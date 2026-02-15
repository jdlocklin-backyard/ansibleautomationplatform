# Ansible Playbook Testing Checklist

## Project Overview
**Goal:** Reorganize, test, and fix all Ansible playbooks in the homelab repository

**Strategy:** 
- Test playbooks one-by-one on ansible5 control node
- Fix issues as they're discovered
- Commit each fix to git immediately
- All playbooks updated to use `hosts: all`

## Connection Information
**Local Repository:** `D:\OPENCODE\ansibleautomationplatform`  
**Remote Repository:** `/root/ansibleautomationplatform`  
**Remote Host:** ansible5 (10.0.0.42) - RHEL 8.10 - AAP Control Node  
**SSH Command:** `ssh root@10.0.0.42`  
**Inventory File:** `inventory_homelab.ini`

## Test Command Template
```bash
cd /root/ansibleautomationplatform
git pull
ansible-playbook <playbook_path> -i inventory_homelab.ini
```

## Managed Hosts (from inventory_homelab.ini)
- **ansible1** - 10.0.0.116 (Ubuntu) - ⚠️ Has broken kubic apt repository
- **ansible2** - 10.0.0.168 (Ubuntu)
- **ansible3** - 10.0.0.194 (Ubuntu)
- **ansible5** - 10.0.0.42 (RHEL 8.10) - AAP Control Node

---

## Diagnostics Playbooks

### ✅ ping_simple.yml
- **Local:** `D:\OPENCODE\ansibleautomationplatform\diagnostics\ping_simple.yml`
- **Remote:** `/root/ansibleautomationplatform/diagnostics/ping_simple.yml`
- **Status:** TESTED - PASSED
- **Description:** Simple connectivity test to all hosts
- **Notes:** All 4 hosts responded ok=1

### ✅ system_info_simple.yml
- **Local:** `D:\OPENCODE\ansibleautomationplatform\diagnostics\system_info_simple.yml`
- **Remote:** `/root/ansibleautomationplatform/diagnostics/system_info_simple.yml`
- **Status:** TESTED - PASSED
- **Description:** Gather and display system information (OS, version, architecture)
- **Notes:** Successfully retrieved info from all hosts

---

## Maintenance Playbooks

### ⏭️ os_update_intermediate.yml
- **Local:** `D:\OPENCODE\ansibleautomationplatform\maintenance\os_update_intermediate.yml`
- **Remote:** `/root/ansibleautomationplatform/maintenance/os_update_intermediate.yml`
- **Status:** SKIPPED - Test later
- **Description:** Update packages on Ubuntu, RHEL, and Arch Linux systems
- **Notes:** Not tested yet - would update production systems. Missing Arch Linux task.

---

## Deployment Playbooks - Webserver

### 🔧 apache_install_simple.yml
- **Local:** `D:\OPENCODE\ansibleautomationplatform\deployment\webserver\apache_install_simple.yml`
- **Remote:** `/root/ansibleautomationplatform/deployment/webserver/apache_install_simple.yml`
- **Status:** FIXED - Ready for re-test
- **Description:** Install Apache web server (apache2 on Ubuntu, httpd on RHEL)
- **Git Commits:**
  - cbea223 - Added OS compatibility (Ubuntu/RHEL)
  - 18081c9 - Added apt cache error handling
- **Notes:** Fixed broken apt cache issue on ansible1. Includes retry logic.
- **Test Command:** `ansible-playbook deployment/webserver/apache_install_simple.yml -i inventory_homelab.ini`

### ⏳ apache_template_simple.yml
- **Local:** `D:\OPENCODE\ansibleautomationplatform\deployment\webserver\apache_template_simple.yml`
- **Remote:** `/root/ansibleautomationplatform/deployment/webserver/apache_template_simple.yml`
- **Status:** PENDING - Not tested
- **Description:** Deploy Apache with Jinja2 template for index.html
- **Dependencies:** Requires `deployment/webserver/templates/template_web.html.j2`
- **Notes:** Template file created in commit 4ac696e

### ⏳ apache_config_intermediate.yml
- **Local:** `D:\OPENCODE\ansibleautomationplatform\deployment\webserver\apache_config_intermediate.yml`
- **Remote:** `/root/ansibleautomationplatform/deployment/webserver/apache_config_intermediate.yml`
- **Status:** PENDING - Not tested
- **Description:** Configure Apache with custom httpd.conf
- **Dependencies:** Requires `deployment/webserver/files/httpd.conf`
- **Notes:** Config file created in commit 4ac696e

---

## Educational Playbooks

### ⏳ ai_learning_intermediate.yml
- **Local:** `D:\OPENCODE\ansibleautomationplatform\educational\ai_learning_intermediate.yml`
- **Remote:** `/root/ansibleautomationplatform/educational/ai_learning_intermediate.yml`
- **Status:** PENDING - Not tested
- **Description:** Comprehensive Ansible learning playbook with various tasks
- **Notes:** Reorganized from root in commit d217e2c

### 📚 Numbered Educational Playbooks (01-15)
- **Local:** `D:\OPENCODE\ansibleautomationplatform\educational\`
- **Remote:** `/root/ansibleautomationplatform/educational/`
- **Status:** NOT REORGANIZED - Left unchanged
- **Playbooks:**
  - 01_hello_ansible.yml
  - 02_file_management.yml
  - 03_user_management.yml
  - 04_package_installation.yml
  - 05_service_control.yml
  - 06_template_basics.yml
  - 07_conditionals.yml
  - 08_loops.yml
  - 09_handlers.yml
  - 10_docker_basics.yml
  - 11_firewall_rules.yml
  - 12_cron_jobs.yml
  - 13_error_handling.yml
  - 14_facts_magic_variables.yml
  - 15_vault_secrets.yml

---

## Proxmox Playbooks

### 🏠 Proxmox Educational Series
- **Local:** `D:\OPENCODE\ansibleautomationplatform\proxmox\`
- **Remote:** `/root/ansibleautomationplatform/proxmox/`
- **Status:** NOT REORGANIZED - Left unchanged
- **Playbooks:**
  - proxmox_01_create_container.yml
  - proxmox_02_create_vm.yml
  - proxmox_03_prep_ssh_keys.yml
  - proxmox_04_configure_passwordless.yml
  - proxmox_05_homelab_structure.yml
  - proxmox_06_host_info.yml

---

## Git Commit History

### Reorganization Phase
- **d217e2c** - Reorganized root playbooks into categorized directories
- **4ac696e** - Added support files (prod_web.html, template_web.html.j2, httpd.conf)

### Bug Fixes
- **cbea223** - Fixed Apache playbooks for OS compatibility (Ubuntu apache2 / RHEL httpd)
- **18081c9** - Added apt cache error handling for apache install (ansible1 kubic repo issue)

---

## Known Issues

### ansible1 (10.0.0.116)
- **Issue:** Broken apt repository - `http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_24.04`
- **Impact:** `apt update` fails on this host
- **Workaround:** Added `ignore_errors` and retry logic without cache update

---

## Next Testing Session

1. **Re-test apache_install_simple.yml** - Verify apt cache fix works
2. **Test apache_template_simple.yml** - Template deployment
3. **Test apache_config_intermediate.yml** - Custom Apache configuration
4. **Test ai_learning_intermediate.yml** - Educational playbook
5. **Later: Fix and test os_update_intermediate.yml** - Add Arch Linux support

---

## Quick Reference

### Pull latest changes
```bash
ssh root@10.0.0.42
cd /root/ansibleautomationplatform
git pull
```

### Test a playbook
```bash
ansible-playbook <path_to_playbook> -i inventory_homelab.ini
```

### Check playbook syntax
```bash
ansible-playbook <path_to_playbook> --syntax-check
```

### Dry run (check mode)
```bash
ansible-playbook <path_to_playbook> -i inventory_homelab.ini --check
```
