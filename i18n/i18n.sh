#!/bin/bash

################################################################################
# i18n Helper Library
# Sistema de internacionalização para scripts bash
# Suporta: pt_BR, en_US, es_ES
# Versão: 2.0
################################################################################

# Diretório base das traduções
I18N_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Idioma padrão (fallback)
DEFAULT_LANG="en_US"

# Idioma atual
CURRENT_LANG=""

# Idiomas disponíveis
AVAILABLE_LANGS=("pt_BR" "en_US" "es_ES")

# Flag de idioma via linha de comando (--lang)
CLI_LANG=""

################################################################################
# Funções de Detecção de Idioma
################################################################################

# Detectar idioma do sistema via LANG/LC_MESSAGES
detect_system_language() {
    # Prioridade: LC_MESSAGES > LANG
    local sys_lang="${LC_MESSAGES:-${LANG}}"
    sys_lang="${sys_lang%%.*}"
    sys_lang="${sys_lang//-/_}"
    
    case "$sys_lang" in
        pt_BR|pt)
            echo "pt_BR"
            ;;
        en_US|en|C|POSIX)
            echo "en_US"
            ;;
        es_ES|es)
            echo "es_ES"
            ;;
        *)
            echo "$DEFAULT_LANG"  # Fallback para en_US
            ;;
    esac
}

# Processar argumentos de linha de comando para detectar --lang
parse_language_args() {
    for arg in "$@"; do
        case "$arg" in
            --lang=*)
                CLI_LANG="${arg#*=}"
                ;;
            --lang)
                # Próximo argumento é o idioma
                local next=false
                for a in "$@"; do
                    if $next; then
                        CLI_LANG="$a"
                        break
                    fi
                    [[ "$a" == "--lang" ]] && next=true
                done
                ;;
        esac
    done
}

# Determinar idioma com base na ordem de prioridade
# 1. --lang (linha de comando)
# 2. CHECKLIST_LINUX_LANG (variável de ambiente)
# 3. LANG/LC_MESSAGES (sistema)
# 4. en_US (fallback)
determine_language() {
    local detected_lang=""
    
    # 1. --lang tem prioridade máxima
    if [[ -n "$CLI_LANG" ]]; then
        detected_lang="$CLI_LANG"
    # 2. Variável de ambiente CHECKLIST_LINUX_LANG
    elif [[ -n "${CHECKLIST_LINUX_LANG:-}" ]]; then
        detected_lang="$CHECKLIST_LINUX_LANG"
    # 3. Detectar do sistema (LANG/LC_MESSAGES)
    else
        detected_lang=$(detect_system_language)
    fi
    
    # Normalizar o nome do idioma
    detected_lang="${detected_lang//-/_}"
    
    # Validar se o idioma está disponível
    if [[ " ${AVAILABLE_LANGS[*]} " =~ " ${detected_lang} " ]]; then
        echo "$detected_lang"
    else
        echo "$DEFAULT_LANG"
    fi
}

# Carregar arquivo de tradução
load_language() {
    local lang="$1"
    local lang_file="${I18N_DIR}/${lang}.sh"
    
    if [[ -f "$lang_file" ]]; then
        source "$lang_file"
        CURRENT_LANG="$lang"
        return 0
    else
        echo "Erro: Arquivo de idioma não encontrado: $lang_file" >&2
        return 1
    fi
}

# Mostrar menu de seleção de idioma
select_language_menu() {
    clear
    echo "════════════════════════════════════════"
    echo " Select language / Seleccione idioma"
    echo " Selecione o idioma"
    echo "════════════════════════════════════════"
    echo ""
    echo "  1) Português (Brasil)"
    echo "  2) English (United States)"
    echo "  3) Español (España)"
    echo ""
    read -p "Opção / Option / Opción [1-3]: " choice
    
    case $choice in
        1)
            load_language "pt_BR"
            ;;
        2)
            load_language "en_US"
            ;;
        3)
            load_language "es_ES"
            ;;
        *)
            echo "Opção inválida / Invalid option / Opción inválida"
            return 1
            ;;
    esac
}

# Inicializar i18n
# Uso: init_i18n "$@"  (passar todos os argumentos do script)
# Ou:   init_i18n --auto
# Ou:   init_i18n --menu
init_i18n() {
    local mode="auto"
    
    # Se recebeu argumentos, processar para detectar --lang
    if [[ $# -gt 0 ]]; then
        # Verificar se é modo manual
        if [[ "$1" == "--menu" ]]; then
            select_language_menu
            return $?
        fi
        
        # Processar argumentos para detectar --lang
        parse_language_args "$@"
    fi
    
    # Determinar idioma com base na ordem de prioridade
    local detected_lang=$(determine_language)
    
    # Carregar o idioma detectado
    load_language "$detected_lang"
}

# Obter nome do idioma atual
get_current_language_name() {
    echo "${LANG_NAME:-Unknown}"
}

# Verificar se idioma está carregado
is_language_loaded() {
    [[ -n "$CURRENT_LANG" ]]
}

# Listar idiomas disponíveis
list_available_languages() {
    for lang in "${AVAILABLE_LANGS[@]}"; do
        local lang_file="${I18N_DIR}/${lang}.sh"
        if [[ -f "$lang_file" ]]; then
            source "$lang_file"
            echo "$lang: $LANG_NAME"
        fi
    done
}

# Traduzir mensagem (fallback para inglês se não encontrar)
translate() {
    local key="$1"
    local value="${!key}"
    
    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$key"
    fi
}

# Alias para translate
t() {
    translate "$@"
}

################################################################################
# Funções Helper para Mensagens Padronizadas
################################################################################

# Cores para output
if [[ -t 1 ]]; then
    I18N_RED='\033[0;31m'
    I18N_GREEN='\033[0;32m'
    I18N_YELLOW='\033[1;33m'
    I18N_BLUE='\033[0;34m'
    I18N_CYAN='\033[0;36m'
    I18N_WHITE='\033[1;37m'
    I18N_NC='\033[0m'
else
    I18N_RED=''
    I18N_GREEN=''
    I18N_YELLOW=''
    I18N_BLUE=''
    I18N_CYAN=''
    I18N_WHITE=''
    I18N_NC=''
fi

# Imprimir mensagem OK (sucesso)
print_ok() {
    local message="${1:-}"
    echo -e "${I18N_GREEN}[${MSG_OK}]${I18N_NC} ${message}"
}

# Imprimir mensagem de erro
print_error() {
    local message="${1:-}"
    echo -e "${I18N_RED}[${MSG_ERROR}]${I18N_NC} ${message}" >&2
}

# Imprimir mensagem de warning (aviso)
print_warning() {
    local message="${1:-}"
    echo -e "${I18N_YELLOW}[${MSG_WARNING}]${I18N_NC} ${message}"
}

# Imprimir mensagem crítica
print_critical() {
    local message="${1:-}"
    echo -e "${I18N_RED}[${MSG_CRITICAL}]${I18N_NC} ${message}" >&2
}

# Imprimir mensagem informativa
print_info() {
    local message="${1:-}"
    echo -e "${I18N_BLUE}[${MSG_INFO}]${I18N_NC} ${message}"
}

# Imprimir status de verificação
print_checking() {
    local message="${1:-}"
    echo -e "${I18N_CYAN}[${MSG_CHECKING}]${I18N_NC} ${message}"
}

# Imprimir mensagem de sucesso com ícone
print_success() {
    local message="${1:-}"
    echo -e "${I18N_GREEN}✓${I18N_NC} ${message}"
}

# Imprimir mensagem de falha com ícone
print_fail() {
    local message="${1:-}"
    echo -e "${I18N_RED}✗${I18N_NC} ${message}" >&2
}

# Imprimir cabeçalho
print_header() {
    local message="${1:-}"
    echo -e "\n${I18N_BLUE}═══════════════════════════════════════════${I18N_NC}"
    echo -e "${I18N_BLUE}${message}${I18N_NC}"
    echo -e "${I18N_BLUE}═══════════════════════════════════════════${I18N_NC}\n"
}

# Imprimir seção
print_section() {
    local message="${1:-}"
    echo -e "\n${I18N_CYAN}→ ${message}${I18N_NC}"
}

################################################################################
# Exportar funções
################################################################################

export -f detect_system_language
export -f parse_language_args
export -f determine_language
export -f load_language
export -f select_language_menu
export -f init_i18n
export -f get_current_language_name
export -f is_language_loaded
export -f list_available_languages
export -f translate
export -f t
export -f print_ok
export -f print_error
export -f print_warning
export -f print_critical
export -f print_info
export -f print_checking
export -f print_success
export -f print_fail
export -f print_header
export -f print_section
