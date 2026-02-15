#!/bin/bash
# =============================================================================
# Configure Ubuntu VM for SSH + Ansible Access
# =============================================================================
# Run this ON the Proxmox host: bash configure_vm_ssh.sh <VM_ID>
# Uses 'qm guest exec' to configure the VM via QEMU Guest Agent.
#
# PREREQUISITES:
#   - VM must be running
#   - QEMU Guest Agent must be installed and running in the VM
#   - If using cloud-init, the user/password may already be set
#
# What it does:
#   1. Creates 'ansible' user with sudo privileges
#   2. Configures SSH for password authentication
#   3. Installs Python3 for Ansible
#   4. Sets up SSH keys
# =============================================================================

set -e

VM_ID="${1:-6001}"
ANSIBLE_USER="ansible"
ANSIBLE_PASS="ansible"

echo "============================================"
echo "  Configuring VM $VM_ID"
echo "============================================"

# Wait for QEMU agent to be available
echo "[1/6] Waiting for QEMU Guest Agent..."
for i in $(seq 1 30); do
    if qm agent "$VM_ID" ping > /dev/null 2>&1; then
        echo "  Agent responding."
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "  ERROR: Guest agent not responding after 60 seconds."
        echo "  Make sure qemu-guest-agent is installed and running in the VM."
        exit 1
    fi
    sleep 2
done

# Install required packages
echo "[2/6] Installing openssh-server, sudo, python3..."
qm guest exec "$VM_ID" -- bash -c "
    apt-get update -qq && \
    apt-get install -y -qq openssh-server sudo python3 python3-apt qemu-guest-agent > /dev/null 2>&1
    systemctl enable qemu-guest-agent
    systemctl start qemu-guest-agent
"

# Create ansible user
echo "[3/6] Creating ansible user..."
qm guest exec "$VM_ID" -- bash -c "
    useradd -m -s /bin/bash $ANSIBLE_USER 2>/dev/null || true
    echo '$ANSIBLE_USER:$ANSIBLE_PASS' | chpasswd
"

# Configure sudo
echo "[4/6] Configuring sudo access..."
qm guest exec "$VM_ID" -- bash -c "
    usermod -aG sudo $ANSIBLE_USER
    echo '$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
    chmod 440 /etc/sudoers.d/ansible
"

# Configure SSH
echo "[5/6] Configuring SSH..."
qm guest exec "$VM_ID" -- bash -c "
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl enable ssh
    systemctl restart ssh
"

# Set up SSH keys
echo "[6/6] Setting up SSH keys..."
if [ -f /root/.ssh/id_rsa.pub ]; then
    SSH_KEY=$(cat /root/.ssh/id_rsa.pub)
    qm guest exec "$VM_ID" -- bash -c "
        mkdir -p /root/.ssh && chmod 700 /root/.ssh
        echo '$SSH_KEY' >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys

        mkdir -p /home/$ANSIBLE_USER/.ssh && chmod 700 /home/$ANSIBLE_USER/.ssh
        echo '$SSH_KEY' >> /home/$ANSIBLE_USER/.ssh/authorized_keys
        chown -R $ANSIBLE_USER:$ANSIBLE_USER /home/$ANSIBLE_USER/.ssh
        chmod 600 /home/$ANSIBLE_USER/.ssh/authorized_keys
    "
    echo "  SSH keys configured for root and $ANSIBLE_USER"
else
    echo "  WARNING: No SSH key found at /root/.ssh/id_rsa.pub"
fi

# Get VM IP
VM_IP=$(qm guest cmd "$VM_ID" network-get-interfaces 2>/dev/null | \
    python3 -c "import sys,json; data=json.load(sys.stdin); [print(a['ip-address']) for i in data for a in i.get('ip-addresses',[]) if a.get('ip-address-type')=='ipv4' and not a['ip-address'].startswith('127.')]" 2>/dev/null | head -1)

echo ""
echo "============================================"
echo "  VM $VM_ID Configured!"
echo "============================================"
echo "  IP:        ${VM_IP:-'Getting IP...'}"
echo ""
echo "  SSH Access:"
echo "    ssh root@${VM_IP:-<IP>}"
echo "    ssh $ANSIBLE_USER@${VM_IP:-<IP>}"
echo ""
echo "  Credentials:"
echo "    ansible user:     $ANSIBLE_USER"
echo "    ansible password: $ANSIBLE_PASS"
echo "    sudo:             NOPASSWD enabled"
echo ""
echo "  Ansible Inventory Entry:"
echo "    ubuntu-vm ansible_host=${VM_IP:-<IP>} ansible_user=$ANSIBLE_USER ansible_password=$ANSIBLE_PASS ansible_become_password=$ANSIBLE_PASS"
echo "============================================"
