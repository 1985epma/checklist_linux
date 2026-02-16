#!/bin/bash

################################################################################
# i18n Demo Script
# Demonstration of the internationalization system
# Author: Everton Araujo
# Version: 1.0
################################################################################

set -euo pipefail

# Load i18n library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/i18n/i18n.sh"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

################################################################################
# Functions
################################################################################

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Main menu demonstration
show_demo_menu() {
    clear
    print_header "$(translate MENU_TITLE)"
    echo ""
    echo "  ${CYAN}1${NC}) $(translate SEC_TITLE)"
    echo "  ${CYAN}2${NC}) $(translate SRV_TITLE)"
    echo "  ${CYAN}3${NC}) $(translate SUDO_TITLE)"
    echo "  ${CYAN}4${NC}) $(translate CORP_TITLE)"
    echo "  ${CYAN}5${NC}) $(translate LANG_SELECT_PROMPT | head -1)"
    echo "  ${CYAN}6${NC}) $(translate MSG_EXIT)"
    echo ""
    read -p "$(translate MENU_SELECT) [1-6]: " choice
    
    case $choice in
        1) demo_security_checklist ;;
        2) demo_service_optimizer ;;
        3) demo_sudo_checker ;;
        4) demo_corporate_sudo ;;
        5) 
            select_language_menu
            show_demo_menu
            ;;
        6) 
            print_success "$(translate MSG_EXIT)..."
            exit 0
            ;;
        *)
            echo "$(translate MENU_INVALID)"
            ;;
    esac
}

# Demo: Security Checklist
demo_security_checklist() {
    clear
    print_header "$(translate SEC_TITLE)"
    echo ""
    print_info "$(translate SEC_SUBTITLE)"
    echo ""
    
    echo "$(translate SEC_CHECKING_UPDATES)..."
    sleep 1
    print_success "$(translate SEC_SYSTEM_UPDATED)"
    echo ""
    
    echo "$(translate SEC_CHECKING_FIREWALL)..."
    sleep 1
    print_success "$(translate SEC_FIREWALL_ACTIVE)"
    echo ""
    
    echo "$(translate SEC_CHECKING_SSH)..."
    sleep 1
    print_success "$(translate SEC_SSH_ROOT_DISABLED)"
    echo ""
    
    echo "$(translate SEC_CHECKING_SERVICES)..."
    sleep 1
    print_success "15 $(translate SRV_SERVICES_FOUND)"
    echo ""
    
    print_success "$(translate SEC_REPORT_GENERATED)"
    echo ""
    
    read -p "$(translate MENU_PRESS_KEY)"
    show_demo_menu
}

# Demo: Service Optimizer
demo_service_optimizer() {
    clear
    print_header "$(translate SRV_TITLE)"
    echo ""
    print_info "$(translate SRV_SUBTITLE)"
    echo ""
    
    echo "$(translate SRV_SELECT_TYPE)"
    echo "  1) $(translate SRV_TYPE_DESKTOP)"
    echo "  2) $(translate SRV_TYPE_SERVER)"
    echo "  3) $(translate SRV_TYPE_CONTAINER)"
    read -p "Option [1-3]: " type_choice
    
    echo ""
    echo "$(translate SRV_ANALYZING)..."
    sleep 1
    print_success "23 $(translate SRV_SERVICES_FOUND)"
    echo ""
    
    print_success "$(translate SRV_OPTIMIZATION_COMPLETE)"
    print_info "$(translate SRV_BACKUP_CREATED)"
    echo ""
    
    read -p "$(translate MENU_PRESS_KEY)"
    show_demo_menu
}

# Demo: Sudo Permissions Checker
demo_sudo_checker() {
    clear
    print_header "$(translate SUDO_TITLE)"
    echo ""
    print_info "$(translate SUDO_SUBTITLE)"
    echo ""
    
    echo "$(translate SUDO_CHECKING_CONFIG)..."
    sleep 1
    print_success "$(translate SUDO_FILE_FOUND)"
    print_success "$(translate SUDO_PERMS_CORRECT)"
    echo ""
    
    echo "$(translate SUDO_CHECKING_USERS)..."
    sleep 1
    print_success "$(translate SUDO_USERS_IN_GROUP): john, maria"
    echo ""
    
    echo "$(translate SUDO_CHECKING_AUTH)..."
    sleep 1
    print_success "$(translate SUDO_NOPASSWD_NONE)"
    echo ""
    
    print_success "$(translate SUDO_REPORT_HTML): sudo_audit.html"
    print_success "$(translate SUDO_REPORT_CSV): sudo_audit.csv"
    echo ""
    
    read -p "$(translate MENU_PRESS_KEY)"
    show_demo_menu
}

# Demo: Corporate Sudo Configurator
demo_corporate_sudo() {
    clear
    print_header "$(translate CORP_TITLE)"
    echo ""
    print_info "$(translate CORP_SUBTITLE)"
    echo ""
    
    echo "  ${CYAN}1${NC}) $(translate CORP_MENU_1)"
    echo "  ${CYAN}2${NC}) $(translate CORP_MENU_2)"
    echo "  ${CYAN}3${NC}) $(translate CORP_MENU_3)"
    echo "  ${CYAN}4${NC}) $(translate CORP_MENU_4)"
    echo "  ${CYAN}5${NC}) $(translate CORP_MENU_5)"
    echo "  ${CYAN}6${NC}) $(translate CORP_MENU_6)"
    echo "  ${CYAN}7${NC}) $(translate MSG_BACK)"
    echo ""
    read -p "$(translate MENU_SELECT) [1-7]: " corp_choice
    
    if [[ "$corp_choice" == "7" ]]; then
        show_demo_menu
        return
    fi
    
    echo ""
    print_success "$(translate CORP_CONFIG_CREATED)"
    print_info "$(translate CORP_BACKUP_CREATED)"
    echo ""
    
    read -p "$(translate MENU_PRESS_KEY)"
    show_demo_menu
}

# Display language information
show_language_info() {
    clear
    print_header "$(translate MSG_INFO)"
    echo ""
    print_info "$(translate SYS_CHECKING)"
    echo ""
    echo "  Current language: $(get_current_language_name) ($CURRENT_LANG)"
    echo ""
    echo "Available languages:"
    list_available_languages | while read -r line; do
        echo "  - $line"
    done
    echo ""
    read -p "$(translate MENU_PRESS_KEY)"
}

################################################################################
# Main
################################################################################

main() {
    # Check if wants language selection menu
    if [[ "${1:-}" == "--select-lang" ]] || [[ "${1:-}" == "-l" ]]; then
        init_i18n false
    else
        # Auto-detect
        init_i18n true
    fi
    
    # Check if language was loaded
    if ! is_language_loaded; then
        echo "Error: Failed to load language"
        exit 1
    fi
    
    # Show language information if requested
    if [[ "${1:-}" == "--info" ]] || [[ "${1:-}" == "-i" ]]; then
        show_language_info
        exit 0
    fi
    
    # Show main menu
    show_demo_menu
}

# Help
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "i18n Demo Script - Demonstration of the internationalization system"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -l, --select-lang    Show language selection menu"
    echo "  -i, --info           Show language information"
    echo "  -h, --help           Show this help"
    echo ""
    echo "Supported languages: pt_BR, en_US, es_ES"
    echo ""
    exit 0
fi

# Execute main
main "$@"
