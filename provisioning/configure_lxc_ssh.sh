#!/bin/bash
# =============================================================================
# Configure Ubuntu LXC Container for SSH + Ansible Access
# =============================================================================
# Run this ON the Proxmox host: bash configure_lxc_ssh.sh <CT_ID>
# It uses 'pct exec' to configure the container from the outside.
#
# What it does:
#   1. Updates packages and installs openssh-server, sudo, python3
#   2. Creates 'ansible' user with sudo privileges
#   3. Configures SSH for password authentication
#   4. Sets up Proxmox host's SSH key for root access
#   5. Displays the container's IP address
# =============================================================================

set -e

CT_ID="${1:-6000}"
ANSIBLE_USER="ansible"
ANSIBLE_PASS="ansible"

echo "============================================"
echo "  Configuring LXC Container $CT_ID"
echo "============================================"

# Wait for container to be fully ready
echo "[1/7] Waiting for container to be ready..."
sleep 5

# Update packages and install SSH + Python
echo "[2/7] Installing openssh-server, sudo, python3..."
pct exec "$CT_ID" -- bash -c "
    apt-get update -qq && \
    apt-get install -y -qq openssh-server sudo python3 python3-apt > /dev/null 2>&1
"

# Create ansible user with password
echo "[3/7] Creating ansible user..."
pct exec "$CT_ID" -- bash -c "
    useradd -m -s /bin/bash $ANSIBLE_USER 2>/dev/null || true
    echo '$ANSIBLE_USER:$ANSIBLE_PASS' | chpasswd
"

# Add ansible user to sudo group with NOPASSWD
echo "[4/7] Configuring sudo access..."
pct exec "$CT_ID" -- bash -c "
    usermod -aG sudo $ANSIBLE_USER
    echo '$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
    chmod 440 /etc/sudoers.d/ansible
"

# Configure SSH
echo "[5/7] Configuring SSH..."
pct exec "$CT_ID" -- bash -c "
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl enable ssh
    systemctl restart ssh
"

# Set up SSH keys for root from Proxmox host
echo "[6/7] Setting up SSH keys..."
if [ -f /root/.ssh/id_rsa.pub ]; then
    pct exec "$CT_ID" -- bash -c "
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
    "
    pct push "$CT_ID" /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
    pct exec "$CT_ID" -- bash -c "chmod 600 /root/.ssh/authorized_keys"

    # Also add key for ansible user
    pct exec "$CT_ID" -- bash -c "
        mkdir -p /home/$ANSIBLE_USER/.ssh
        chmod 700 /home/$ANSIBLE_USER/.ssh
        cp /root/.ssh/authorized_keys /home/$ANSIBLE_USER/.ssh/authorized_keys
        chown -R $ANSIBLE_USER:$ANSIBLE_USER /home/$ANSIBLE_USER/.ssh
        chmod 600 /home/$ANSIBLE_USER/.ssh/authorized_keys
    "
    echo "  SSH keys configured for root and $ANSIBLE_USER"
else
    echo "  WARNING: No SSH key found at /root/.ssh/id_rsa.pub"
    echo "  Generate one: ssh-keygen -t rsa -b 4096"
fi

# Get container IP
echo "[7/7] Getting container IP..."
sleep 3
CT_IP=$(pct exec "$CT_ID" -- hostname -I 2>/dev/null | awk '{print $1}')

echo ""
echo "============================================"
echo "  Container $CT_ID Configured!"
echo "============================================"
echo "  Hostname:  $(pct exec "$CT_ID" -- hostname)"
echo "  IP:        ${CT_IP:-'Waiting for DHCP...'}"
echo ""
echo "  SSH Access:"
echo "    ssh root@${CT_IP:-<IP>}"
echo "    ssh $ANSIBLE_USER@${CT_IP:-<IP>}"
echo ""
echo "  Credentials:"
echo "    root password:    $ANSIBLE_PASS"
echo "    ansible user:     $ANSIBLE_USER"
echo "    ansible password: $ANSIBLE_PASS"
echo "    sudo:             NOPASSWD enabled"
echo ""
echo "  Ansible Inventory Entry:"
echo "    ubuntu-lxc ansible_host=${CT_IP:-<IP>} ansible_user=$ANSIBLE_USER ansible_password=$ANSIBLE_PASS ansible_become_password=$ANSIBLE_PASS"
echo "============================================"
