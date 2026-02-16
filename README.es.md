# 🛡️ CHECK LINUX Security Tools

> Idioma: Español · Read in English: [readme.md](readme.md) · Leia em Português (Brasil): [README.pt-br.md](README.pt-br.md)

[![CI](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml/badge.svg)](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml)
[![Licencia: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-orange)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)

Conjunto de herramientas de seguridad para sistemas Ubuntu Linux. Incluye scripts para checklist de seguridad, optimización de servicios y generación de informes en HTML/CSV.

## 📋 Descripción

Este proyecto ayuda a administradores de sistemas, profesionales de DevOps y entusiastas de seguridad a:
- Identificar vulnerabilidades potenciales
- Optimizar servicios del sistema
- Generar informes de auditoría

> Importante: Los scripts no realizan cambios automáticos en el sistema (excepto Service Optimizer en modo automático).

| Información | Detalle |
|-------------|---------|
| Autor | Everton Araujo |
| Versión | 2.0 |
| Fecha de creación | 22 de diciembre de 2025 |
| Licencia | MIT |

## ✅ Verificaciones Incluidas

| Verificación | Descripción |
|--------------|-------------|
| Actualizaciones del Sistema | Verifica paquetes actualizables vía `apt` |
| Firewall (UFW) | Estado y reglas del firewall |
| Servicios en Ejecución | Servicios activos y recomendaciones |
| Cuentas de Usuario | Usuarios con shell y cuentas tipo root |
| Permisos de Archivos | `/etc/passwd`, `/etc/shadow`, `/etc/ssh/sshd_config` |
| Configuración de SSH | `PermitRootLogin`, `PasswordAuthentication` |
| Análisis de Malware | `rkhunter` si está instalado (opcional) |

## 🔧 Herramientas

| Script | Descripción |
|--------|-------------|
| `security_checklist.sh` | Checklist de seguridad con informes HTML/CSV |
| `service_optimizer.sh` | Optimizador de servicios para Desktop/Server/Container |
| `service_optimizer_gui.sh` | 🖥️ Versión GUI del optimizador (Zenity) |
| `sudo_permissions_checker.sh` | Auditoría de permisos sudo del sistema |
| `corporate_sudo_configurator.sh` | Configurador corporativo de sudo |
| `i18n_demo.sh` | Demostración del sistema de internacionalización (i18n) |

## 🌍 Internacionalización (i18n)
- El README por defecto está en Inglés
- Los scripts soportan múltiples idiomas (pt_BR, en_US, es_ES)
- Consulte I18N_README.md para más detalles

## 📦 Métodos de Instalación

### Método 1: Flatpak (Recomendado para Usuarios de Escritorio)

Flatpak proporciona una forma aislada e independiente de la distribución para instalar y ejecutar CHECK LINUX Security Tools.

#### Instalación Rápida

```bash
# Instalar desde build local
./build-flatpak.sh

# O construir e instalar en un comando
flatpak-builder --user --install --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
```

#### Requisitos

```bash
# Instalar Flatpak y flatpak-builder
sudo apt install flatpak flatpak-builder

# Agregar repositorio Flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Instalar runtime
flatpak install flathub org.freedesktop.Platform//23.08
flatpak install flathub org.freedesktop.Sdk//23.08
```

#### Ejecutar el Flatpak

```bash
# Iniciar desde el menú de aplicaciones o ejecutar:
flatpak run com.github._1985epma.ChecklistLinux

# Ejecutar herramientas específicas
flatpak run --command=security-checklist com.github._1985epma.ChecklistLinux
flatpak run --command=service-optimizer com.github._1985epma.ChecklistLinux
```

**📘 Para instrucciones detalladas de Flatpak, consulte [FLATPAK_BUILD.md](FLATPAK_BUILD.md)**

---

### Método 2: Ejecución Directa de Scripts

Para servidores o usuarios avanzados que prefieren ejecución directa de scripts.

---

## ⚡ Inicio Rápido

Checklist de Seguridad:
```bash
sudo ./security_checklist.sh
sudo ./security_checklist.sh -f html
sudo ./security_checklist.sh -f csv
```

Optimizador de Servicios:
```bash
sudo ./service_optimizer.sh --help
sudo ./service_optimizer.sh -t desktop -m 1 --dry-run
```

Auditoría de Sudo:
```bash
sudo ./sudo_permissions_checker.sh
```

Configurador Corporativo de Sudo:
```bash
sudo ./corporate_sudo_configurator.sh
```

## 📦 Requisitos
- Ubuntu 20.04/22.04/24.04 LTS
- Privilegios de sudo
- Opcional: `ufw`, `rkhunter`

## 🤝 Contribuciones
- Cree una rama de feature desde `develop`
- Abra un PR hacia `main` (rama protegida)

## 📄 Licencia
MIT
