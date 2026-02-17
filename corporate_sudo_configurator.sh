#!/bin/bash

################################################################################
# CORPORATE SUDO CONFIGURATOR
# Script to configure sudo appropriate for corporate environment
# Without root privileges, with granular permission control
# Author: Everton Araujo
# Version: 2.0
# Date: 2026-02-16
################################################################################

set -euo pipefail

################################################################################
# Internationalization (i18n)
################################################################################

# Detectar diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
I18N_FILE="${SCRIPT_DIR}/i18n/i18n.sh"

# Carregar sistema de i18n
if [[ -f "$I18N_FILE" ]]; then
    source "$I18N_FILE"
    init_i18n "$@"
else
    echo "Error: i18n system not found at ${I18N_FILE}"
    exit 1
fi

################################################################################
# Variables
################################################################################

SUDOERS_DIR="/etc/sudoers.d"
BACKUP_DIR="/root/sudo_backups"
CURRENT_USER="${SUDO_USER:-$(whoami)}"

################################################################################
# Utility Functions
################################################################################

# Verificar se está rodando como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "$SYS_REQUIRES_SUDO"
        exit 1
    fi
}

# Criar backup dos sudoers
create_backup() {
    mkdir -p "${BACKUP_DIR}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/sudoers_backup_${timestamp}"
    
    if [[ -f /etc/sudoers ]]; then
        cp /etc/sudoers "${backup_file}"
        chmod 600 "${backup_file}"
        print_success "${CORP_BACKUP_CREATED}: ${backup_file}"
    fi
}

# Validar arquivo sudoers
validate_sudoers() {
    if ! sudo -l -f "$1" > /dev/null 2>&1; then
        print_warning "${CORP_CONFIG_FAILED}: $1"
        return 1
    fi
    return 0
}

################################################################################
# Main Menu
################################################################################

show_main_menu() {
    clear
    print_header "$CORP_TITLE"
    echo ""
    echo "$CORP_SUBTITLE"
    echo ""
    echo "  ${I18N_CYAN}1${I18N_NC}) $CORP_MENU_1"
    echo "  ${I18N_CYAN}2${I18N_NC}) $CORP_MENU_2"
    echo "  ${I18N_CYAN}3${I18N_NC}) $CORP_MENU_3"
    echo "  ${I18N_CYAN}4${I18N_NC}) $CORP_MENU_4"
    echo "  ${I18N_CYAN}5${I18N_NC}) $CORP_MENU_5"
    echo "  ${I18N_CYAN}6${I18N_NC}) $CORP_MENU_6"
    echo "  ${I18N_CYAN}7${I18N_NC}) $CORP_MENU_7"
    echo ""
    read -p "$MENU_SELECT [1-7]: " choice
}

################################################################################
# Option 1: File Reader
################################################################################

setup_file_reader() {
    print_header "📁 $CORP_MENU_1"
    echo ""
    
    read -p "$CORP_SELECT_USER [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "$CORP_USER_NOT_EXIST: $user"
        return 1
    fi
    
    read -p "$CORP_SELECT_DIRS [/home /opt /srv]: " dirs
    dirs=${dirs:-"/home /opt /srv"}
    
    print_section "${MSG_CHECKING}: $user"
    print_info "$CORP_SELECT_DIRS: $dirs"
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_files"
    
    cat > "${config_file}" << EOF
# Sudo configuration for file reading/execution
# User: $user
# Date: $(date)

# Script reading and execution
$user ALL=(ALL) NOPASSWD: /usr/bin/cat /home/*
$user ALL=(ALL) NOPASSWD: /usr/bin/tail /home/*
$user ALL=(ALL) NOPASSWD: /usr/bin/find /home -type f
$user ALL=(ALL) NOPASSWD: /usr/bin/grep -r * /home/*
$user ALL=(ALL) NOPASSWD: /bin/bash /home/*/scripts/*
$user ALL=(ALL) NOPASSWD: /bin/sh /home/*/scripts/*

# Permission to list directories
$user ALL=(ALL) NOPASSWD: /bin/ls /home
$user ALL=(ALL) NOPASSWD: /bin/ls /opt
$user ALL=(ALL) NOPASSWD: /bin/ls /srv

# Permission verification
$user ALL=(ALL) NOPASSWD: /bin/stat /home/*
$user ALL=(ALL) NOPASSWD: /usr/bin/file /home/*
EOF
    
    chmod 440 "${config_file}"
    
    if validate_sudoers "${config_file}"; then
        print_success "$CORP_CONFIG_CREATED"
        print_info "${FILE_CREATED}: ${config_file}"
    else
        print_error "$CORP_CONFIG_FAILED"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Option 2: Package Manager
################################################################################

setup_package_manager() {
    print_header "📦 Configure Sudo for Package Manager"
    echo ""
    
    read -p "Which user do you want to configure? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "User $user does not exist"
        return 1
    fi
    
    echo "Which managers to allow?"
    echo "  ${CYAN}1${NC}) APT (Debian/Ubuntu)"
    echo "  ${CYAN}2${NC}) Snap"
    echo "  ${CYAN}3${NC}) Flatpak"
    echo "  ${CYAN}4${NC}) All"
    read -p "Choose [1-4]: " pkg_choice
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_packages"
    
    cat > "${config_file}" << EOF
# Sudo configuration for package manager
# User: $user
# Date: $(date)

# Activities allowed without password
Defaults:$user !requiretty
Defaults:$user log_output

EOF
    
    case $pkg_choice in
        1|4)
            cat >> "${config_file}" << 'EOF'
# APT Permissions
$user ALL=(ALL) NOPASSWD: /usr/bin/apt update
$user ALL=(ALL) NOPASSWD: /usr/bin/apt upgrade
$user ALL=(ALL) NOPASSWD: /usr/bin/apt install
$user ALL=(ALL) NOPASSWD: /usr/bin/apt remove
$user ALL=(ALL) NOPASSWD: /usr/bin/apt search
$user ALL=(ALL) NOPASSWD: /usr/bin/apt-get update
$user ALL=(ALL) NOPASSWD: /usr/bin/apt-get upgrade
$user ALL=(ALL) NOPASSWD: /usr/bin/apt-cache
EOF
            ;;
    esac
    
    case $pkg_choice in
        2|4)
            cat >> "${config_file}" << 'EOF'
# Snap Permissions
$user ALL=(ALL) NOPASSWD: /usr/bin/snap install
$user ALL=(ALL) NOPASSWD: /usr/bin/snap remove
$user ALL=(ALL) NOPASSWD: /usr/bin/snap update
$user ALL=(ALL) NOPASSWD: /usr/bin/snap search
$user ALL=(ALL) NOPASSWD: /usr/bin/snap list
EOF
            ;;
    esac
    
    case $pkg_choice in
        3|4)
            cat >> "${config_file}" << 'EOF'
# Flatpak Permissions
$user ALL=(ALL) NOPASSWD: /usr/bin/flatpak install
$user ALL=(ALL) NOPASSWD: /usr/bin/flatpak remove
$user ALL=(ALL) NOPASSWD: /usr/bin/flatpak update
$user ALL=(ALL) NOPASSWD: /usr/bin/flatpak search
$user ALL=(ALL) NOPASSWD: /usr/bin/flatpak list
EOF
            ;;
    esac
    
    chmod 440 "${config_file}"
    
    if validate_sudoers "${config_file}"; then
        print_success "Package configuration created!"
        print_info "File: ${config_file}"
    else
        print_error "Validation failed"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Option 3: Complete Sudo (Without Root)
################################################################################

setup_complete_sudo() {
    print_header "🚀 Configure Complete Sudo (Without root privileges)"
    echo ""
    print_warning "This configuration is powerful. Use with caution!"
    echo ""
    
    read -p "Which user do you want to configure? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "User $user does not exist"
        return 1
    fi
    
    read -p "Allow executing ALL commands without password? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        print_info "Operation cancelled"
        return 0
    fi
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_complete"
    
    cat > "${config_file}" << EOF
# Complete sudo configuration for $user
# WARNING: This user has virtually unlimited access
# Date: $(date)

# Does not require tty for sudo commands
Defaults:$user !requiretty

# Logging of all executed commands
Defaults:$user log_output
Defaults:$user log_input

# Execute all commands without asking password
$user ALL=(ALL) NOPASSWD: ALL

# Exception: Critical commands that ALWAYS require confirmation
# $user ALL=(ALL) PASSWD: /usr/bin/passwd
# $user ALL=(ALL) PASSWD: /sbin/shutdown
# $user ALL=(ALL) PASSWD: /sbin/reboot
EOF
    
    chmod 440 "${config_file}"
    
    if validate_sudoers "${config_file}"; then
        print_success "Complete configuration created!"
        print_warning "Remember: This user can execute any command!"
        print_info "File: ${config_file}"
    else
        print_error "Validation failed"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Option 4: Custom Configuration
################################################################################

setup_custom() {
    print_header "⚙️ Configure Custom Sudoers"
    echo ""
    
    read -p "Which user do you want to configure? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "User $user does not exist"
        return 1
    fi
    
    read -p "Configuration name: " config_name
    config_name=${config_name//[^a-zA-Z0-9_]/}
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_${config_name}"
    
    print_section "Edit the configuration (save and exit to confirm):"
    print_info "Use the editor to add rules. Example:"
    echo "    $user ALL=(ALL) NOPASSWD: /usr/bin/docker"
    echo "    $user ALL=(ALL) NOPASSWD: /usr/bin/systemctl"
    echo ""
    
    # Initial template
    cat > "${config_file}" << EOF
# Custom configuration for $user
# Date: $(date)
# Edit the lines below with the desired commands

# Example:
# $user ALL=(ALL) NOPASSWD: /usr/bin/docker
# $user ALL=(ALL) NOPASSWD: /usr/bin/systemctl
# $user ALL=(ALL) PASSWD: /usr/bin/passwd

EOF
    
    ${EDITOR:-nano} "${config_file}"
    
    if validate_sudoers "${config_file}"; then
        print_success "Custom configuration created!"
        print_info "File: ${config_file}"
    else
        print_error "Validation failed"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Option 5: View Configurations
################################################################################

view_configurations() {
    print_header "📋 Current Sudo Configurations"
    echo ""
    
    if [[ ! -d "${SUDOERS_DIR}" ]]; then
        print_warning "Directory ${SUDOERS_DIR} not found"
        return 1
    fi
    
    local count=0
    for config in "${SUDOERS_DIR}"/corporate_*; do
        if [[ -f "$config" ]]; then
            count=$((count + 1))
            echo ""
            print_section "File: $(basename $config)"
            echo "────────────────────────────────────"
            head -20 "$config"
            if [[ $(wc -l < "$config") -gt 20 ]]; then
                echo "... (more lines)"
            fi
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        print_warning "No corporate configurations found"
    else
        print_success "Total configurations: $count"
    fi
}

################################################################################
# Option 6: Restore Backup
################################################################################

restore_backup() {
    print_header "🔄 Restore Backup"
    echo ""
    
    if [[ ! -d "${BACKUP_DIR}" ]]; then
        print_warning "No backups available"
        return 0
    fi
    
    local count=0
    for backup in "${BACKUP_DIR}"/sudoers_backup_*; do
        if [[ -f "$backup" ]]; then
            count=$((count + 1))
            echo "  $count) $(basename $backup)"
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        print_warning "No backups available"
        return 0
    fi
    
    read -p "Select backup to restore [1-$count]: " choice
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt $count ]]; then
        print_error "Invalid option"
        return 1
    fi
    
    local backup_file=$(ls -1 "${BACKUP_DIR}"/sudoers_backup_* | sed -n "${choice}p")
    
    if [[ -f "$backup_file" ]]; then
        cp "$backup_file" /etc/sudoers
        print_success "Backup restored: $(basename $backup_file)"
    fi
}

################################################################################
# Main Loop
################################################################################

main() {
    check_root
    create_backup
    
    while true; do
        show_main_menu
        
        case $choice in
            1) setup_file_reader ;;
            2) setup_package_manager ;;
            3) setup_complete_sudo ;;
            4) setup_custom ;;
            5) view_configurations ;;
            6) restore_backup ;;
            7) 
                print_success "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
        
        echo ""
        read -p "Press ENTER to continue..."
    done
}

# Execute main
main "$@"
