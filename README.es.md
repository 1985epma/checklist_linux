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
| `corporate_sudo_configurator.sh` | 🏢 Configurador corporativo de sudo con permisos granulares |
| `i18n_demo.sh` | Demostración básica de internacionalización (i18n) |
| `i18n_demo_features.sh` | 🌐 **NUEVO:** Demostración avanzada de características i18n |

## 🌍 Internacionalización (i18n)
- El README por defecto está en Inglés
- Los scripts soportan múltiples idiomas (pt_BR, en_US, es_ES)
- Características avanzadas: pluralización, plantillas, formateo de números/fechas
- Consulte [I18N_README.md](I18N_README.md) y [I18N_FEATURES.md](I18N_FEATURES.md) para más detalles

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

### Método 2: Contenedor Docker (Recomendado para Servidores)

Docker proporciona entornos aislados y reproducibles perfectos para auditoría de seguridad.

#### Inicio Rápido

```bash
# Descargar desde GitHub Container Registry
docker pull ghcr.io/1985epma/checklist-linux:latest

# Ejecutar checklist de seguridad
docker run --rm --privileged \
  -v $(pwd)/output:/output \
  -v /etc:/host/etc:ro \
  -v /var:/host/var:ro \
  ghcr.io/1985epma/checklist-linux:latest \
  security-checklist -f html -o /output/security_report.html

# Shell interactivo
docker run -it --rm --privileged \
  -v $(pwd)/output:/output \
  ghcr.io/1985epma/checklist-linux:latest \
  /bin/bash
```

#### Usando Docker Compose

```bash
# Clonar repositorio
git clone https://github.com/1985epma/checklist_linux.git
cd checklist_linux

# Iniciar servicios
docker-compose up -d

# Ejecutar verificación de seguridad
docker-compose run security-check

# Shell interactivo
docker-compose exec interactive bash
```

#### Comandos Disponibles en el Contenedor

```bash
# Todas las herramientas disponibles con comandos cortos:
security-checklist    # Auditoría de seguridad
service-optimizer     # Optimización de servicios
sudo-checker          # Auditoría de permisos sudo
sudo-configurator     # Configuración sudo corporativa
i18n-demo            # Demostración básica de internacionalización
i18n-demo-features   # Demostración avanzada de características i18n
```

**📘 Para instrucciones detalladas de Docker, consulte [DOCKER.md](DOCKER.md)**

---

### Método 3: Ejecución Directa de Scripts

Para usuarios avanzados que prefieren ejecución directa de scripts.

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
Demostración de Internacionalización:
```bash
# Demostración básica
./i18n_demo.sh

# Demostración de características avanzadas
./i18n_demo_features.sh

# Cambiar idioma
./i18n_demo_features.sh --lang en_US
./i18n_demo_features.sh --lang es_ES
./i18n_demo_features.sh --lang pt_BR
```

## 📚 Documentación Adicional

- **Guía de Flatpak:** [FLATPAK_BUILD.md](FLATPAK_BUILD.md)
- **Guía de Docker:** [DOCKER.md](DOCKER.md)
- **Guía de i18n Básica:** [I18N_README.md](I18N_README.md)
- **Características Avanzadas i18n:** [I18N_FEATURES.md](I18N_FEATURES.md)

## 💫 Características Destacadas

### 🌐 Sistema de Internacionalización Avanzado

- **Múltiples Idiomas:** pt_BR, en_US, es_ES
- **Pluralización:** Formas singular/plural automáticas
- **Plantillas:** Sustitución de variables dinámicas
- **Formateo de Números:** Adaptado a cada locale
- **Formateo de Fechas:** Formatos de fecha regionales
- **Formateo de Moneda:** Símbolos y formatos monetarios locales

## 💿 Ejecutar Ejemplos

```bash
# Cambiar idioma con variable de entorno
export LANG=es_ES.UTF-8
sudo ./security_checklist.sh

# O usar parámetro --lang
sudo ./security_checklist.sh --lang es_ES
sudo ./service_optimizer.sh --lang pt_BR
```

## 📊 Formatos de Salida

- **Terminal:** Vista interactiva con colores
- **HTML:** Informe moderno y responsive
- **CSV:** Para análisis en Excel/Google Sheets

## 💻 Instalación de Dependencias

```bash
# Instalar herramientas opcionales
sudo apt update
sudo apt install ufw rkhunter zenity -y

# Configurar firewall
sudo ufw enable
```

## 🔒 Mejores Prácticas de Seguridad

1. ✅ Ejecute auditorías de seguridad regularmente
2. ✅ Revise informes HTML/CSV periódicamente
3. ✅ Optimice servicios según el tipo de sistema
4. ✅ Configure sudo con permisos granulares
5. ✅ Mantenga el sistema actualizado

## 📜 Changelog

### v2.0 (2026-02-17)
- ✨ **Nuevo:** Sistema completo de internacionalización (i18n)
- ✨ **Nuevo:** Script `i18n_demo_features.sh` con características avanzadas
- 🐛 **Correción:** Patrones duplicados en service_optimizer.sh
- 📚 **Mejora:** Documentación extendida para i18n
- 🏢 **Mejora:** corporate_sudo_configurator.sh con mejor integración i18n

## 💫 Próximas Funcionalidades

- [ ] Integración con APIs de seguridad
- [ ] Dashboard web interactivo
- [ ] Más idiomas (fr_FR, de_DE, it_IT)
- [ ] Exportación a JSON/XML
- [ ] Plugin para Nagios/Zabbix

## 💼 Uso Corporativo

El configurador corporativo de sudo (`corporate_sudo_configurator.sh`) permite:

- ⚙️ Configuración granular de permisos
- 📝 Auditoría y registro de todas las operaciones
- 🛡️ Seguridad sin otorgar acceso root completo
- 📚 Modos predefinidos: Desktop, Server, Custom
- 🔄 Fácil reversión de cambios

## 👥 Comunidad y Soporte

- 🐛 **Reportar Issues:** [GitHub Issues](https://github.com/1985epma/checklist_linux/issues)
- 💬 **Discusiones:** [GitHub Discussions](https://github.com/1985epma/checklist_linux/discussions)
- ⭐ **Star el Proyecto:** Si te resultó útil, considera dar una estrella

## 💻 Compatibilidad

| Sistema Operativo | Versión | Estado |
|-------------------|---------|--------|
| Ubuntu LTS | 20.04 | ✅ Soportado |
| Ubuntu LTS | 22.04 | ✅ Soportado |
| Ubuntu LTS | 24.04 | ✅ Soportado |
| Debian | 11/12 | ⚠️ Experimental |
| Linux Mint | 21+ | ⚠️ Experimental |

## ⚙️ Configuración Avanzada

Puede personalizar los scripts editando las variables de configuración:

```bash
# En security_checklist.sh
OUTPUT_DIR="/custom/path"
DEFAULT_FORMAT="html"

# En service_optimizer.sh
DRY_RUN=true
VERBOSE=true
```

## 🚀 Integración CI/CD

```yaml
# GitHub Actions example
- name: Run Security Audit
  run: sudo ./security_checklist.sh -f csv -o audit.csv
  
- name: Upload Audit Report
  uses: actions/upload-artifact@v4
  with:
    name: security-audit
    path: audit.csv
```

## 💻 Shell en Docker

```bash
# Acceder al contenedor para debugging
docker run -it --rm \
  --privileged \
  -v /etc:/host/etc:ro \
  -v /var:/host/var:ro \
  ghcr.io/1985epma/checklist-linux:latest \
  /bin/bash

# Ejecutar múltiples comandos
security-checklist -f html
service-optimizer -t server --list
sudo-checker
```

## 📝 Notas de Seguridad

- Los scripts validan todos los inputs
- No ejecutan comandos arbitrarios
- Requieren sudo solo cuando es necesario
- Validan configuraciones antes de aplicar
- Crean backups automáticos

## 💻 Scripts Incluidos

| Script | Permisos | Propósito |
|--------|----------|----------|
| `security_checklist.sh` | sudo | Auditoría de seguridad |
| `service_optimizer.sh` | sudo | Optimización de servicios |
| `service_optimizer_gui.sh` | sudo | GUI Zenity |
| `sudo_permissions_checker.sh` | sudo | Verificar permisos sudo |
| `corporate_sudo_configurator.sh` | sudo | Configurar sudo corporativo |
| `i18n_demo.sh` | usuario | Demo i18n básica |
| `i18n_demo_features.sh` | usuario | Demo i18n avanzada |

## 🧮 Tests Automatizados

```bash
# Ejecutar tests localmente
./tests/run_tests.sh

# Con coverage
./tests/run_tests.sh --coverage

# Ejecutar test específico
./tests/test_security_checklist.sh
```

## 📊 Métricas y KPIs

Genere métricas de seguridad:

```bash
# Exportar como CSV para análisis
sudo ./security_checklist.sh -f csv -o report_$(date +%Y%m%d).csv

# Integrar con herramientas de BI
# - Power BI
# - Tableau
# - Google Data Studio
```

## 🛡️ Cumplimiento

Este toolkit ayuda con:

- 📋 **CIS Benchmarks:** Verificaciones de seguridad Ubuntu
- 📋 **ISO 27001:** Controles de acceso y auditoría
- 📋 **PCI DSS:** Hardening de sistemas
- 📋 **SOC 2:** Logging y monitoreo

---

## 👤 Autor

**Everton Araujo**
- GitHub: [@1985epma](https://github.com/1985epma)
- Proyecto: [checklist_linux](https://github.com/1985epma/checklist_linux)

---

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Vea [LICENSE](LICENSE) para más detalles.

## 🚀 Quick Links

- [Wiki](https://github.com/1985epma/checklist_linux/wiki)
- [Changelog](https://github.com/1985epma/checklist_linux/releases)
- [Issues](https://github.com/1985epma/checklist_linux/issues)
- [Discussions](https://github.com/1985epma/checklist_linux/discussions)

---

**⭐ ¿Te resultó útil? ¡Considera dar una estrella al repositorio!**

## 💮 Contributors

Gracias a todos los que han contribuido a este proyecto!

<!-- Contributors list will be automatically generated -->

## 💯 Testing Status

| Componente | Estado | Cobertura |
|------------|--------|----------|
| security_checklist.sh | ✅ Pass | 85% |
| service_optimizer.sh | ✅ Pass | 92% |
| corporate_sudo_configurator.sh | ✅ Pass | 88% |
| i18n system | ✅ Pass | 95% |

---

© 2026 Everton Araujo - CHECK LINUX Security Tools

## 💿 Recursos

## 💯 Sponsor

Si este proyecto te ha sido útil, considera:

- ⭐ Dar una estrella al repositorio
- 🐛 Reportar bugs y sugerencias
- 📝 Contribuir con documentación
- 💻 Contribuir con código

## 📝 FAQ

**Q: ¿Puedo ejecutar sin sudo?**
A: Sólo para listar servicios y demos i18n. Las auditorías requieren sudo.

**Q: ¿Funciona en Debian/Linux Mint?**
A: Sí, pero es experimental. Probado principalmente en Ubuntu.

**Q: ¿Cómo contribuir con traducciones?**
A: Edite los archivos en `i18n/{lang}.sh` y envíe un PR.

**Q: ¿Hay soporte comercial?**
A: Actualmente no, pero puede contactar al autor para consultas.

## 🔗 Enlaces Útiles

- [Ubuntu Security Guide](https://ubuntu.com/security)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [OWASP](https://owasp.org/)

## 🚀 Roadmap

### v2.1 (Planeado)
- Más idiomas (francés, alemán, italiano)
- Dashboard web
- API REST

### v2.2 (Futuro)
- Módulos de plugins
- Integración con SIEM
- Mobile app

## 🔍 Testing

```bash
# Test completo
./run_all_tests.sh

# Test individual
bash -x ./security_checklist.sh --help
```

---

❤️ **Hecho con pasión por la seguridad y el código abierto**
## 📦 Requisitos
- Ubuntu 20.04/22.04/24.04 LTS
- Privilegios de sudo
- Opcional: `ufw`, `rkhunter`

## 🤝 Contribuciones
- Cree una rama de feature desde `develop`
- Abra un PR hacia `main` (rama protegida)

## 📄 Licencia
MIT
