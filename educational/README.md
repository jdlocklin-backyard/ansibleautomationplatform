# Ansible Educational Playbooks

A series of 15 hands-on playbooks designed to teach Ansible concepts progressively. Each playbook is heavily commented to explain what's happening and why.

## How to Use These Playbooks

1. **Read the playbook first** - Each file has extensive comments explaining concepts
2. **Run with --check** for dry runs: `ansible-playbook playbook.yml --check`
3. **Run the playbook**: `ansible-playbook educational/XX_playbook_name.yml`
4. **Experiment** - Modify variables and re-run to see what changes

## Prerequisites

- Ansible installed (`pip install ansible`)
- Basic YAML understanding
- Terminal/command line access

## Playbook Curriculum

| # | Playbook | Key Concepts | Your Project Connection |
|---|----------|-------------|------------------------|
| 01 | `01_hello_ansible.yml` | Basic syntax, debug module, variables, Jinja2 filters | Foundation for all playbooks |
| 02 | `02_file_management.yml` | file/copy modules, permissions, stat module | Creating project directories |
| 03 | `03_user_management.yml` | user/group modules, become (sudo), SSH keys | Server access management |
| 04 | `04_package_installation.yml` | apt/package modules, pip, state options | Like your `installgitcurl.yml` |
| 05 | `05_service_control.yml` | service/systemd modules, start/stop/enable | Like your `apache.yml` |
| 06 | `06_template_basics.yml` | Jinja2 templates, dynamic configs | Creating `.env` files |
| 07 | `07_conditionals.yml` | when statements, OS detection, boolean logic | Like your `multiOSupdate.yml` |
| 08 | `08_loops.yml` | loop, with_items, dict2items, loop_control | Batch file operations |
| 09 | `09_handlers.yml` | notify/handlers, flush_handlers | Restart only when needed |
| 10 | `10_docker_basics.yml` | docker modules, docker-compose | Your garden-agent deployment |
| 11 | `11_firewall_rules.yml` | ufw module, port management | Securing your servers |
| 12 | `12_cron_jobs.yml` | cron module, scheduled tasks | Automated maintenance |
| 13 | `13_error_handling.yml` | block/rescue/always, ignore_errors, assert | Graceful failure handling |
| 14 | `14_facts_magic_variables.yml` | ansible_facts, system info, set_fact | OS-specific logic |
| 15 | `15_vault_secrets.yml` | Ansible Vault, encrypting secrets | Securing your OPENAI_API_KEY |

## Quick Start

```bash
# Run on localhost (most playbooks support this)
ansible-playbook educational/01_hello_ansible.yml

# Run on remote hosts (update inventory first)
ansible-playbook educational/04_package_installation.yml -i inventory

# Dry run (check mode)
ansible-playbook educational/03_user_management.yml --check

# Verbose output
ansible-playbook educational/01_hello_ansible.yml -v
```

## Recommended Learning Path

**Week 1 - Basics:**
- 01_hello_ansible.yml
- 02_file_management.yml
- 04_package_installation.yml

**Week 2 - Control Flow:**
- 07_conditionals.yml
- 08_loops.yml
- 09_handlers.yml

**Week 3 - System Administration:**
- 03_user_management.yml
- 05_service_control.yml
- 12_cron_jobs.yml

**Week 4 - Advanced Topics:**
- 06_template_basics.yml
- 10_docker_basics.yml
- 13_error_handling.yml

**Week 5 - Production Ready:**
- 11_firewall_rules.yml
- 14_facts_magic_variables.yml
- 15_vault_secrets.yml

## Key Modules Covered

| Module | Purpose | Playbook |
|--------|---------|----------|
| `debug` | Print messages/variables | 01, all |
| `file` | Manage files/directories | 02 |
| `copy` | Copy files or create with content | 02, 06 |
| `user` | Manage user accounts | 03 |
| `group` | Manage groups | 03 |
| `apt` | Debian/Ubuntu packages | 04 |
| `package` | Cross-platform packages | 04 |
| `service` | Manage services | 05 |
| `systemd` | Systemd-specific features | 05 |
| `template` | Jinja2 templates | 06 |
| `docker_*` | Docker management | 10 |
| `ufw` | Ubuntu firewall | 11 |
| `cron` | Scheduled tasks | 12 |
| `assert` | Validate conditions | 13 |
| `setup` | Gather system facts | 14 |

## Tips for Learning

1. **Read comments carefully** - They explain the "why" not just the "what"
2. **Use --check first** - Especially for user management and firewall rules
3. **Compare to your playbooks** - See how concepts apply to your existing work
4. **Modify and experiment** - Change variables and see what happens
5. **Check the output** - Ansible tells you what changed (and what didn't)

## Connection to Your Projects

These playbooks directly relate to your existing work:

- **garden-agent**: Playbooks 02, 06, 10 cover the deployment pattern
- **installgitcurl.yml**: Playbooks 04, 08 explain package installation
- **multiOSupdate.yml**: Playbook 07 covers OS-specific conditionals
- **apache.yml**: Playbooks 05, 09 cover service management

## Need Help?

- Run `ansible-doc <module>` for module documentation
- Use `-vvv` for very verbose debugging output
- Check Ansible docs: https://docs.ansible.com/

Happy automating!
