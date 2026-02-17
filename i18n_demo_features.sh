#!/bin/bash

################################################################################
# i18n Demo Script
# Demonstração do sistema de internacionalização
# Teste as funcionalidades: --lang, CHECKLIST_LINUX_LANG, detecção automática
################################################################################

set -euo pipefail

################################################################################
# Carregar i18n
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
I18N_FILE="${SCRIPT_DIR}/i18n/i18n.sh"

if [[ -f "$I18N_FILE" ]]; then
    source "$I18N_FILE"
    init_i18n "$@"
else
    echo "Error: i18n system not found at ${I18N_FILE}"
    exit 1
fi

################################################################################
# Demonstração
################################################################################

print_header "🌍 Sistema de Internacionalização (i18n)"

echo "Idioma atual: $(get_current_language_name)"
echo ""

# Demonstrar mensagens padronizadas
print_section "Mensagens Padronizadas do Dicionário"
echo ""

print_ok "$MSG_OK - Tudo funcionando"
print_success "$MSG_SUCCESS - Operação completada"
print_info "$MSG_INFO - Informação importante"
print_checking "$MSG_CHECKING - Verificando sistema"
print_warning "$MSG_WARNING - Atenção necessária"
print_critical "$MSG_CRITICAL - Situação crítica"
print_fail "$MSG_FAILED - Operação falhou"

echo ""
print_section "Variáveis de Mensagens Comuns"
echo ""

echo "✓ $MSG_YES / $MSG_NO"
echo "✓ $MSG_CONTINUE / $MSG_CANCEL"
echo "✓ $MSG_LOADING... $MSG_READY"
echo "✓ $MSG_PROCESSING... $MSG_DONE"

echo ""
print_section "Como Testar os Diferentes Modos"
echo ""

cat << EOF
1. Forçar idioma via linha de comando:
   $0 --lang=pt_BR
   $0 --lang=en_US
   $0 --lang=es_ES

2. Usar variável de ambiente:
   CHECKLIST_LINUX_LANG=pt_BR $0
   CHECKLIST_LINUX_LANG=en_US $0

3. Detectar automaticamente do sistema:
   $0  (usará \$LANG ou \$LC_MESSAGES)

4. Idioma atual detectado:
   LANG=$LANG
   CURRENT_LANG=$CURRENT_LANG
EOF

echo ""
print_section "Exemplos de Uso em Scripts"
echo ""

cat << 'EOF'
# Exemplo 1: Mensagens simples
print_success "Configuração aplicada com sucesso"
print_error "Falha ao conectar ao servidor"

# Exemplo 2: Usar variáveis de tradução
echo "$SEC_CHECKING_FIREWALL"
echo "$CORP_MENU_1"
echo "$MSG_CONTINUE..."

# Exemplo 3: Estrutura de menu
print_header "$CORP_TITLE"
print_section "$CORP_SUBTITLE"
echo "1) $CORP_MENU_1"
echo "2) $CORP_MENU_2"
EOF

echo ""
print_success "Demonstração concluída!"
echo ""

# Informação de debug (útil para testes)
if [[ "${DEBUG:-0}" == "1" ]]; then
    print_section "Informações de Debug"
    echo "CLI_LANG: ${CLI_LANG:-não definido}"
    echo "CHECKLIST_LINUX_LANG: ${CHECKLIST_LINUX_LANG:-não definido}"
    echo "LANG: ${LANG:-não definido}"
    echo "LC_MESSAGES: ${LC_MESSAGES:-não definido}"
    echo "CURRENT_LANG: ${CURRENT_LANG:-não definido}"
fi
