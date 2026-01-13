# 🛡️ CHECK LINUX Security Tools

> 🌍 Idioma: PT-BR (padrão) · Read this in English: [README.en.md](README.en.md)

[![CI](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml/badge.svg)](https://github.com/1985epma/checklist_linux/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-orange)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)

Conjunto de ferramentas de segurança para sistemas Ubuntu Linux. Inclui scripts para checklist de segurança, otimização de serviços e geração de relatórios em HTML/CSV.

## 📋 Descrição

Este projeto oferece ferramentas para ajudar administradores de sistemas, profissionais de DevOps e entusiastas de segurança a:
- Identificar potenciais vulnerabilidades
- Otimizar serviços do sistema
- Gerar relatórios de auditoria

> ⚠️ **Importante:** Os scripts **não realizam alterações automáticas** no sistema para evitar riscos (exceto o Service Optimizer em modo automático).

| Informação | Detalhe |
|------------|---------|
| **Autor** | Everton Araujo |
| **Versão** | 2.0 |
| **Data de Criação** | 22 de dezembro de 2025 |
| **Licença** | MIT |

## ✅ Recursos Verificados

| Verificação | Descrição |
|-------------|-----------|
| 🔄 **Atualizações do Sistema** | Verifica pacotes atualizáveis via `apt` |
| 🔥 **Firewall (UFW)** | Checa status e regras do firewall |
| ⚙️ **Serviços em Execução** | Lista serviços ativos e sugere revisão |
| 👤 **Contas de Usuário** | Identifica usuários com shell e contas root-like |
| 📁 **Permissões de Arquivos** | Verifica `/etc/passwd`, `/etc/shadow` e `/etc/ssh/sshd_config` |
| 🔐 **Configurações de SSH** | Analisa `PermitRootLogin` e `PasswordAuthentication` |
| 🦠 **Verificação de Malware** | Usa `rkhunter` se instalado (opcional) |

## 🔧 Ferramentas Disponíveis

| Script | Descrição |
|--------|-----------|
| `security_checklist.sh` | Checklist de segurança com relatórios HTML/CSV |
| `service_optimizer.sh` | Otimizador de serviços para Desktop/Servidor/Container |
| `sudo_permissions_checker.sh` | Verificação de permissões sudo do sistema |
| `sudo_corporate_config.sh` | Configurador de sudo corporativo seguro |
| `i18n_demo.sh` | Demonstração do sistema de internacionalização (i18n) |


> 🌍 **Novo:** Sistema de internacionalização disponível! Os scripts suportam múltiplos idiomas (pt_BR, en_US, es_ES). Veja [I18N_README.md](I18N_README.md) para detalhes.

## 📦 Requisitos

- **Sistema Operacional:** Ubuntu Linux (testado em versões LTS: 20.04, 22.04 e 24.04)
- **Permissões:** Acesso `sudo` para comandos que requerem privilégios elevados
- **Ferramentas opcionais:**
  - `ufw` - Firewall
  - `rkhunter` - Verificação de rootkits

> 💡 Se alguma ferramenta não estiver instalada, o script sugere a instalação automaticamente.

---

## ⚡ Security Checklist - Quick Start

```bash
# Executar no terminal (padrão)
sudo ./security_checklist.sh

# Exportar para HTML
sudo ./security_checklist.sh -f html

# Exportar para CSV
sudo ./security_checklist.sh -f csv

# Exportar com nome personalizado
sudo ./security_checklist.sh -f html -o relatorio_seguranca.html
sudo ./security_checklist.sh -f csv -o auditoria.csv
```

## 🚀 Instalação e Uso

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/checklist_linux.git
cd checklist_linux
```

### 2. Torne o script executável

```bash
chmod +x security_checklist.sh
```

### 3. Execute o script

```bash
# Saída no terminal (padrão)
sudo ./security_checklist.sh

# Gerar relatório HTML
sudo ./security_checklist.sh -f html

# Gerar relatório CSV
sudo ./security_checklist.sh -f csv

# Especificar nome do arquivo de saída
sudo ./security_checklist.sh -f html -o meu_relatorio.html
sudo ./security_checklist.sh --format csv --output security_audit.csv
```

### Opções disponíveis

| Opção | Descrição |
|-------|-----------|
| `-f, --format` | Formato de saída: `terminal` (padrão), `html`, `csv` |
| `-o, --output` | Nome do arquivo de saída |
| `-h, --help` | Mostrar ajuda |

## 📊 Exemplo de Saída (Terminal)

```
╔══════════════════════════════════════════════════════════════╗
║      🛡️  CHECKLIST DE SEGURANÇA - UBUNTU LINUX  🛡️           ║
╚══════════════════════════════════════════════════════════════╝

📅 Data/Hora: Sáb 21 Dez 2025 10:30:00 -03
🖥️  Hostname: meu-servidor
🐧 Sistema: Ubuntu 24.04 LTS

══════════════════════════════════════════════════════════════

📁 Sistema
────────────────────────────────────────
  ✅ OK | Atualizações
      └─ Sistema atualizado

📁 Firewall
────────────────────────────────────────
  ✅ OK | UFW
      └─ Ativo com 5 regras

...

📊 RESUMO
  ✅ OK: 12 | ⚠️  Avisos: 2 | ❌ Críticos: 0 | ℹ️  Info: 4
```

## 📄 Relatório HTML

O relatório HTML gera uma página moderna e responsiva com:
- Cards de resumo coloridos
- Tabelas organizadas por categoria
- Status com cores (OK verde, Warning amarelo, Critical vermelho)
- Design dark mode profissional

![HTML Report Preview](https://via.placeholder.com/800x400?text=HTML+Report+Preview)

## 📑 Relatório CSV

O relatório CSV pode ser aberto no Excel, Google Sheets ou qualquer ferramenta de análise:

```csv
Categoria,Item,Status,Descrição,Recomendação,Data,Hostname,Sistema
"Sistema","Atualizações","OK","Sistema atualizado","-","Sáb 21 Dez 2025","servidor","Ubuntu 24.04"
"Firewall","UFW","OK","Ativo com 5 regras","-","Sáb 21 Dez 2025","servidor","Ubuntu 24.04"
```

---

## 🔧 Service Optimizer - Otimizador de Serviços

Script para desativar serviços desnecessários baseado no tipo de sistema.

### Tipos de Sistema

| Tipo | Descrição |
|------|-----------|
| 🖥️ **Desktop** | Remove servidores web, BD, containers se não usar |
| 🖧 **Servidor** | Remove interface gráfica, som, bluetooth, etc. |
| 📦 **Container** | Remove systemd, udev, cron, ssh, etc. |

### Modos de Operação

| Modo | Descrição |
|------|-----------|
| ⚡ **1 - Automático** | Desativa todos os serviços recomendados automaticamente |
| 🔧 **2 - Avançado** | Seleciona categorias (BD, Web, Audio, etc.) |
| 💬 **3 - Interativo** | Pergunta para cada serviço individualmente |

### Exemplos de Uso

```bash
# Tornar executável
chmod +x service_optimizer.sh

# Modo interativo (menu)
sudo ./service_optimizer.sh

# Desktop - Modo automático
sudo ./service_optimizer.sh -t desktop -m 1

# Servidor - Modo interativo
sudo ./service_optimizer.sh -t server -m 3

# Container - Modo avançado
sudo ./service_optimizer.sh -t container -m 2

# Simular sem fazer alterações (dry-run)
sudo ./service_optimizer.sh -t desktop -m 1 --dry-run

# Apenas listar serviços
./service_optimizer.sh --list -t server
```

### Opções Disponíveis

| Opção | Descrição |
|-------|-----------|
| `-t, --type` | Tipo: `desktop`, `server`, `container` |
| `-m, --mode` | Modo: `1` (auto), `2` (avançado), `3` (interativo) |
| `-d, --dry-run` | Simular sem fazer alterações |
| `-l, --list` | Listar serviços sem executar |
| `-h, --help` | Mostrar ajuda |

### Serviços por Categoria

<details>
<summary>🖥️ Desktop - Serviços removíveis</summary>

- **Servidores:** apache2, nginx, mysql, postgresql, mongodb, redis
- **Containers:** docker, containerd, lxd, snapd
- **Impressão:** cups (se não usar impressora)
- **Bluetooth:** bluetooth (se não usar)
- **Rede:** avahi-daemon, smbd, nfs-server
- **Outros:** ModemManager, fwupd, apport

</details>

<details>
<summary>🖧 Servidor - Serviços removíveis</summary>

- **GUI:** gdm, lightdm, gnome-shell, plasmashell
- **Áudio:** pulseaudio, pipewire, alsa
- **Bluetooth:** bluetooth
- **Desktop:** colord, tracker, geoclue, gvfs
- **Relatórios:** apport, whoopsie, kerneloops

</details>

<details>
<summary>📦 Container - Serviços removíveis</summary>

- **Systemd:** journald, udevd, logind, resolved
- **Hardware:** udev, thermald, irqbalance
- **Rede:** NetworkManager, wpa_supplicant
- **Cron:** cron, anacron, atd
- **SSH:** sshd (use docker exec)

</details>

---

---

## 🔐 Sudo Permissions Checker - Verificação de Permissões

Script para auditar e verificar as configurações atuais de permissões sudo no sistema.

```bash
# Executar verificação completa
sudo ./sudo_permissions_checker.sh

# Verificar usuário específico
sudo ./sudo_permissions_checker.sh -u username

# Gerar relatório em arquivo
sudo ./sudo_permissions_checker.sh -o relatorio_sudo.txt

# Modo detalhado
sudo ./sudo_permissions_checker.sh -v
```

### Verificações Realizadas

✅ Usuários com acesso sudo
✅ Grupos sudoers configurados
✅ Regras sudo sem senha (NOPASSWD)
✅ Aliases de comando definidos
✅ Padrões de comando permitidos
✅ Análise de configurações perigosas

---

## 🏢 Sudo Corporate Config - Configuração Corporativa

Script interativo para criar uma configuração sudo segura e adequada para ambientes corporativos.

```bash
# Modo interativo
sudo ./sudo_corporate_config.sh

# Modo automático (Desktop)
sudo ./sudo_corporate_config.sh -m desktop

# Modo automático (Servidor)
sudo ./sudo_corporate_config.sh -m server

# Aplicar com backup automático
sudo ./sudo_corporate_config.sh -m desktop -b

# Visualizar mudanças sem aplicar (dry-run)
sudo ./sudo_corporate_config.sh -m desktop --dry-run
```

### Opções Disponíveis

| Opção | Descrição |
|-------|-----------|
| `-m, --mode` | `desktop`, `server` ou `custom` |
| `-u, --user` | Usuário para adicionar aos sudoers |
| `-b, --backup` | Criar backup automático do sudoers |
| `--dry-run` | Simular mudanças sem aplicar |
| `-v, --verbose` | Modo detalhado |
| `-h, --help` | Mostrar ajuda |

### Modos Disponíveis

#### 🖥️ Desktop Mode
- ✅ Usuário pode executar apt/snap/flatpak
- ✅ Pode ler e executar scripts de utilidade
- ✅ Acesso a comandos de rede (ifconfig, systemctl)
- ❌ Sem acesso a arquivos do sistema críticos
- ❌ Nenhum comando é executado sem senha
- ❌ Sem acesso direto a shell como root

#### 🖧 Server Mode
- ✅ Controle de gerenciamento de serviços
- ✅ Permissão para atualizar pacotes
- ✅ Logs e monitoramento de sistema
- ✅ Backup e restauração
- ❌ Sem edição de arquivos críticos
- ❌ Todas as operações requerem confirmação
- ❌ Sem acesso a sudo -i (shell root)

#### ⚙️ Custom Mode
- Permite selecionar permissões específicas
- Configuração granular por usuário
- Adicionar múltiplos usuários
- Definir comandos permitidos customizados

### Estrutura de Configuração

As configurações são criadas em `/etc/sudoers.d/`:

```bash
/etc/sudoers.d/user_apt_snap      # Permissões para apt/snap/flatpak
/etc/sudoers.d/user_file_ops      # Leitura e execução de arquivos
/etc/sudoers.d/user_system_mgmt   # Gerenciamento de sistema
```

### Segurança

✅ Nenhuma operação é executada como root direto
✅ Logging de todas as operações sudo
✅ Requer senha para a maioria dos comandos
✅ Configurações validadas antes de aplicar
✅ Backup automático do sudoers original
✅ Reversão fácil em caso de erro

---

## 🔧 Personalização

Você pode editar o script para adicionar verificações personalizadas conforme sua necessidade:

- Adicionar verificação de portas abertas
- Incluir análise de logs específicos
- Verificar configurações de aplicações específicas

## 🔄 CI/CD

Este projeto utiliza **GitHub Actions** para integração contínua:

| Job | Descrição |
|-----|-----------|
| 🔍 **Lint** | Valida o script com ShellCheck |
| 🧪 **Test** | Testa as opções e exportações |
| 🚀 **Release** | Cria releases automáticas (com `[release]` no commit) |

### Criar uma Release

Para criar uma nova release automaticamente, inclua `[release]` na mensagem do commit:

```bash
git commit -m "Nova funcionalidade [release]"
git push origin main
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer um fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/nova-verificacao`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova verificação'`)
4. Push para a branch (`git push origin feature/nova-verificacao`)
5. Abrir um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**⭐ Se este projeto foi útil, considere dar uma estrela no repositório!**
