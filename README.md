# Ansible Automation Platform - Homelab Playbooks

Comprehensive Ansible playbook collection for homelab infrastructure management.

**Access:** https://ansible.codeandcamera.me

---

## 📁 Repository Structure

### 🔍 diagnostics/
System testing and information gathering
- `ping_simple.yml` - Test connectivity to all hosts
- `system_info_simple.yml` - Gather hardware/OS specs

### 🔧 maintenance/
Routine maintenance tasks
- `os_update_intermediate.yml` - Multi-OS system updates (Ubuntu/Arch/Windows)

### 🚀 deployment/
Application and service deployments

**apps/** - Application-specific deployments
- `garden_agent_advanced.yml` - Deploy garden monitoring agent (Docker-based)

**webserver/** - Web server management
- `apache_install_simple.yml` - Install and configure Apache
- `apache_template_simple.yml` - Deploy Apache with Jinja2 templates
- `apache_config_intermediate.yml` - Manage Apache configuration with handlers

### 📚 educational/
Progressive Ansible learning curriculum - [See educational/README.md](educational/README.md)

### 🖥️ proxmox/
Proxmox VE administration playbooks - [See proxmox/README_PROXMOX.md](proxmox/README_PROXMOX.md)

---

## 🚀 Quick Start

### Test Connectivity:
```bash
ansible-playbook diagnostics/ping_simple.yml
```

### Get System Information:
```bash
ansible-playbook diagnostics/system_info_simple.yml
```

### Update All Systems:
```bash
ansible-playbook maintenance/os_update_intermediate.yml
```

### Deploy Apache Web Server:
```bash
ansible-playbook deployment/webserver/apache_install_simple.yml
```

---

## 📖 Documentation
- **[Playbook Testing Checklist](PLAYBOOK_CHECKLIST.md)** - Current testing progress and status ⭐
- [AAP Configuration Order & Refresh Guide](AAP_CONFIGURATION_ORDER.md)
- [AAP GUI Setup Guide](AAP_SETUP_GUIDE.md)
- [AAP GUI Quick Reference](AAP_GUI_QUICKSTART.md)

---

## 🔑 Inventory

**File:** `inventory_homelab.ini`

**Hosts:**
- **ansible1** - 10.0.0.116 (Ubuntu) - Control node ⚠️ Has broken kubic apt repository
- **ansible2** - 10.0.0.168 (Ubuntu) - Managed node
- **ansible3** - 10.0.0.194 (Ubuntu) - Managed node
- **ansible5** - 10.0.0.42 (RHEL 8.10) - AAP Control Node ⭐ Primary testing location

**Groups:**
- `ansible_control` - ansible1
- `ansible_nodes` - ansible2, ansible3, ansible5
- `homelab` - All hosts (children of above)

**All playbooks target:** `hosts: all`

**Testing Location:** SSH to ansible5 (`ssh root@10.0.0.42`), clone repo to `/root/ansibleautomationplatform`

---

## 🛠️ Git Workflow

```bash
# Clone (first time)
git clone https://github.com/jdlocklin-backyard/ansibleautomationplatform.git

# Before working
git pull origin main

# After changes
git add .
git commit -m "Your message"
git push origin main
```

---

## 📋 Naming Convention

Playbooks follow: `<descriptive_name>_<complexity>.yml`

**Complexity Levels:**
- `_simple` - Single purpose, 1-5 tasks, straightforward
- `_intermediate` - Multiple tasks, conditionals, handlers
- `_advanced` - Complex logic, external dependencies, multi-stage

---

## 🧪 Current Testing Status

**Phase:** Reorganization and Testing  
**Progress:** 2/27 playbooks tested (diagnostics complete)  
**Latest:** Fixed apt cache handling for Apache installation  
**Next:** Test apache_install_simple.yml with new error handling

See **[PLAYBOOK_CHECKLIST.md](PLAYBOOK_CHECKLIST.md)** for detailed testing progress.

---

**Repository Version:** 2.1 - Testing in Progress  
**Last Updated:** February 15, 2026
