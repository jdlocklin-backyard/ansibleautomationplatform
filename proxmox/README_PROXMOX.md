# Proxmox Admin Playbooks

A comprehensive collection of Ansible playbooks designed to run **directly on the Proxmox server** for managing containers, VMs, and system configuration. These playbooks use Proxmox's built-in CLI tools (`pct`, `qm`, `pvesh`) instead of SSH to manage guest systems.

## Important: Run on Proxmox Server Only

These playbooks are designed to run **locally on your Proxmox host**, not from a remote Ansible control node. This approach allows direct access to Proxmox CLI tools and eliminates the need for API authentication.

---

## Setting Up Ansible on Proxmox

### Step 1: Update System Packages

```bash
# Update package lists
apt update

# Upgrade existing packages (optional but recommended)
apt upgrade -y
```

### Step 2: Install Ansible

Proxmox is based on Debian, so we use apt:

```bash
# Install Ansible and dependencies
apt install -y ansible python3-pip python3-jmespath jq

# Verify installation
ansible --version
```

**Expected output:**
```
ansible [core 2.14.x]
  config file = /etc/ansible/ansible.cfg
  ...
```

### Step 3: Install Additional Python Packages

Some playbooks use advanced features that require extra packages:

```bash
# Install community.general collection (for advanced filters)
ansible-galaxy collection install community.general

# Install python requirements for JSON parsing
pip3 install jmespath
```

### Step 4: Configure Ansible for Local Use

Create or edit `/etc/ansible/ansible.cfg`:

```bash
cat > /etc/ansible/ansible.cfg << 'EOF'
[defaults]
# Run locally by default
inventory = /etc/ansible/hosts
host_key_checking = False
retry_files_enabled = False

# Reduce verbosity of success messages
display_skipped_hosts = False

# Performance tuning
forks = 10
pipelining = True

[privilege_escalation]
become = True
become_method = sudo
become_user = root
EOF
```

### Step 5: Create a Basic Inventory

```bash
mkdir -p /etc/ansible/hosts.d

cat > /etc/ansible/hosts << 'EOF'
# Proxmox Host Inventory
# Additional host files can be placed in /etc/ansible/hosts.d/

[proxmox]
localhost ansible_connection=local

# Guest hosts will be added by proxmox_04_configure_passwordless.yml
EOF
```

### Step 6: Clone This Repository

```bash
# Clone to a convenient location
cd /root
git clone https://github.com/jdlocklin-backyard/ansibleautomationplatform.git
cd ansibleautomationplatform

# Or if already cloned, pull latest changes
git pull origin main
```

### Step 7: Verify Setup

```bash
# Test Ansible is working
ansible localhost -m ping

# Test a simple playbook
ansible-playbook proxmox/proxmox_06_host_info.yml
```

---

## Playbook Overview

| # | Playbook | Purpose |
|---|----------|---------|
| 01 | `proxmox_01_create_container.yml` | Create LXC containers with custom configuration |
| 02 | `proxmox_02_create_vm.yml` | Create QEMU/KVM virtual machines |
| 03 | `proxmox_03_prep_ssh_keys.yml` | Copy SSH keys to containers/VMs |
| 04 | `proxmox_04_configure_passwordless.yml` | Configure passwordless SSH access |
| 05 | `proxmox_05_homelab_structure.yml` | Create standard folder structure for homelab apps |
| 06 | `proxmox_06_host_info.yml` | Get configuration info on all hosts |

---

## Quick Start Guide

### 1. Create Your First Container

```bash
# Create a Debian container with default settings
ansible-playbook proxmox/proxmox_01_create_container.yml

# Create with custom settings
ansible-playbook proxmox/proxmox_01_create_container.yml \
  -e "ct_id=101" \
  -e "ct_hostname=webserver" \
  -e "ct_memory=1024" \
  -e "ct_cores=2"
```

### 2. Set Up SSH Access

```bash
# Copy SSH keys to all running guests
ansible-playbook proxmox/proxmox_03_prep_ssh_keys.yml

# Configure passwordless SSH and create inventory
ansible-playbook proxmox/proxmox_04_configure_passwordless.yml
```

### 3. Set Up Homelab Directories

```bash
# Create standard folder structure on all guests
ansible-playbook proxmox/proxmox_05_homelab_structure.yml
```

### 4. Get System Information

```bash
# Display info about all hosts
ansible-playbook proxmox/proxmox_06_host_info.yml

# Save report to file
ansible-playbook proxmox/proxmox_06_host_info.yml -e "save_report=true"
```

---

## How These Playbooks Work

### No SSH Required (for Proxmox CLI)

These playbooks run **locally** on the Proxmox server and use built-in commands:

| Tool | Purpose | Example |
|------|---------|---------|
| `pct` | Container management | `pct exec 100 -- hostname` |
| `qm` | VM management | `qm guest cmd 200 ping` |
| `pvesh` | API access | `pvesh get /nodes/pve/status` |
| `pvesm` | Storage management | `pvesm status` |
| `pvecm` | Cluster management | `pvecm status` |

### Communicating with Guests

**Containers (LXC):**
```bash
# Run commands inside a container
pct exec <vmid> -- <command>

# Example: Get IP address
pct exec 100 -- hostname -I

# Push file to container
pct push 100 /local/file /container/path
```

**Virtual Machines:**
```bash
# Requires QEMU guest agent installed in VM
qm guest cmd <vmid> ping
qm guest exec <vmid> -- <command>

# Get network info
qm guest cmd 200 network-get-interfaces
```

---

## Preparing Container Templates

Before creating containers, you need templates:

```bash
# List available templates
pveam available

# Download a template (e.g., Debian 12)
pveam download local debian-12-standard_12.7-1_amd64.tar.zst

# List downloaded templates
pveam list local
```

---

## Preparing VM Templates (Cloud-Init)

For faster VM deployment, create a cloud-init enabled template:

```bash
# Download a cloud image (example: Debian)
cd /var/lib/vz/template/iso/
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

# Create a VM for the template
qm create 9000 --name debian12-cloudinit --memory 2048 --net0 virtio,bridge=vmbr0

# Import the disk
qm importdisk 9000 debian-12-generic-amd64.qcow2 local-lvm

# Attach the disk
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0

# Add cloud-init drive
qm set 9000 --ide2 local-lvm:cloudinit

# Set boot order
qm set 9000 --boot c --bootdisk scsi0

# Enable serial console
qm set 9000 --serial0 socket --vga serial0

# Convert to template
qm template 9000
```

---

## Common Customizations

### Container Creation Variables

```yaml
ct_id: 100                    # Container ID
ct_hostname: "mycontainer"    # Hostname
ct_memory: 512                # Memory in MB
ct_cores: 1                   # CPU cores
ct_storage: "local-lvm"       # Storage pool
ct_rootfs_size: 8             # Disk size in GB
ct_bridge: "vmbr0"            # Network bridge
ct_ip: "dhcp"                 # IP (or static like 192.168.1.100/24)
ct_unprivileged: true         # Unprivileged container (more secure)
```

### VM Creation Variables

```yaml
vm_id: 200                    # VM ID
vm_name: "myvm"               # VM name
vm_install_method: "cloudinit" # clone, cloudinit, or iso
vm_clone_source: 9000         # Template to clone from
vm_memory: 2048               # Memory in MB
vm_cores: 2                   # CPU cores
vm_disk_size: "32G"           # Disk size
ci_user: "admin"              # Cloud-init user
ci_password: "changeme"       # Cloud-init password
```

---

## Directory Structure

After running `proxmox_05_homelab_structure.yml`, your guests will have:

```
/opt/homelab/
├── apps/                   # Application directories
│   ├── portainer/
│   ├── nginx-proxy/
│   ├── pihole/
│   └── ...
├── data/                   # Persistent data
│   ├── databases/
│   ├── media/
│   └── documents/
├── config/                 # Configuration files
│   ├── ssl/
│   └── env/
├── docker/                 # Docker-related files
│   ├── compose/
│   └── volumes/
├── backups/                # Local backups
├── scripts/                # Maintenance scripts
│   ├── backup.sh
│   └── update.sh
├── logs/                   # Application logs
└── secrets/                # Sensitive data
```

---

## Troubleshooting

### "pct: command not found"
You're not running on a Proxmox host. These playbooks must run directly on Proxmox.

### "Container already exists"
Use a different container ID or destroy the existing one:
```bash
pct stop 100
pct destroy 100
```

### "VM guest agent not responding"
Install qemu-guest-agent in the VM:
```bash
# Debian/Ubuntu
apt install qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent
```

### "Template not found"
Download the template first:
```bash
pveam download local debian-12-standard_12.7-1_amd64.tar.zst
```

### SSH connection refused
Ensure the SSH service is running in the guest:
```bash
pct exec 100 -- systemctl status sshd
pct exec 100 -- systemctl start sshd
```

---

## Security Considerations

1. **SSH Keys**: Always use SSH key authentication, not passwords
2. **Unprivileged Containers**: Use `ct_unprivileged: true` when possible
3. **Firewall**: Consider enabling the Proxmox firewall
4. **Secrets**: Store sensitive data in the `/opt/homelab/secrets/` directory with restricted permissions
5. **Backups**: Regularly backup your containers/VMs using Proxmox Backup Server or the included backup script

---

## Learning Resources

- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Ansible Documentation](https://docs.ansible.com/)
- [LXC Container Guide](https://pve.proxmox.com/wiki/Linux_Container)
- [QEMU/KVM Guide](https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines)

---

## Contributing

Each playbook is heavily commented for educational purposes. When adding new playbooks:

1. Follow the `proxmox_XX_name.yml` naming convention
2. Include the "IMPORTANT: Proxmox server only" header
3. Add comprehensive inline comments
4. Update this README with the new playbook

---

Happy Proxmox Automation!
