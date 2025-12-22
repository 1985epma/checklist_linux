#!/bin/bash

# Script de Checklist de Segurança para Ubuntu Linux
# Autor: Grok 4 (gerado por xAI)
# Data: 2025-12-22

echo "=== Checklist de Segurança no Ubuntu Linux ==="
echo "Data/Hora: $(date)"
echo "Hostname: $(hostname)"
echo "Versão do Ubuntu: $(lsb_release -ds)"
echo ""

# 1. Verificar atualizações disponíveis
echo "1. Atualizações do Sistema:"
sudo apt update > /dev/null 2>&1
UPDATES=$(apt list --upgradable 2>/dev/null | grep -c '/')
if [ $UPDATES -gt 0 ]; then
    echo "  - Há $UPDATES pacotes atualizáveis. Recomendação: Execute 'sudo apt upgrade'."
else
    echo "  - Sistema atualizado."
fi
echo ""

# 2. Status do Firewall (UFW)
echo "2. Firewall (UFW):"
if ! command -v ufw &> /dev/null; then
    echo "  - UFW não instalado. Recomendação: Instale com 'sudo apt install ufw'."
else
    STATUS=$(sudo ufw status | grep Status | awk '{print $2}')
    if [ "$STATUS" = "active" ]; then
        echo "  - Ativo. Regras atuais:"
        sudo ufw status verbose | sed 's/^/    /'
    else
        echo "  - Inativo. Recomendação: Ative com 'sudo ufw enable'."
    fi
fi
echo ""

# 3. Serviços em execução (verificar serviços comuns desnecessários)
echo "3. Serviços em Execução:"
echo "  - Lista de serviços ativos (top 10):"
systemctl list-units --type=service --state=running | head -n 11 | sed 's/^/    /'
echo "  - Verifique serviços desnecessários (ex: telnet, ftp). Pare com 'sudo systemctl stop <serviço>'."
echo ""

# 4. Contas de Usuário
echo "4. Contas de Usuário:"
echo "  - Usuários com shell de login:"
awk -F: '$7 ~ /\/bin\/(bash|sh)$/{print $1}' /etc/passwd | sed 's/^/    - /'
echo "  - Usuários com UID 0 (root-like):"
awk -F: '($3 == 0) {print $1}' /etc/passwd | sed 's/^/    - /'
echo "  - Recomendação: Remova contas desnecessárias e use senhas fortes."
echo ""

# 5. Permissões de Arquivos Críticos
echo "5. Permissões de Arquivos Críticos:"
check_permissions() {
    FILE=$1
    EXPECTED=$2
    if [ -f "$FILE" ]; then
        PERMS=$(stat -c "%a" "$FILE")
        if [ "$PERMS" != "$EXPECTED" ]; then
            echo "  - $FILE: Permissões atuais $PERMS (esperado: $EXPECTED). Ajuste com 'sudo chmod $EXPECTED $FILE'."
        else
            echo "  - $FILE: Permissões OK ($EXPECTED)."
        fi
    else
        echo "  - $FILE: Não encontrado."
    fi
}
check_permissions "/etc/passwd" "644"
check_permissions "/etc/shadow" "600"  # ou 640 dependendo da config
check_permissions "/etc/ssh/sshd_config" "600"
echo ""

# 6. Configurações Básicas de SSH
echo "6. SSH (se instalado):"
if [ -f /etc/ssh/sshd_config ]; then
    PERMIT_ROOT=$(grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
    if [ "$PERMIT_ROOT" = "yes" ]; then
        echo "  - PermitRootLogin: yes (Inseguro! Mude para 'no' em /etc/ssh/sshd_config e reinicie SSH)."
    else
        echo "  - PermitRootLogin: $PERMIT_ROOT (OK)."
    fi
    PASSWORD_AUTH=$(grep "^PasswordAuthentication" /etc/ssh/sshd_config | awk '{print $2}')
    if [ "$PASSWORD_AUTH" = "yes" ]; then
        echo "  - PasswordAuthentication: yes (Considere desabilitar e usar chaves SSH)."
    else
        echo "  - PasswordAuthentication: $PASSWORD_AUTH (OK)."
    fi
else
    echo "  - SSH não parece instalado."
fi
echo ""

# 7. Verificar por Malware Básico (usando rkhunter se instalado)
echo "7. Verificação de Malware:"
if command -v rkhunter &> /dev/null; then
    echo "  - Executando rkhunter (resumo):"
    sudo rkhunter --check --skip-keypress --quiet | grep -i warning | sed 's/^/    /'
else
    echo "  - rkhunter não instalado. Recomendação: Instale com 'sudo apt install rkhunter' e execute 'sudo rkhunter --check'."
fi
echo ""

echo "=== Fim do Checklist ==="
echo "Recomendações Gerais: Mantenha o sistema atualizado, use autenticação de dois fatores e monitore logs com 'journalctl'."

