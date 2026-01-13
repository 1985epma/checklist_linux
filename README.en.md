# 🛡️ CHECK LINUX Security Tools

> Language: English · Español: [README.es.md](README.es.md) · Leia em Português (Brasil): [readme.md](readme.md)

[![CI](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml/badge.svg)](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-orange)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)

Toolkit to help secure Ubuntu Linux systems. Includes scripts for security checklist, service optimization, and HTML/CSV audit reports.

## 📋 Overview

This project helps sysadmins, DevOps, and security enthusiasts to:
- Identify potential vulnerabilities
- Optimize system services
- Generate audit reports (HTML/CSV)

> Important: Scripts do not automatically change your system (except Service Optimizer in auto mode).

| Info | Details |
|------|---------|
| Author | Everton Araujo |
| Version | 2.0 |
| Created | Dec 22, 2025 |
| License | MIT |

## ✅ Checks

| Check | Description |
|-------|-------------|
| System Updates | Check upgradable packages via `apt` |
| Firewall (UFW) | Firewall status and rules |
| Running Services | Active services and review suggestions |
| User Accounts | Users with shells and root-like accounts |
| File Permissions | `/etc/passwd`, `/etc/shadow`, `/etc/ssh/sshd_config` |
| SSH Settings | `PermitRootLogin`, `PasswordAuthentication` |
| Malware Scan | `rkhunter` if installed (optional) |

## 🔧 Tools

| Script | Description |
|--------|-------------|
| `security_checklist.sh` | Security checklist with HTML/CSV reports |
| `service_optimizer.sh` | Service optimizer for Desktop/Server/Container |
| `sudo_permissions_checker.sh` | System sudo permissions audit |
| `corporate_sudo_configurator.sh` | Corporate sudo configuration tool |
| `i18n_demo.sh` | Internationalization (i18n) demo |

## 🌍 Internationalization (i18n)
- Default README language is Portuguese (Brazil)
- Scripts support multiple languages (pt_BR, en_US, es_ES)
- See I18N_README.md for details

## ⚡ Quick Start

Security Checklist:
```bash
sudo ./security_checklist.sh
sudo ./security_checklist.sh -f html
sudo ./security_checklist.sh -f csv
```

Service Optimizer:
```bash
sudo ./service_optimizer.sh --help
sudo ./service_optimizer.sh -t desktop -m 1 --dry-run
```

Sudo Audit:
```bash
sudo ./sudo_permissions_checker.sh
```

Corporate Sudo Configurator:
```bash
sudo ./corporate_sudo_configurator.sh
```

## 📦 Requirements
- Ubuntu 20.04/22.04/24.04 LTS
- sudo privileges
- Optional: `ufw`, `rkhunter`

## 🤝 Contributing
- Create a feature branch from `develop`
- Open a PR to `main` (branch is protected)

## 📄 License
MIT
