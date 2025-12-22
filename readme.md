# 🛡️ Security Checklist para Ubuntu Linux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-orange)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)

Script Bash para realizar um checklist básico de segurança em sistemas Ubuntu Linux. Verifica itens essenciais como atualizações, firewall, serviços em execução, contas de usuário, permissões de arquivos e configurações de SSH, gerando um relatório no terminal com recomendações.

## 📋 Descrição

O script foi projetado para ajudar administradores de sistemas, profissionais de DevOps e entusiastas de segurança a identificar potenciais vulnerabilidades ou configurações inadequadas de forma rápida.

> ⚠️ **Importante:** O script **não realiza alterações automáticas** no sistema para evitar riscos. Ele fornece apenas sugestões para ações manuais.

| Informação | Detalhe |
|------------|---------|
| **Autor** | Everton Araujo |
| **Versão** | 1.0 |
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

## 📦 Requisitos

- **Sistema Operacional:** Ubuntu Linux (testado em versões LTS: 20.04, 22.04 e 24.04)
- **Permissões:** Acesso `sudo` para comandos que requerem privilégios elevados
- **Ferramentas opcionais:**
  - `ufw` - Firewall
  - `rkhunter` - Verificação de rootkits

> 💡 Se alguma ferramenta não estiver instalada, o script sugere a instalação automaticamente.

## ⚡ Quick Start - Exportar Relatórios

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

## 🔧 Personalização

Você pode editar o script para adicionar verificações personalizadas conforme sua necessidade:

- Adicionar verificação de portas abertas
- Incluir análise de logs específicos
- Verificar configurações de aplicações específicas

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
