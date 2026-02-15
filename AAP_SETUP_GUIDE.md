# Ansible Automation Platform Setup Guide

> **Last Updated:** February 14, 2026  
> **AAP Server:** ansible5 (VM 2004)  
> **IP Address:** 10.0.0.42  
> **Web URL:** https://ansible.codeandcamera.me (via Cloudflare) or https://10.0.0.42

---

## Table of Contents

1. [Access Information](#access-information)
2. [Initial Setup](#initial-setup)
3. [Inventory Configuration](#inventory-configuration)
4. [Project Configuration](#project-configuration)
5. [Credentials Setup](#credentials-setup)
6. [Testing Playbooks](#testing-playbooks)
7. [Troubleshooting](#troubleshooting)

---

## Access Information

### Web Interface

**External URL:** https://ansible.codeandcamera.me  
**Direct URL:** https://10.0.0.42  
**Port:** 443 (HTTPS)

**Credentials (from VM notes):**
- **Username:** `admin`
- **Password:** `ansible`

### SSH Access

```bash
ssh root@10.0.0.42
# Password: root123
```

### Service Status

AAP runs as multiple services:
```bash
# Check AWX services
systemctl status automation-controller-dispatcher
systemctl status automation-controller-callback-receiver
systemctl status automation-controller-web
systemctl status automation-controller-task

# Check nginx
systemctl status nginx

# Check receptor
systemctl status receptor
```

**Key Processes:**
- `nginx` - Web server on ports 80/443
- `uwsgi` - Application server (socket: /var/run/tower/uwsgi.sock)
- `daphne` - WebSocket server (socket: /var/run/tower/daphne.sock)
- `awx-manage` - Management processes
- `receptor` - Automation mesh

---

## Initial Setup

### 1. First Login

1. Navigate to https://ansible.codeandcamera.me or https://10.0.0.42
2. Accept the self-signed certificate warning
3. Login with:
   - Username: `admin`
   - Password: `ansible`

### 2. Initial Configuration Wizard

If this is the first time logging in, you may see a setup wizard. Complete these steps:

1. **User Agreement** - Accept the terms
2. **Subscription** - Skip if not using Red Hat subscription
3. **Analytics** - Configure based on preference

---

## Inventory Configuration

### Option 1: Using the Web GUI

1. **Navigate to Inventories**
   - Click **Resources** → **Inventories**
   - Click **Add** → **Add Inventory**

2. **Create Inventory**
   - **Name:** `Homelab`
   - **Description:** `Ansible homelab infrastructure`
   - **Organization:** Default
   - Click **Save**

3. **Add Hosts**
   - Click on **Homelab** inventory
   - Click **Hosts** tab → **Add**
   - Add each host:

   **Host: ansible1**
   ```
   Name: ansible1
   Variables (YAML):
   ---
   ansible_host: 10.0.0.116
   ansible_user: ansible
   ansible_password: ansible
   ansible_become_password: ansible
   ansible_python_interpreter: /usr/bin/python3
   ```

   **Host: ansible2**
   ```
   Name: ansible2
   Variables (YAML):
   ---
   ansible_host: 10.0.0.168
   ansible_user: ansible
   ansible_password: ansible
   ansible_become_password: ansible
   ansible_python_interpreter: /usr/bin/python3
   ```

   **Host: ansible3**
   ```
   Name: ansible3
   Variables (YAML):
   ---
   ansible_host: 10.0.0.194
   ansible_user: ansible
   ansible_password: ansible
   ansible_become_password: ansible
   ansible_python_interpreter: /usr/bin/python3
   ```

   **Host: ansible5**
   ```
   Name: ansible5
   Variables (YAML):
   ---
   ansible_host: 10.0.0.42
   ansible_user: root
   ansible_password: root123
   ansible_python_interpreter: /usr/bin/python3
   ```

4. **Create Groups** (Optional)
   - Click **Groups** tab → **Add**
   
   **Group: ansible_control**
   - Add host: `ansible1`
   
   **Group: ansible_nodes**
   - Add hosts: `ansible2`, `ansible3`, `ansible5`

### Option 2: Import from File (Recommended)

1. **Sync Inventory File from Server**
   ```bash
   # The inventory is already deployed at:
   # /etc/ansible/hosts on ansible5
   ```

2. **Create Inventory from Source**
   - Navigate to **Inventories** → **Add** → **Add Inventory**
   - Name: `Homelab`
   - Click **Save**
   - Click **Sources** tab → **Add**
   - **Source:** Custom Script
   - Paste inventory file content or use file path

---

## Project Configuration

### 1. Create Project for GitHub Repository

1. **Navigate to Projects**
   - Click **Resources** → **Projects**
   - Click **Add**

2. **Configure Project**
   ```
   Name: AAP Playbooks
   Description: Ansible Automation Platform playbooks from GitHub
   Organization: Default
   
   Source Control Type: Git
   Source Control URL: https://github.com/jdlocklin-backyard/ansibleautomationplatform.git
   Source Control Branch: main
   
   SCM Update Options:
   ☑ Update Revision on Launch
   ☑ Clean
   ```

3. **Save and Sync**
   - Click **Save**
   - Click the sync icon to pull playbooks from GitHub

### 2. Verify Playbooks Are Available

After sync, the following playbooks should be available:
- `ping.yml` - Basic connectivity test
- `specs.yml` - System specifications
- `multiOSupdate.yml` - OS updates
- `installgitcurl.yml` - Install git and curl
- Educational playbooks (15 files in `educational/`)
- Proxmox playbooks (6 files in `proxmox/`)

---

## Credentials Setup

### Machine Credentials

1. **Navigate to Credentials**
   - Click **Resources** → **Credentials**
   - Click **Add**

2. **Create Ansible Nodes Credential**
   ```
   Name: Ansible Nodes SSH
   Description: SSH credentials for ansible user
   Organization: Default
   Credential Type: Machine
   
   Username: ansible
   Password: ansible
   Privilege Escalation Method: sudo
   Privilege Escalation Username: root
   Privilege Escalation Password: ansible
   ```

3. **Create Root Credential (for ansible5)**
   ```
   Name: Root SSH
   Description: Root SSH for ansible5
   Organization: Default
   Credential Type: Machine
   
   Username: root
   Password: root123
   ```

### Source Control Credentials (Optional)

If the GitHub repository is private:

1. **Create GitHub Credential**
   ```
   Name: GitHub PAT
   Description: Personal Access Token for GitHub
   Credential Type: Source Control
   
   Username: your-github-username
   Password: your-personal-access-token
   ```

---

## Testing Playbooks

### Test 1: Ping Playbook

1. **Create Job Template**
   - Navigate to **Resources** → **Templates**
   - Click **Add** → **Add Job Template**
   
   ```
   Name: Test Ping
   Job Type: Run
   Inventory: Homelab
   Project: AAP Playbooks
   Playbook: ping.yml
   Credentials: Ansible Nodes SSH
   
   Options:
   ☑ Enable Privilege Escalation
   ```

2. **Launch Job**
   - Click **Save**
   - Click **Launch**
   - Verify all hosts respond with "ok=1"

### Test 2: System Specs

1. **Create Job Template**
   ```
   Name: Get System Specs
   Job Type: Run
   Inventory: Homelab
   Project: AAP Playbooks
   Playbook: specs.yml
   Credentials: Ansible Nodes SSH
   ```

2. **Launch and Review Output**

---

## Current Infrastructure Status

### Configured Hosts

| Host | IP | User | Status | Notes |
|------|------------|------|--------|-------|
| ansible1 | 10.0.0.116 | ansible | ✅ Ready | Control node |
| ansible2 | 10.0.0.168 | ansible | ✅ Ready | Managed node |
| ansible3 | 10.0.0.194 | ansible | ✅ Ready | Managed node |
| ansible5 | 10.0.0.42 | root | ✅ Ready | AAP server (RHEL 8) |

### Not Yet Configured

| Host | IP | Status | Reason |
|------|------------|--------|--------|
| ansible4 | TBD | ⚠️ Pending | QEMU guest agent not running |
| ansible6 | TBD | ⚠️ Pending | QEMU guest agent not running |

---

## Troubleshooting

### Web Interface Not Loading

**Check nginx:**
```bash
ssh root@10.0.0.42
systemctl status nginx
journalctl -u nginx -n 50
```

**Check AWX services:**
```bash
ps aux | grep awx
systemctl status automation-controller-*
```

### Playbook Fails to Connect

**Issue:** "Permission denied" or "Host unreachable"

**Solutions:**

1. **Verify credentials in inventory/template**
   - Check username/password are correct
   - Verify ansible_host IP is correct

2. **Test SSH manually:**
   ```bash
   ssh ansible@10.0.0.168
   # Use password: ansible
   ```

3. **Check host key checking:**
   - Ensure `host_key_checking = False` in ansible.cfg
   - Or add to inventory: `ansible_ssh_common_args: '-o StrictHostKeyChecking=no'`

### Inventory Not Syncing

1. **Check project sync status**
   - Navigate to Projects → AAP Playbooks
   - Click sync icon
   - Review sync output for errors

2. **Verify GitHub repository access**
   - Test URL: https://github.com/jdlocklin-backyard/ansibleautomationplatform.git
   - Check if private repo needs credentials

### Can't Access via Cloudflare

**Check Cloudflare tunnel:**
```bash
# On cloudflare1 (CT 3100) or cloudflare2 (CT 3200)
systemctl status cloudflared
journalctl -u cloudflared -f
```

**Verify tunnel route:**
- Should route `ansible.codeandcamera.me` to `https://10.0.0.42`

---

## Configuration Files

### Ansible Configuration

**Location:** `/etc/ansible/ansible.cfg`

```ini
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
remote_user = root
timeout = 30
gather_facts = True

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
```

### Inventory File

**Location:** `/etc/ansible/hosts`

```ini
# Ansible Inventory for Homelab
# Updated: February 14, 2026
# Network: 10.0.0.0/24 (post-ISP migration)

[ansible_control]
ansible1 ansible_host=10.0.0.116 ansible_user=ansible ansible_password=ansible ansible_become_password=ansible

[ansible_nodes]
ansible2 ansible_host=10.0.0.168 ansible_user=ansible ansible_password=ansible ansible_become_password=ansible
ansible3 ansible_host=10.0.0.194 ansible_user=ansible ansible_password=ansible ansible_become_password=ansible
ansible5 ansible_host=10.0.0.42 ansible_user=root ansible_password=root123

[ansible_nodes:vars]
ansible_python_interpreter=/usr/bin/python3

[homelab:children]
ansible_control
ansible_nodes

[homelab:vars]
ansible_connection=ssh
```

---

## Next Steps

1. ✅ AAP is running and accessible
2. ✅ Inventory file configured with correct IPs and credentials
3. ✅ ping.yml tested successfully from CLI
4. ⚠️ **TODO:** Configure inventory in AAP GUI
5. ⚠️ **TODO:** Create project from GitHub repository
6. ⚠️ **TODO:** Create job templates
7. ⚠️ **TODO:** Test playbooks from GUI

---

## Additional Resources

- **GitHub Repository:** https://github.com/jdlocklin-backyard/ansibleautomationplatform
- **AAP Documentation:** https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/
- **Homelab Docs:** https://github.com/jdlocklin-backyard/homelab

---

**Document Version:** 1.0  
**Created:** February 14, 2026  
**Maintainer:** Infrastructure Team
