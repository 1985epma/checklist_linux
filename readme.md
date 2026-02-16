# 🛡️ CHECK LINUX Security Tools

> 🌍 Language: English (default) · Português (Brasil): [README.pt-br.md](README.pt-br.md) · Español: [README.es.md](README.es.md)

[![CI](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml/badge.svg)](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-orange)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)

Toolkit to help secure Ubuntu Linux systems. Includes scripts for security checklist, service optimization, and HTML/CSV audit reports.

## 📋 Overview

This project helps sysadmins, DevOps, and security enthusiasts to:
- Identify potential vulnerabilities
- Optimize system services
- Generate audit reports

> ⚠️ **Important:** Scripts **do not automatically change** your system to avoid risks (except Service Optimizer in auto mode).

| Info | Details |
|------|---------|
| **Author** | Everton Araujo |
| **Version** | 2.0 |
| **Created** | December 22, 2025 |
| **License** | MIT |

## ✅ Security Checks

| Check | Description |
|-------|-------------|
| 🔄 **System Updates** | Check upgradable packages via `apt` |
| 🔥 **Firewall (UFW)** | Firewall status and rules |
| ⚙️ **Running Services** | List active services and suggests review |
| 👤 **User Accounts** | Identifies users with shell and root-like accounts |
| 📁 **File Permissions** | Check `/etc/passwd`, `/etc/shadow` and `/etc/ssh/sshd_config` |
| 🔐 **SSH Configuration** | Analyze `PermitRootLogin` and `PasswordAuthentication` |
| 🦠 **Malware Scan** | Uses `rkhunter` if installed (optional) |

## 🔧 Available Tools

| Script | Description |
|--------|-------------|
| `security_checklist.sh` | Security checklist with HTML/CSV reports |
| `service_optimizer.sh` | Service optimizer for Desktop/Server/Container |
| `service_optimizer_gui.sh` | 🖥️ GUI version of optimizer (Zenity) |
| `sudo_permissions_checker.sh` | System sudo permissions audit |
| `corporate_sudo_configurator.sh` | Corporate sudo configuration tool |
| `i18n_demo.sh` | Internationalization (i18n) demo |


> 🌍 **New:** Internationalization system available! Scripts support multiple languages (pt_BR, en_US, es_ES). See [I18N_README.md](I18N_README.md) for details.

## 📦 Requirements

- **Operating System:** Ubuntu Linux (tested on LTS versions: 20.04, 22.04 and 24.04)
- **Permissions:** `sudo` access for commands that require elevated privileges
- **Optional tools:**
  - `ufw` - Firewall
  - `rkhunter` - Rootkit detection

> 💡 If any tool is not installed, the script will suggest installation automatically.

---

## 📦 Installation Methods

### Method 1: Flatpak (Recommended for Desktop Users)

Flatpak provides a sandboxed, distribution-independent way to install and run CHECK LINUX Security Tools.

#### Quick Install

```bash
# Install from local build
./build-flatpak.sh

# Or build and install in one command
flatpak-builder --user --install --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
```

#### Requirements

```bash
# Install Flatpak and flatpak-builder
sudo apt install flatpak flatpak-builder

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install runtime
flatpak install flathub org.freedesktop.Platform//23.08
flatpak install flathub org.freedesktop.Sdk//23.08
```

#### Running the Flatpak

```bash
# Launch from application menu or run:
flatpak run com.github._1985epma.ChecklistLinux

# Run specific tools
flatpak run --command=security-checklist com.github._1985epma.ChecklistLinux
flatpak run --command=service-optimizer com.github._1985epma.ChecklistLinux
```

#### Distribution

Create a distributable bundle:
```bash
./build-flatpak.sh bundle
# or
flatpak-builder --repo=repo --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
flatpak build-bundle repo checklist-linux.flatpak com.github._1985epma.ChecklistLinux
```

**📘 For detailed Flatpak instructions, see [FLATPAK_BUILD.md](FLATPAK_BUILD.md)**

---

### Method 2: Direct Script Execution

For servers or advanced users who prefer direct script execution:

---

## ⚡ Security Checklist - Quick Start

```bash
# Run in terminal (default)
sudo ./security_checklist.sh

# Export to HTML
sudo ./security_checklist.sh -f html

# Export to CSV
sudo ./security_checklist.sh -f csv

# Export with custom name
sudo ./security_checklist.sh -f html -o security_report.html
sudo ./security_checklist.sh -f csv -o audit.csv
```

## 🚀 Installation and Usage

### 1. Clone the repository

```bash
git clone https://github.com/your-user/checklist_linux.git
cd checklist_linux
```

### 2. Make the script executable

```bash
chmod +x security_checklist.sh
```

### 3. Run the script

```bash
# Terminal output (default)
sudo ./security_checklist.sh

# Generate HTML report
sudo ./security_checklist.sh -f html

# Generate CSV report
sudo ./security_checklist.sh -f csv

# Specify output file name
sudo ./security_checklist.sh -f html -o my_report.html
sudo ./security_checklist.sh --format csv --output security_audit.csv
```

### Available options

| Option | Description |
|--------|-------------|
| `-f, --format` | Output format: `terminal` (default), `html`, `csv` |
| `-o, --output` | Output file name |
| `-h, --help` | Show help |

## 📊 Sample Output (Terminal)

```
╔══════════════════════════════════════════════════════════════╗
║      🛡️  SECURITY CHECKLIST - UBUNTU LINUX  🛡️              ║
╚══════════════════════════════════════════════════════════════╝

📅 Date/Time: Sat Dec 21 2025 10:30:00 -03
🖥️  Hostname: my-server
🐧 System: Ubuntu 24.04 LTS

══════════════════════════════════════════════════════════════

📁 System
────────────────────────────────────────
  ✅ OK | Updates
      └─ System up to date

📁 Firewall
────────────────────────────────────────
  ✅ OK | UFW
      └─ Active with 5 rules

...

📊 SUMMARY
  ✅ OK: 12 | ⚠️  Warnings: 2 | ❌ Critical: 0 | ℹ️  Info: 4
```

## 📄 HTML Report

The HTML report generates a modern and responsive page with:
- Colored summary cards
- Tables organized by category
- Status with colors (OK green, Warning yellow, Critical red)
- Professional dark mode design

![HTML Report Preview](https://via.placeholder.com/800x400?text=HTML+Report+Preview)

## 📑 CSV Report

The CSV report can be opened in Excel, Google Sheets or any analysis tool:

```csv
Category,Item,Status,Description,Recommendation,Date,Hostname,System
"System","Updates","OK","System up to date","-","Sat Dec 21 2025","server","Ubuntu 24.04"
"Firewall","UFW","OK","Active with 5 rules","-","Sat Dec 21 2025","server","Ubuntu 24.04"
```

---

## 🔧 Service Optimizer - Service Optimization Tool

Script to disable unnecessary services based on system type.

### System Types

| Type | Description |
|------|-------------|
| 🖥️ **Desktop** | Removes web servers, DB, containers if not using |
| 🖧 **Server** | Removes GUI, sound, bluetooth, etc. |
| 📦 **Container** | Removes systemd, udev, cron, ssh, etc. |

### Operation Modes

| Mode | Description |
|------|-------------|
| ⚡ **1 - Automatic** | Disables all recommended services automatically |
| 🔧 **2 - Advanced** | Select categories (DB, Web, Audio, etc.) |
| 💬 **3 - Interactive** | Asks for each service individually |

### Usage Examples

```bash
# Make executable
chmod +x service_optimizer.sh

# Interactive mode (menu)
sudo ./service_optimizer.sh

# Desktop - Automatic mode
sudo ./service_optimizer.sh -t desktop -m 1

# Server - Interactive mode
sudo ./service_optimizer.sh -t server -m 3

# Container - Advanced mode
sudo ./service_optimizer.sh -t container -m 2

# Simulate without making changes (dry-run)
sudo ./service_optimizer.sh -t desktop -m 1 --dry-run

# List services only
./service_optimizer.sh --list -t server
```

### Available Options

| Option | Description |
|--------|-------------|
| `-t, --type` | Type: `desktop`, `server`, `container` |
| `-m, --mode` | Mode: `1` (auto), `2` (advanced), `3` (interactive) |
| `-d, --dry-run` | Simulate without making changes |
| `-l, --list` | List services without executing |
| `-h, --help` | Show help |

### Services by Category

<details>
<summary>🖥️ Desktop - Removable services</summary>

- **Servers:** apache2, nginx, mysql, postgresql, mongodb, redis
- **Containers:** docker, containerd, lxd, snapd
- **Printing:** cups (if not using printer)
- **Bluetooth:** bluetooth (if not using)
- **Network:** avahi-daemon, smbd, nfs-server
- **Others:** ModemManager, fwupd, apport

</details>

<details>
<summary>🖧 Server - Removable services</summary>

- **GUI:** gdm, lightdm, gnome-shell, plasmashell
- **Audio:** pulseaudio, pipewire, alsa
- **Bluetooth:** bluetooth
- **Desktop:** colord, tracker, geoclue, gvfs
- **Reports:** apport, whoopsie, kerneloops

</details>

<details>
<summary>📦 Container - Removable services</summary>

- **Systemd:** journald, udevd, logind, resolved
- **Hardware:** udev, thermald, irqbalance
- **Network:** NetworkManager, wpa_supplicant
- **Cron:** cron, anacron, atd
- **SSH:** sshd (use docker exec)

</details>

---

## 🔐 Sudo Permissions Checker - Permissions Audit

Script to audit and verify current sudo permission settings on the system.

```bash
# Run complete verification
sudo ./sudo_permissions_checker.sh

# Check specific user
sudo ./sudo_permissions_checker.sh -u username

# Generate report to file
sudo ./sudo_permissions_checker.sh -o sudo_report.txt

# Verbose mode
sudo ./sudo_permissions_checker.sh -v
```

### Checks Performed

✅ Users with sudo access
✅ Configured sudoers groups
✅ Passwordless sudo rules (NOPASSWD)
✅ Defined command aliases
✅ Allowed command patterns
✅ Analysis of dangerous configurations

---

## 🏢 Sudo Corporate Config - Corporate Configuration

Interactive script to create a secure sudo configuration suitable for corporate environments.

```bash
# Interactive mode
sudo ./corporate_sudo_configurator.sh

# Automatic mode (Desktop)
sudo ./corporate_sudo_configurator.sh -m desktop

# Automatic mode (Server)
sudo ./corporate_sudo_configurator.sh -m server

# Apply with automatic backup
sudo ./corporate_sudo_configurator.sh -m desktop -b

# View changes without applying (dry-run)
sudo ./corporate_sudo_configurator.sh -m desktop --dry-run
```

### Available Options

| Option | Description |
|--------|-------------|
| `-m, --mode` | `desktop`, `server` or `custom` |
| `-u, --user` | User to add to sudoers |
| `-b, --backup` | Create automatic backup of sudoers |
| `--dry-run` | Simulate changes without applying |
| `-v, --verbose` | Verbose mode |
| `-h, --help` | Show help |

### Available Modes

#### 🖥️ Desktop Mode
- ✅ User can run apt/snap/flatpak
- ✅ Can read and execute utility scripts
- ✅ Access to network commands (ifconfig, systemctl)
- ❌ No access to critical system files
- ❌ No command runs without password
- ❌ No direct shell access as root

#### 🖧 Server Mode
- ✅ Service management control
- ✅ Permission to update packages
- ✅ System logs and monitoring
- ✅ Backup and restoration
- ❌ No editing of critical files
- ❌ All operations require confirmation
- ❌ No access to sudo -i (root shell)

#### ⚙️ Custom Mode
- Allows selecting specific permissions
- Granular configuration per user
- Add multiple users
- Define custom allowed commands

### Configuration Structure

Configurations are created in `/etc/sudoers.d/`:

```bash
/etc/sudoers.d/user_apt_snap      # Permissions for apt/snap/flatpak
/etc/sudoers.d/user_file_ops      # File reading and execution
/etc/sudoers.d/user_system_mgmt   # System management
```

### Security

✅ No operations executed as direct root
✅ Logging of all sudo operations
✅ Requires password for most commands
✅ Configurations validated before applying
✅ Automatic backup of original sudoers
✅ Easy rollback in case of error

---

## 🔧 Customization

You can edit the script to add custom checks according to your needs:

- Add open port verification
- Include specific log analysis
- Check specific application configurations

## 🔄 CI/CD

This project uses **GitHub Actions** for continuous integration:

| Job | Description |
|-----|-------------|
| 🔍 **Lint** | Validates script with ShellCheck |
| 🧪 **Test** | Tests options and exports |
| 🚀 **Release** | Creates automatic releases (with `[release]` in commit) |

### Creating a Release

To create a new release automatically, include `[release]` in the commit message:

```bash
git commit -m "New feature [release]"
git push origin main
```

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/new-check`)
3. Commit your changes (`git commit -m 'Add new check'`)
4. Push to the branch (`git push origin feature/new-check`)
5. Open a Pull Request

## 📄 License

This project is under the MIT license. See the [LICENSE](LICENSE) file for more details.

---

**⭐ If this project was useful, consider giving it a star on the repository!**
