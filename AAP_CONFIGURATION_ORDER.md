# AAP Configuration Order & Refresh Guide

> **Purpose:** Step-by-step guide for configuring Ansible Automation Platform (AAP)  
> **Date:** February 14, 2026  
> **Environment:** ansible5 (VM 2004) at 10.0.0.42

---

## 🎯 Configuration Order Overview

```
1. Credentials (Optional)
   └─> Used by: Inventories, Projects, Job Templates

2. Inventories + Hosts
   └─> Contains: Hosts, Groups, Variables
   └─> Used by: Job Templates

3. Projects
   └─> Contains: Playbooks from Git/SCM
   └─> Used by: Job Templates

4. Job Templates
   └─> Combines: Inventory + Project + Credentials + Playbook
   └─> This is what you actually execute
```

**Why this order?**
- Job Templates need Inventories and Projects to exist first
- Projects and Inventories can be created in parallel
- Credentials are optional but should be created before being referenced

---

## 📋 Step-by-Step Configuration

### Step 1: Credentials (Optional)

**When to create:**
- For centralized credential management
- SSH keys, vault passwords, cloud credentials
- Private Git repositories

**For password-based authentication:**
- ⚠️ **Can skip** - use inventory host variables instead
- Or create "Machine Credential" for reusability

**Location:** Resources → Credentials → Add

**Example Credential Configuration:**
```
Name: Homelab SSH
Credential Type: Machine
Username: ansible
Password: ansible
```

**When to refresh:** Never (changes are immediate)

---

### Step 2: Inventories + Hosts

#### A. Create Inventory

**Navigation:** Resources → Inventories → Add

**Configuration:**
```
Name: Homelab
Organization: Default
Description: Homelab infrastructure
```

Click **Save**

#### B. Add Hosts

**Navigation:** Click on "Homelab" inventory → Hosts tab → Add

**For each host, create with these details:**

**Host 1:**
```
Name: ansible1

Variables (YAML format):
ansible_host: 10.0.0.116
ansible_user: ansible
ansible_password: ansible
```

**Host 2:**
```
Name: ansible2

Variables (YAML format):
ansible_host: 10.0.0.168
ansible_user: ansible
ansible_password: ansible
```

**Host 3:**
```
Name: ansible3

Variables (YAML format):
ansible_host: 10.0.0.194
ansible_user: ansible
ansible_password: ansible
```

**Host 4:**
```
Name: ansible5

Variables (YAML format):
ansible_host: 10.0.0.42
ansible_user: root
ansible_password: root123
```

Click **Save** after each host.

#### C. Optional: Create Groups

**Navigation:** Inventories → Homelab → Groups → Add

**Example groups:**
```
Group: ansible_nodes
  └─> Hosts: ansible1, ansible2, ansible3

Group: control_nodes
  └─> Hosts: ansible5
```

**When to refresh:**
- ✅ **Static Inventories:** Never (changes are immediate)
- 🔄 **Dynamic Inventories:** Click **Sync** button after cloud source changes

---

### Step 3: Projects

**What it does:**
- Connects to Git repository
- Downloads playbooks to `/var/lib/awx/projects/`
- Keeps playbooks synchronized

**Navigation:** Resources → Projects → Add

**Configuration:**
```
Name: AAP Playbooks
Organization: Default
SCM Type: Git
SCM URL: https://github.com/jdlocklin-backyard/ansibleautomationplatform.git
SCM Branch/Tag/Commit: main

Options:
☑ Update Revision on Launch (recommended - auto-syncs before jobs)
☑ Clean (optional - removes local modifications)
☐ Delete on Update (dangerous - only if needed)
```

Click **Save**

#### ⚠️ IMPORTANT: Sync the Project

**After saving, you MUST sync:**
1. Click the **Sync** button (🔄 icon) next to the project
2. Wait for status to change: "Pending" → "Running" → "Successful"
3. Verify: Click on project → Check "Last Job Status" shows "Successful"

**When to refresh:**
- 🔄 **After initial creation** - Required to download playbooks
- 🔄 **After pushing changes to GitHub** - To pull latest updates
- 🔄 **Before creating Job Templates** - Ensures playbooks are visible
- ⚡ **Auto-refresh:** If "Update Revision on Launch" enabled, syncs automatically

**How to manually refresh:**
```
Resources → Projects → Click Sync button (🔄) next to project name
```

**Verify sync success:**
```
Resources → Projects → Click project name → Check "Revision" field
Should show: Latest commit hash from GitHub
```

---

### Step 4: Job Templates

**What it does:**
- Combines Inventory + Project + Playbook
- Defines execution parameters
- This is what you launch to run playbooks

**Navigation:** Resources → Templates → Add → Add job template

**Configuration:**
```
Name: Ping Test
Description: Basic connectivity test for homelab hosts
Job Type: Run
Inventory: Homelab (select from dropdown)
Project: AAP Playbooks (select from dropdown)
Playbook: ping.yml (select from dropdown - appears after project sync)
Credentials: (leave blank - using host variables)

Options:
☑ Enable Privilege Escalation (if playbooks need sudo)
☑ Enable Fact Storage (optional - stores gather_facts data)
☐ Allow Simultaneous (if you want to run multiple instances)

Advanced:
Forks: 5 (default - parallel execution)
Verbosity: 0 (Normal)
Timeout: 0 (no timeout)
```

Click **Save**

**If playbook dropdown is empty:**
1. Go back to Projects
2. Click **Sync** button on your project
3. Wait for "Successful" status
4. Return to Job Template creation
5. Playbook dropdown should now be populated

**When to refresh:** Never (references are dynamic)

---

## 🔄 Refresh Requirements Reference

| Component | Refresh Needed? | When | How |
|-----------|----------------|------|-----|
| **Credentials** | ❌ Never | Changes are immediate | N/A |
| **Inventories (Static)** | ❌ Never | Changes are immediate | N/A |
| **Inventories (Dynamic)** | ✅ Yes | After cloud source changes | Click **Sync** button |
| **Hosts** | ❌ Never | Changes are immediate | N/A |
| **Projects** | ✅ **Required** | **After creation**<br>After Git push<br>Before template creation | Click **Sync** button<br>Status indicator must show "Successful" |
| **Job Templates** | ❌ Never | References are dynamic | N/A |

---

## 🚀 Running Your First Job

**After configuration is complete:**

1. **Navigate:** Resources → Templates
2. **Find:** "Ping Test" template
3. **Launch:** Click rocket icon (🚀) next to template name
4. **Monitor:** Job execution page shows real-time output
5. **Verify:** Check for "ok=1" on all 4 hosts

**Expected Output:**
```
PLAY [Test Ansible connectivity] *************************************

TASK [Ping all hosts] ************************************************
ok: [ansible1]
ok: [ansible2]
ok: [ansible3]
ok: [ansible5]

PLAY RECAP ***********************************************************
ansible1    : ok=1    changed=0    unreachable=0    failed=0
ansible2    : ok=1    changed=0    unreachable=0    failed=0
ansible3    : ok=1    changed=0    unreachable=0    failed=0
ansible5    : ok=1    changed=0    unreachable=0    failed=0
```

---

## 📝 Configuration Checklist

Use this checklist when setting up AAP:

### Pre-Configuration
- [ ] AAP is running and accessible
- [ ] Login credentials verified (admin/ansible)
- [ ] GitHub repository URL ready
- [ ] Host IP addresses documented

### Configuration Steps
- [ ] **Step 1:** Create Credentials (if needed)
- [ ] **Step 2a:** Create Inventory "Homelab"
- [ ] **Step 2b:** Add host "ansible1" with variables
- [ ] **Step 2c:** Add host "ansible2" with variables
- [ ] **Step 2d:** Add host "ansible3" with variables
- [ ] **Step 2e:** Add host "ansible5" with variables
- [ ] **Step 3a:** Create Project "AAP Playbooks"
- [ ] **Step 3b:** ⚠️ **Sync Project** - Wait for "Successful"
- [ ] **Step 3c:** Verify playbooks downloaded (check Revision field)
- [ ] **Step 4a:** Create Job Template "Ping Test"
- [ ] **Step 4b:** Verify playbook appears in dropdown
- [ ] **Step 4c:** Save job template

### Verification
- [ ] Launch "Ping Test" job template
- [ ] Verify all 4 hosts respond with "ok=1"
- [ ] Check job history shows "Successful"

---

## 🔄 After Making Changes

| Change Made | Action Required | Location |
|-------------|----------------|----------|
| **Modified playbook in GitHub** | 🔄 Sync Project | Resources → Projects → Sync |
| **Added new playbook to GitHub** | 🔄 Sync Project | Resources → Projects → Sync |
| **Changed host IP/credentials** | ✅ Edit directly | Resources → Inventories → Hosts → Edit |
| **Added new host** | ✅ Create host | Resources → Inventories → Hosts → Add |
| **Changed job template settings** | ✅ Edit directly | Resources → Templates → Edit |
| **Updated AAP itself** | 🔄 Restart services | SSH: `systemctl restart automation-controller` |

---

## ⚠️ Common Issues & Solutions

### Issue: Playbook not appearing in dropdown
**Symptoms:** When creating Job Template, playbook dropdown is empty

**Solutions:**
1. Go to Resources → Projects
2. Click **Sync** button next to your project
3. Wait for status to show "Successful"
4. Return to Job Template creation
5. Refresh browser if needed

**Root Cause:** Project hasn't downloaded playbooks from Git yet

---

### Issue: Project sync failed
**Symptoms:** Project status shows "Failed" with red indicator

**Solutions:**
1. Verify GitHub URL is correct and accessible
2. For private repos: Add Git credentials
3. Check network connectivity from ansible5
4. Review sync job output for specific errors

**Common Causes:**
- Incorrect Git URL
- Private repository without credentials
- Network/firewall issues
- Invalid branch name

---

### Issue: Hosts unreachable during job run
**Symptoms:** Job fails with "unreachable" or "failed to connect"

**Solutions:**
1. Verify host variables in Inventory → Hosts
2. Check IP addresses are correct (10.0.0.x network)
3. Verify username/password credentials
4. Test connectivity from ansible5 CLI:
   ```bash
   ansible all -m ping -i /etc/ansible/hosts
   ```

**Common Causes:**
- Wrong IP address
- Incorrect username/password
- Host firewall blocking SSH
- Host powered off

---

### Issue: Permission denied errors
**Symptoms:** Tasks fail with "permission denied" or "sudo required"

**Solutions:**
1. Enable "Privilege Escalation" in Job Template
2. Verify user has sudo permissions on target hosts
3. Add become directives to playbook if needed

**Example playbook with become:**
```yaml
---
- name: Task requiring sudo
  hosts: all
  become: yes
  tasks:
    - name: Install package
      yum:
        name: htop
        state: present
```

---

### Issue: Changes in GitHub not reflected
**Symptoms:** Updated playbook doesn't show changes when run

**Solutions:**
1. Go to Resources → Projects → "AAP Playbooks"
2. Click **Sync** button
3. Wait for "Successful" status
4. Or: Enable "Update Revision on Launch" in project settings

**Prevention:** Enable "Update Revision on Launch" for automatic sync

---

### Issue: Job template won't save
**Symptoms:** Error when saving job template

**Solutions:**
1. Ensure Inventory exists and is selected
2. Ensure Project exists, is synced, and is selected
3. Ensure playbook is selected from dropdown
4. Check for required fields (name, job type)

---

## 📚 Related Documentation

- [AAP Setup Guide](./AAP_SETUP_GUIDE.md) - Comprehensive AAP installation and setup
- [AAP GUI Quickstart](./AAP_GUI_QUICKSTART.md) - Quick reference for GUI configuration
- [Inventory File](./inventory_homelab.ini) - CLI inventory reference
- [Ping Playbook](./ping.yml) - Basic connectivity test playbook

---

## 🔗 External Resources

- [Ansible Automation Platform Documentation](https://docs.ansible.com/automation-controller/latest/)
- [AWX Documentation](https://ansible.readthedocs.io/projects/awx/en/latest/)
- [Ansible Playbook Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

---

## 📊 Configuration Dependencies Diagram

```
┌─────────────────┐
│  Credentials    │ (Optional)
│  (Step 1)       │
└────────┬────────┘
         │
         ├──────────────┐
         │              │
         ▼              ▼
┌─────────────────┐  ┌─────────────────┐
│  Inventories    │  │    Projects     │
│  (Step 2)       │  │    (Step 3)     │
│                 │  │                 │
│  ├─ Hosts       │  │  ⚠️ MUST SYNC   │
│  └─ Variables   │  │  after creation │
└────────┬────────┘  └────────┬────────┘
         │                    │
         └──────────┬─────────┘
                    ▼
         ┌─────────────────────┐
         │   Job Templates     │
         │   (Step 4)          │
         │                     │
         │   Combines:         │
         │   - Inventory       │
         │   - Project         │
         │   - Playbook        │
         │   - Credentials     │
         └──────────┬──────────┘
                    │
                    ▼
         ┌─────────────────────┐
         │   🚀 Launch Job     │
         └─────────────────────┘
```

---

## 🎯 Quick Reference: First-Time Setup

**Minimum configuration to run your first playbook:**

1. **Create Inventory** with hosts (5 minutes)
2. **Create Project** and **sync it** ⚠️ (2 minutes)
3. **Create Job Template** (2 minutes)
4. **Launch Job** (30 seconds)

**Total time: ~10 minutes**

---

**Document Version:** 1.0  
**Last Updated:** February 14, 2026  
**AAP Version:** Based on AWX (Ansible Automation Platform Community)
