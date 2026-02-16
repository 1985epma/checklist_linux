#!/bin/bash

################################################################################
# CORPORATE SUDO CONFIGURATOR
# Script to configure sudo appropriate for corporate environment
# Without root privileges, with granular permission control
# Author: Everton Araujo
# Version: 1.0
# Date: 2026-01-13
################################################################################

set -euo pipefail

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables
SUDOERS_DIR="/etc/sudoers.d"
BACKUP_DIR="/root/sudo_backups"
CURRENT_USER="${SUDO_USER:-$(whoami)}"

################################################################################
# Utility Functions
################################################################################

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

print_section() {
    echo -e "\n${CYAN}→ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run with sudo"
        exit 1
    fi
}

create_backup() {
    mkdir -p "${BACKUP_DIR}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/sudoers_backup_${timestamp}"
    
    if [[ -f /etc/sudoers ]]; then
        cp /etc/sudoers "${backup_file}"
        chmod 600 "${backup_file}"
        print_success "Backup created: ${backup_file}"
    fi
}

validate_sudoers() {
    if ! sudo -l -f "$1" > /dev/null 2>&1; then
        print_warning "Sudoers validation failed for: $1"
        return 1
    fi
    return 0
}

################################################################################
# Main Menu
################################################################################

show_main_menu() {
    clear
    print_header "🏢 CORPORATE SUDO CONFIGURATOR v1.0"
    echo ""
    echo "Configure sudo permissions for corporate environment"
    echo ""
    echo "  ${CYAN}1${NC}) Configure Sudo for File Reading/Execution"
    echo "  ${CYAN}2${NC}) Configure Sudo for Package Managers (apt/snap/flatpak)"
    echo "  ${CYAN}3${NC}) Configure Complete Sudo (without root privileges)"
    echo "  ${CYAN}4${NC}) Configure Custom Sudoers per User"
    echo "  ${CYAN}5${NC}) View Current Configurations"
    echo "  ${CYAN}6${NC}) Restore Backup"
    echo "  ${CYAN}7${NC}) Exit"
    echo ""
    read -p "Select an option [1-7]: " choice
}

################################################################################
# Option 1: File Reader
################################################################################

setup_file_reader() {
    print_header "📁 Configure Sudo for File Reading/Execution"
    echo ""
    
    read -p "Which user do you want to configure? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "User $user does not exist"
        return 1
    fi
    
    read -p "Which directories for reading? (separate with space) [/home /opt /srv]: " dirs
    dirs=${dirs:-"/home /opt /srv"}
    
    print_section "Configuring read permissions for: $user"
    print_info "Directories: $dirs"
    
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
        print_success "Read/execution configuration created!"
        print_info "File: ${config_file}"
    else
        print_error "Configuration validation failed"
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
