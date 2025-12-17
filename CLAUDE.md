# CLAUDE.md - AI Assistant Guide for Ansible Automation Platform Repository

**Last Updated:** 2025-12-17
**Repository:** ansibleautomationplatform
**Primary Use:** Ansible playbooks for infrastructure automation and system administration

---

## Repository Overview

This repository contains Ansible playbooks for managing infrastructure through the Ansible Automation Platform (AAP), accessible at `ansible.codeandcamera.me`. The playbooks automate common system administration tasks including OS updates, web server deployment, package management, and Docker container orchestration.

### Key Information
- **Platform:** Ansible Automation Platform (AAP)
- **Authentication:** Email-based OTP
- **Primary Target Systems:** Ubuntu, Debian, Windows, Arch Linux
- **Default Host Groups:** `myhosts`, `all`, `web`, `garden_servers`

---

## Codebase Structure

```
ansibleautomationplatform/
├── README.md                    # Basic git workflow instructions
├── ai-learning_playbook.yml     # Educational playbook with extensive comments
├── apache.yml                   # Apache installation with static content
├── apache_template.yml          # Apache installation with Jinja2 templates
├── httpd_conf.yml              # Apache configuration management with handlers
├── installgitcurl.yml          # Package installation + Docker garden-agent setup
├── multiOSupdate.yml           # Multi-platform OS update automation
├── ping.yml                    # Simple connectivity test
└── specs.yml                   # System specification gathering
```

### File Organization
- **No subdirectories:** All playbooks are in the root directory
- **No inventory files:** Inventories are managed within AAP platform
- **No templates/files dirs:** Source files referenced in playbooks are expected to exist locally
- **No roles:** All tasks are defined directly in playbooks

---

## Playbook Inventory

### 1. **ai-learning_playbook.yml**
**Purpose:** Educational playbook demonstrating Ansible fundamentals
**Target:** `all` hosts
**Key Features:**
- Extensively commented for learning
- Demonstrates variables, loops, conditionals, facts, and registered variables
- Tests: connectivity, uptime checks, package status verification
- Ubuntu-specific conditional tasks

**Variables:**
- `learning_message`: Custom message variable
- `packages_to_check`: List of packages (git, curl, htop)

**Best For:** Understanding Ansible concepts and AAP basics

---

### 2. **installgitcurl.yml**
**Purpose:** Install git/curl and deploy Docker-based garden-agent project
**Target:** `myhosts` group
**Privilege Escalation:** Yes (`become: true`)

**Key Features:**
- Package installation (git, curl)
- Version validation
- Docker container orchestration
- Environment variable management
- System information display

**Variables:**
- `openai_key`: Retrieved from environment variable `OPENAI_API_KEY`

**Deployment Steps:**
1. Validates OS version
2. Updates apt cache
3. Installs git and curl
4. Validates installations
5. Creates `/opt/garden-agent` directory
6. Copies `main.py`, `Dockerfile`, `docker-compose.yml`
7. Creates `.env` file with OpenAI API key
8. Tears down existing containers
9. Builds and starts new containers

**Dependencies:** Requires local files: `main.py`, `Dockerfile`, `docker-compose.yml`

---

### 3. **multiOSupdate.yml**
**Purpose:** Cross-platform system update automation
**Target:** `all` hosts
**Supported OS:** Windows, Ubuntu/Debian, Arch Linux

**Platform-Specific Behavior:**
- **Windows:** SecurityUpdates, UpdateRollups, CriticalUpdates
- **Ubuntu/Debian:** `apt upgrade dist` with cache update
- **Arch Linux:** Checks `/run/reboot-required`

**Features:**
- Automatic reboot detection and execution
- 600-second reboot timeout
- Conditional execution based on OS family
- Uses `ansible_facts['os_family']` for OS detection

**Note:** Arch Linux update task appears incomplete (no update command before reboot check)

---

### 4. **apache.yml**
**Purpose:** Apache web server installation with static content
**Target:** `myhosts` group
**Privilege Escalation:** Yes

**Tasks:**
1. Install latest httpd package
2. Enable and start httpd service
3. Copy `prod_web.html` to `/var/www/html/index.html`

**Dependencies:** Requires local file `prod_web.html`

---

### 5. **apache_template.yml**
**Purpose:** Apache installation with Jinja2 templating
**Target:** `web` group
**Privilege Escalation:** Yes

**Tasks:**
1. Install latest httpd package
2. Enable and start httpd service
3. Deploy templated HTML using `template_web.html.j2`

**Dependencies:** Requires local template file `template_web.html.j2`

**Note:** Commented out owner/group/mode settings suggest incomplete configuration

---

### 6. **httpd_conf.yml**
**Purpose:** Apache configuration file management
**Target:** `web` group
**Privilege Escalation:** Yes

**Key Features:**
- Uses **handlers** for service management
- Copies `httpd.conf` to `/etc/httpd/conf/`
- Automatically restarts Apache when config changes

**Handler:** `restart_apache` - Restarts httpd service

**Dependencies:** Requires local file `httpd.conf`

---

### 7. **ping.yml**
**Purpose:** Simple connectivity test
**Target:** `all` hosts
**Gather Facts:** No (disabled for speed)
**Privilege Escalation:** Yes

**Use Case:** Quick verification of Ansible connectivity to managed nodes

---

### 8. **specs.yml**
**Purpose:** System specification gathering and reporting
**Target:** `all` hosts
**Gather Facts:** Yes

**Collected Information:**
- CPU details (`ansible_processor`)
- Total RAM (`ansible_memtotal_mb`)
- Disk usage (via `df -h`)
- Network interfaces (`ansible_interfaces`)
- Demonstration of loops (counts to 3)

**Note:** Uses `shell` module for disk info instead of `ansible.builtin.command`

---

## Development Workflows

### Standard Git Workflow (from README.md)

```bash
# Initial setup (once per machine)
git clone https://github.com/jdlocklin-backyard/ansibleautomationplatform.git

# Before working
git pull origin main

# After making changes
git add .
git commit -m "Your message"
git push origin main
```

### AI-Assisted Development Workflow

When working with Claude or other AI assistants:

1. **Feature Branch Naming Convention:**
   - Format: `claude/<descriptive-name>-<session-id>`
   - Example: `claude/add-claude-documentation-twaB3`
   - **Critical:** Branch name MUST start with `claude/` and end with matching session ID

2. **Branch Operations:**
   ```bash
   # Create and switch to feature branch
   git checkout -b claude/<feature-name>-<session-id>

   # Push to remote with tracking
   git push -u origin claude/<feature-name>-<session-id>
   ```

3. **Push Retry Policy:**
   - Retry up to 4 times on network failures
   - Exponential backoff: 2s, 4s, 8s, 16s
   - **Important:** Push will fail with 403 if branch naming convention is violated

4. **Fetch/Pull Operations:**
   - Prefer specific branch fetching: `git fetch origin <branch-name>`
   - Same retry policy applies (4 attempts, exponential backoff)

---

## Key Conventions and Patterns

### 1. **Playbook Structure Standards**

```yaml
---
- name: Descriptive playbook name
  hosts: target_group
  become: true|false
  gather_facts: true|false
  vars:
    variable_name: value
  tasks:
    - name: Clear, descriptive task name
      module.name:
        parameter: value
```

### 2. **Module Preferences**

**Preferred Modules (in order):**
1. `ansible.builtin.*` - Fully qualified module names
2. Built-in modules with short names (existing playbooks use both)
3. Avoid `shell` module unless necessary (use `command` instead)

**Examples from codebase:**
- ✅ `ansible.builtin.ping`, `ansible.builtin.debug`, `ansible.builtin.apt`
- ✅ `copy`, `service`, `debug` (short form, acceptable)
- ⚠️ `shell: df -h` (used in specs.yml, but `command` preferred)

### 3. **Task Naming**

- Use descriptive, action-oriented names
- Good: "Install git", "Update apt package list", "Display connection success"
- Bad: "Task 1", "Run command", "Do thing"

### 4. **Variables and Facts**

**Variable Sources:**
- `vars` section in playbook
- Environment variables via `lookup('env', 'VAR_NAME')`
- Ansible facts: `ansible_distribution`, `ansible_facts.packages`, etc.
- Registered variables from task output

**Naming Conventions:**
- Snake_case: `learning_message`, `openai_key`, `git_version`
- Descriptive suffixes: `_result`, `_info`, `_required`

### 5. **Privilege Escalation**

- Most playbooks use `become: true` for system-level changes
- Only `ping.yml` uses `become: true` for connectivity test (unusual but present)
- Consider whether tasks actually need root privileges

### 6. **Host Groups**

**Current Usage:**
- `all` - Universal target for testing and multi-OS updates
- `myhosts` - Primary target for Ubuntu/Debian systems
- `web` - Web server group
- `garden_servers` - Previously used, now replaced with `myhosts` (see commit history)

**Recent Changes:**
- Commit `703582e`: Changed from `garden_servers` to `myhosts`
- Be aware of host group evolution when modifying playbooks

---

## Best Practices for AI Assistants

### When Creating New Playbooks

1. **Always include:**
   - Descriptive playbook name
   - Clear task names
   - Appropriate `become` setting
   - `gather_facts` set explicitly (true/false)

2. **Variable Management:**
   - Use `vars` section for playbook-specific variables
   - Use environment lookup for sensitive data: `lookup('env', 'VAR_NAME')`
   - Never hardcode secrets

3. **Error Handling:**
   - Use `ignore_errors: yes` sparingly (only seen in docker-compose down)
   - Use `changed_when: false` for read-only commands
   - Register outputs when needed for debugging or conditional logic

4. **Idempotency:**
   - Ensure tasks can run multiple times safely
   - Use `state: present/latest/started` appropriately
   - Consider `changed_when` and `failed_when` conditions

### When Modifying Existing Playbooks

1. **Preserve Structure:**
   - Maintain existing module naming style (fully qualified vs short)
   - Keep task ordering unless there's a reason to change
   - Don't remove comments from `ai-learning_playbook.yml` (educational value)

2. **Host Group Changes:**
   - Verify host group exists in AAP inventory before changing
   - Document reason for host group changes in commit message
   - Check git history for context on previous host group migrations

3. **Dependencies:**
   - Document required local files (templates, configs, source files)
   - Note when tasks expect external resources (Docker, specific packages)
   - Verify file paths are correct for AAP execution context

### When Troubleshooting

1. **Check These First:**
   - Host group definitions in AAP inventory
   - Required local files existence (templates, configs)
   - OS family detection for multi-platform playbooks
   - Privilege escalation requirements

2. **Common Issues:**
   - Missing `become: true` for system-level changes
   - Incorrect host group name
   - Missing source files referenced in `copy` or `template` tasks
   - OS-specific tasks without proper `when` conditions

3. **Debugging Additions:**
   - Add `ansible.builtin.debug` tasks to display variable values
   - Use `register` to capture task output for inspection
   - Add `gather_facts: true` if you need system information

---

## Code Quality Guidelines

### What to Avoid

1. **Over-engineering:**
   - Don't add unnecessary roles or directory structure
   - Keep playbooks simple and direct
   - Don't add features not explicitly requested

2. **Security Issues:**
   - Never commit API keys or secrets
   - Always use environment variables or AAP credentials
   - Validate user input when using variables in shell commands

3. **Breaking Changes:**
   - Don't change host groups without confirmation
   - Don't modify `ai-learning_playbook.yml` structure (it's educational)
   - Don't remove working handlers or notification chains

### What to Encourage

1. **Consistency:**
   - Match existing module naming style in the playbook
   - Follow established variable naming patterns
   - Use similar task structures to existing playbooks

2. **Documentation:**
   - Add comments for complex logic
   - Include purpose in playbook name
   - Document required variables and their sources

3. **Testing:**
   - Test connectivity with `ping.yml` before major changes
   - Use `specs.yml` to verify target system capabilities
   - Start with `check` mode when possible (--check flag in AAP)

---

## Important Context from Commit History

### Recent Changes (Last 15 Commits)

1. **Host Group Evolution:**
   - `703582e`: `garden_servers` → `myhosts`
   - `12b377e`: `myhosts` → `garden_servers` (later reverted)
   - Pattern: Host group names are actively evolving

2. **Docker Garden Agent Project:**
   - `5e322f4`: Added setup tasks for garden-agent
   - `4a8a1b9`: Added OpenAI API key variable
   - `fe0cdcc`: Enhanced with server ping and system info
   - Integration complete in `installgitcurl.yml`

3. **Learning Resources:**
   - `b6dde0e`: Created AI-generated learning playbook
   - Focus on educational content for AAP beginners

4. **Multi-OS Support:**
   - Multiple commits refining `multiOSupdate.yml`
   - Cross-platform update automation is a priority

### Patterns to Continue

- Educational comments in learning materials
- Version validation after package installation
- System info display for verification
- Clean slate approach (tear down before rebuild)

---

## Platform-Specific Notes

### Ansible Automation Platform (AAP)

1. **Inventory Management:**
   - Inventories are managed in AAP web interface
   - Host groups referenced in playbooks must exist in AAP
   - No local inventory files needed

2. **Credential Management:**
   - SSH credentials configured in AAP
   - API keys should use AAP credential system or environment variables
   - Current approach uses `lookup('env', 'VAR_NAME')`

3. **Execution Environment:**
   - Playbooks run in AAP execution environments
   - Source files must be available in AAP project
   - File paths are relative to project directory

### Supported Target Systems

1. **Ubuntu/Debian (Primary):**
   - Most playbooks target Ubuntu
   - Uses `apt` module
   - Checks for `/var/run/reboot-required`

2. **Windows:**
   - Supported in `multiOSupdate.yml`
   - Uses `ansible.windows.*` collection
   - Separate reboot handling

3. **Arch Linux:**
   - Included in multi-OS update playbook
   - Implementation appears incomplete (no update command)

---

## Quick Reference

### Common Tasks

**Test connectivity:**
```bash
ansible-playbook ping.yml
```

**Gather system specs:**
```bash
ansible-playbook specs.yml
```

**Update systems:**
```bash
ansible-playbook multiOSupdate.yml
```

**Deploy Apache:**
```bash
ansible-playbook apache.yml  # Static content
ansible-playbook apache_template.yml  # Templated content
```

### Module Quick Reference

| Task | Module | Example |
|------|--------|---------|
| Test connectivity | `ansible.builtin.ping` | Used in ping.yml:8 |
| Install package | `ansible.builtin.apt` | Used in installgitcurl.yml:15 |
| Debug output | `ansible.builtin.debug` | Used throughout |
| Copy file | `ansible.builtin.copy` | Used in apache.yml:16 |
| Template file | `ansible.builtin.template` | Used in apache_template.yml:16 |
| Run command | `ansible.builtin.command` | Used in installgitcurl.yml:30 |
| Manage service | `ansible.builtin.service` | Used in apache.yml:11 |
| Gather facts | `ansible.builtin.setup` | Used in installgitcurl.yml:50 |

---

## AI Assistant Guidelines Summary

### Do's ✅

- Read existing playbooks before suggesting modifications
- Maintain consistent style with existing code
- Use fully qualified module names (`ansible.builtin.*`) when adding new tasks
- Test changes with simple playbooks first (ping.yml, specs.yml)
- Document variables and their sources
- Use environment variables for sensitive data
- Follow git branch naming: `claude/<name>-<session-id>`
- Commit with descriptive messages matching repository style
- Verify host groups exist before using them

### Don'ts ❌

- Don't commit secrets or API keys
- Don't create unnecessary directory structures or roles
- Don't modify `ai-learning_playbook.yml` educational comments
- Don't change host groups without understanding impact
- Don't use `shell` module when `command` suffices
- Don't add features beyond requirements
- Don't push to branches not matching `claude/*` pattern
- Don't skip error handling for critical tasks
- Don't assume host group names without checking current usage

### When in Doubt

1. Check recent commit history for context
2. Look at similar existing playbooks for patterns
3. Use `ping.yml` to verify connectivity
4. Use `specs.yml` to understand target systems
5. Start with minimal changes and iterate
6. Ask user about host group names or AAP inventory structure

---

## Maintenance Notes

**This document should be updated when:**
- New playbooks are added
- Host group naming conventions change
- AAP platform configuration changes
- New target OS platforms are added
- Major refactoring occurs
- New development patterns emerge

**Document Version:** 1.0
**Created:** 2025-12-17
**Next Review:** When significant repository changes occur

---

*This guide is specifically designed for AI assistants working with this repository. For human developer documentation, see README.md.*
