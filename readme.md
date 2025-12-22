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
sudo ./security_checklist.sh
```

## 📊 Exemplo de Saída

```
=== Checklist de Segurança no Ubuntu Linux ===
Data/Hora: Sáb 21 Dez 2025 10:30:00 -03
Hostname: meu-servidor
Versão do Ubuntu: Ubuntu 24.04 LTS

1. Atualizações do Sistema:
  - Sistema atualizado.

2. Firewall (UFW):
  - Ativo. Regras atuais:
    Status: active
    ...

3. Serviços em Execução:
  - Lista de serviços ativos (top 10):
    ...

...

=== Fim do Checklist ===
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
