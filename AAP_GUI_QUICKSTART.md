# AAP GUI Configuration - Quick Reference

> **Date:** February 14, 2026  
> **Status:** Pending manual configuration  
> **Full Guide:** See [AAP_SETUP_GUIDE.md](./AAP_SETUP_GUIDE.md)

---

## Access Information

- **URL:** https://ansible.codeandcamera.me (or https://10.0.0.42)
- **Username:** admin
- **Password:** ansible
- **Backend:** ansible5 (VM 2004) at 10.0.0.42

---

## Configuration Checklist

### ✅ Task 1: Login to AAP
- [ ] Open https://ansible.codeandcamera.me in browser
- [ ] Login with admin/ansible
- [ ] Verify dashboard loads

### ✅ Task 2: Create Inventory

**Navigation:** Resources → Inventories → Add

**Settings:**
- **Name:** Homelab
- **Organization:** Default
- **Type:** Inventory

**Add Hosts (click "Hosts" tab after creating inventory):**

| Host Name | Variables |
|-----------|-----------|
| ansible1 | `ansible_host: 10.0.0.116`<br>`ansible_user: ansible`<br>`ansible_password: ansible` |
| ansible2 | `ansible_host: 10.0.0.168`<br>`ansible_user: ansible`<br>`ansible_password: ansible` |
| ansible3 | `ansible_host: 10.0.0.194`<br>`ansible_user: ansible`<br>`ansible_password: ansible` |
| ansible5 | `ansible_host: 10.0.0.42`<br>`ansible_user: root`<br>`ansible_password: root123` |

**Format for each host (YAML):**
```yaml
ansible_host: 10.0.0.XXX
ansible_user: ansible
ansible_password: ansible
```

### ✅ Task 3: Create Project

**Navigation:** Resources → Projects → Add

**Settings:**
- **Name:** AAP Playbooks
- **Organization:** Default
- **SCM Type:** Git
- **SCM URL:** https://github.com/yourusername/ansibleautomationplatform.git
  - ⚠️ **Replace with your actual GitHub repo URL!**
- **SCM Branch:** main
- **Update on Launch:** ✓ (checked)

**Note:** If repository is private, you'll need to add credentials. For public repos, leave credentials blank.

### ✅ Task 4: Create Job Template

**Navigation:** Resources → Templates → Add → Add job template

**Settings:**
- **Name:** Ping Test
- **Job Type:** Run
- **Inventory:** Homelab (select from dropdown)
- **Project:** AAP Playbooks (select from dropdown)
- **Playbook:** ping.yml (select from dropdown)
- **Credentials:** Leave blank (using inventory host variables)
- **Options:**
  - ✓ Enable Privilege Escalation (if needed)
  - ✓ Enable Fact Storage (optional)

### ✅ Task 5: Run Job Template

**Navigation:** Resources → Templates → Ping Test → Launch (🚀 icon)

**Expected Result:**
```
PLAY [Test Ansible connectivity] **********************

TASK [Ping all hosts] *********************************
ok: [ansible1]
ok: [ansible2]
ok: [ansible3]
ok: [ansible5]

PLAY RECAP ********************************************
ansible1    : ok=1    changed=0    unreachable=0    failed=0
ansible2    : ok=1    changed=0    unreachable=0    failed=0
ansible3    : ok=1    changed=0    unreachable=0    failed=0
ansible5    : ok=1    changed=0    unreachable=0    failed=0
```

---

## Troubleshooting

### Issue: Hosts unreachable
- **Cause:** Incorrect IP address or credentials
- **Fix:** Edit host variables in inventory

### Issue: Playbook not found
- **Cause:** Project not synced or wrong branch
- **Fix:** Update project (Resources → Projects → AAP Playbooks → Sync)

### Issue: Permission denied
- **Cause:** Wrong user/password in host variables
- **Fix:** Verify credentials match:
  - ansible1-3: ansible/ansible
  - ansible5: root/root123

### Issue: Project sync fails
- **Cause:** Invalid GitHub URL or private repo without credentials
- **Fix:** Verify GitHub URL is correct and accessible

---

## Post-Configuration

After successful ping test:

1. Take screenshot of successful job run
2. Note any errors or warnings
3. Report back completion status

---

## Next Steps (After GUI Configuration)

- [ ] Create additional job templates for other playbooks
- [ ] Set up scheduled jobs (if needed)
- [ ] Configure notifications (optional)
- [ ] Document final AAP setup in homelab repository
- [ ] Get IPs for ansible4 and ansible6 (enable guest agents)

---

**Reference:** Full detailed instructions in [AAP_SETUP_GUIDE.md](./AAP_SETUP_GUIDE.md)
