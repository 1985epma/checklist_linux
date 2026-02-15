#!/bin/bash

################################################################################
# i18n Helper Library
# Sistema de internacionalização para scripts bash
# Suporta: pt_BR, en_US, es_ES
# Versão: 1.0
################################################################################

# Diretório base das traduções
I18N_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Idioma padrão
DEFAULT_LANG="${LANG:-pt_BR}"

# Idioma atual
CURRENT_LANG=""

# Idiomas disponíveis
AVAILABLE_LANGS=("pt_BR" "en_US" "es_ES")

################################################################################
# Funções
################################################################################

# Detectar idioma do sistema
detect_system_language() {
    local sys_lang="${LANG%%.*}"
    sys_lang="${sys_lang//-/_}"
    
    case "$sys_lang" in
        pt_BR|pt)
            echo "pt_BR"
            ;;
        en_US|en)
            echo "en_US"
            ;;
        es_ES|es)
            echo "es_ES"
            ;;
        *)
            echo "pt_BR"  # Padrão
            ;;
    esac
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
init_i18n() {
    local auto_detect="${1:-true}"
    
    if [[ "$auto_detect" == "true" ]]; then
        # Detectar idioma do sistema
        local detected_lang=$(detect_system_language)
        load_language "$detected_lang"
    else
        # Mostrar menu de seleção
        select_language_menu
    fi
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
# Exportar funções
################################################################################

export -f detect_system_language
export -f load_language
export -f select_language_menu
export -f init_i18n
export -f get_current_language_name
export -f is_language_loaded
export -f list_available_languages
export -f translate
export -f t
