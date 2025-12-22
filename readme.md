# Script de Checklist de Segurança para Ubuntu Linux

Este repositório contém um script Bash simples para realizar um checklist básico de segurança em sistemas Ubuntu Linux. O script verifica itens essenciais como atualizações, firewall, serviços em execução, contas de usuário, permissões de arquivos e configurações de SSH, gerando um relatório no terminal com recomendações.

## Descrição

O script é projetado para ajudar administradores de sistemas, profissionais de DevOps e entusiastas de segurança a identificar potenciais vulnerabilidades ou configurações inadequadas de forma rápida. Ele **não realiza alterações automáticas** no sistema para evitar riscos; em vez disso, fornece sugestões para ações manuais.

**Versão:** 1.0  
**Data de Criação:** 22 de dezembro de 2025  
**Licença:** MIT (ou use como preferir; sinta-se à vontade para modificar)

## Recursos Verificados

- **Atualizações do Sistema:** Verifica pacotes atualizáveis via `apt`.
- **Firewall (UFW):** Checa status e regras.
- **Serviços em Execução:** Lista serviços ativos e sugere revisão.
- **Contas de Usuário:** Identifica usuários com shell e contas root-like.
- **Permissões de Arquivos Críticos:** Verifica arquivos como `/etc/passwd`, `/etc/shadow` e `/etc/ssh/sshd_config`.
- **Configurações de SSH:** Analisa opções como `PermitRootLogin` e `PasswordAuthentication`.
- **Verificação de Malware:** Usa `rkhunter` se instalado (opcional).

## Requisitos

- Ubuntu Linux (testado em versões LTS como 20.04, 22.04 e 24.04).
- Acesso sudo para comandos que requerem privilégios elevados.
- Ferramentas opcionais: `ufw` (firewall), `rkhunter` (para verificação de rootkits).

Se alguma ferramenta não estiver instalada, o script sugere a instalação.

## Instalação e Uso

1. **Baixe o Script:**
   - Clone este repositório ou copie o código para um arquivo chamado `security_checklist.sh`.

2. **Torne Executável:**

