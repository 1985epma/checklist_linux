#!/bin/bash

################################################################################
# CORPORATE SUDO CONFIGURATOR
# Script para configurar sudo adequado para ambiente corporativo
# Sem privilégios root, com controle granular de permissões
# Autor: Everton Araujo
# Versão: 1.0
# Data: 2026-01-13
################################################################################

set -euo pipefail

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variáveis
SUDOERS_DIR="/etc/sudoers.d"
BACKUP_DIR="/root/sudo_backups"
CURRENT_USER="${SUDO_USER:-$(whoami)}"

################################################################################
# Funções de Utilitário
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
        print_error "Este script deve ser executado com sudo"
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
        print_success "Backup criado: ${backup_file}"
    fi
}

validate_sudoers() {
    if ! sudo -l -f "$1" > /dev/null 2>&1; then
        print_warning "Validação de sudoers falhou para: $1"
        return 1
    fi
    return 0
}

################################################################################
# Menu Principal
################################################################################

show_main_menu() {
    clear
    print_header "🏢 CORPORATE SUDO CONFIGURATOR v1.0"
    echo ""
    echo "Configurar permissões de sudo para ambiente corporativo"
    echo ""
    echo "  ${CYAN}1${NC}) Configurar Sudo para Leitura/Execução de Arquivos"
    echo "  ${CYAN}2${NC}) Configurar Sudo para Gerenciador de Pacotes (apt/snap/flatpak)"
    echo "  ${CYAN}3${NC}) Configurar Sudo Completo (sem privilégios root)"
    echo "  ${CYAN}4${NC}) Configurar Sudoers por Usuário Personalizado"
    echo "  ${CYAN}5${NC}) Visualizar Configurações Atuais"
    echo "  ${CYAN}6${NC}) Restaurar Backup"
    echo "  ${CYAN}7${NC}) Sair"
    echo ""
    read -p "Selecione uma opção [1-7]: " choice
}

################################################################################
# Opção 1: Arquivo Reader
################################################################################

setup_file_reader() {
    print_header "📁 Configurar Sudo para Leitura/Execução de Arquivos"
    echo ""
    
    read -p "Qual usuário deseja configurar? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "Usuário $user não existe"
        return 1
    fi
    
    read -p "Quais diretórios para leitura? (separe com espaço) [/home /opt /srv]: " dirs
    dirs=${dirs:-"/home /opt /srv"}
    
    print_section "Configurando permissões de leitura para: $user"
    print_info "Diretórios: $dirs"
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_files"
    
    cat > "${config_file}" << EOF
# Configuração de sudo para leitura/execução de arquivos
# Usuário: $user
# Data: $(date)

# Leitura e execução de scripts
$user ALL=(ALL) NOPASSWD: /usr/bin/cat /home/*
$user ALL=(ALL) NOPASSWD: /usr/bin/tail /home/*
$user ALL=(ALL) NOPASSWD: /usr/bin/find /home -type f
$user ALL=(ALL) NOPASSWD: /usr/bin/grep -r * /home/*
$user ALL=(ALL) NOPASSWD: /bin/bash /home/*/scripts/*
$user ALL=(ALL) NOPASSWD: /bin/sh /home/*/scripts/*

# Permissão para listar diretórios
$user ALL=(ALL) NOPASSWD: /bin/ls /home
$user ALL=(ALL) NOPASSWD: /bin/ls /opt
$user ALL=(ALL) NOPASSWD: /bin/ls /srv

# Verificação de permissões
$user ALL=(ALL) NOPASSWD: /bin/stat /home/*
$user ALL=(ALL) NOPASSWD: /usr/bin/file /home/*
EOF
    
    chmod 440 "${config_file}"
    
    if validate_sudoers "${config_file}"; then
        print_success "Configuração de leitura/execução criada!"
        print_info "Arquivo: ${config_file}"
    else
        print_error "Falha na validação da configuração"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Opção 2: Gerenciador de Pacotes
################################################################################

setup_package_manager() {
    print_header "📦 Configurar Sudo para Gerenciador de Pacotes"
    echo ""
    
    read -p "Qual usuário deseja configurar? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "Usuário $user não existe"
        return 1
    fi
    
    echo "Quais gerenciadores permitir?"
    echo "  ${CYAN}1${NC}) APT (Debian/Ubuntu)"
    echo "  ${CYAN}2${NC}) Snap"
    echo "  ${CYAN}3${NC}) Flatpak"
    echo "  ${CYAN}4${NC}) Todos"
    read -p "Escolha [1-4]: " pkg_choice
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_packages"
    
    cat > "${config_file}" << EOF
# Configuração de sudo para gerenciador de pacotes
# Usuário: $user
# Data: $(date)

# Atividades permitidas sem password
Defaults:$user !requiretty
Defaults:$user log_output

EOF
    
    case $pkg_choice in
        1|4)
            cat >> "${config_file}" << 'EOF'
# Permissões para APT
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
# Permissões para Snap
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
# Permissões para Flatpak
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
        print_success "Configuração de pacotes criada!"
        print_info "Arquivo: ${config_file}"
    else
        print_error "Falha na validação"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Opção 3: Sudo Completo (Sem Root)
################################################################################

setup_complete_sudo() {
    print_header "🚀 Configurar Sudo Completo (Sem privilégios root)"
    echo ""
    print_warning "Esta configuração é poderosa. Use com cuidado!"
    echo ""
    
    read -p "Qual usuário deseja configurar? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "Usuário $user não existe"
        return 1
    fi
    
    read -p "Permitir executar TODOS os comandos sem password? [s/N]: " confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        print_info "Operação cancelada"
        return 0
    fi
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_complete"
    
    cat > "${config_file}" << EOF
# Configuração completa de sudo para $user
# AVISO: Este usuário tem acesso praticamente ilimitado
# Data: $(date)

# Não requer tty para comandos sudo
Defaults:$user !requiretty

# Logging de todos os comandos executados
Defaults:$user log_output
Defaults:$user log_input

# Executa todos os comandos sem pedir password
$user ALL=(ALL) NOPASSWD: ALL

# Exceção: Comandos críticos que SEMPRE pedem confirmação
# $user ALL=(ALL) PASSWD: /usr/bin/passwd
# $user ALL=(ALL) PASSWD: /sbin/shutdown
# $user ALL=(ALL) PASSWD: /sbin/reboot
EOF
    
    chmod 440 "${config_file}"
    
    if validate_sudoers "${config_file}"; then
        print_success "Configuração completa criada!"
        print_warning "Lembre-se: Este usuário pode executar qualquer comando!"
        print_info "Arquivo: ${config_file}"
    else
        print_error "Falha na validação"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Opção 4: Configuração Personalizada
################################################################################

setup_custom() {
    print_header "⚙️ Configurar Sudoers Personalizado"
    echo ""
    
    read -p "Qual usuário deseja configurar? [${CURRENT_USER}]: " user
    user=${user:-$CURRENT_USER}
    
    if ! id "$user" &>/dev/null; then
        print_error "Usuário $user não existe"
        return 1
    fi
    
    read -p "Nome da configuração: " config_name
    config_name=${config_name//[^a-zA-Z0-9_]/}
    
    local config_file="${SUDOERS_DIR}/corporate_${user}_${config_name}"
    
    print_section "Edite a configuração (salve e saia para confirmar):"
    print_info "Use o editor para adicionar regras. Exemplo:"
    echo "    $user ALL=(ALL) NOPASSWD: /usr/bin/docker"
    echo "    $user ALL=(ALL) NOPASSWD: /usr/bin/systemctl"
    echo ""
    
    # Template inicial
    cat > "${config_file}" << EOF
# Configuração personalizada para $user
# Data: $(date)
# Edite as linhas abaixo com os comandos desejados

# Exemplo:
# $user ALL=(ALL) NOPASSWD: /usr/bin/docker
# $user ALL=(ALL) NOPASSWD: /usr/bin/systemctl
# $user ALL=(ALL) PASSWD: /usr/bin/passwd

EOF
    
    ${EDITOR:-nano} "${config_file}"
    
    if validate_sudoers "${config_file}"; then
        print_success "Configuração personalizada criada!"
        print_info "Arquivo: ${config_file}"
    else
        print_error "Falha na validação"
        rm "${config_file}"
        return 1
    fi
}

################################################################################
# Opção 5: Visualizar Configurações
################################################################################

view_configurations() {
    print_header "📋 Configurações Atuais de Sudo"
    echo ""
    
    if [[ ! -d "${SUDOERS_DIR}" ]]; then
        print_warning "Diretório ${SUDOERS_DIR} não encontrado"
        return 1
    fi
    
    local count=0
    for config in "${SUDOERS_DIR}"/corporate_*; do
        if [[ -f "$config" ]]; then
            count=$((count + 1))
            echo ""
            print_section "Arquivo: $(basename $config)"
            echo "────────────────────────────────────"
            head -20 "$config"
            if [[ $(wc -l < "$config") -gt 20 ]]; then
                echo "... (mais linhas)"
            fi
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        print_warning "Nenhuma configuração corporativa encontrada"
    else
        print_success "Total de configurações: $count"
    fi
}

################################################################################
# Opção 6: Restaurar Backup
################################################################################

restore_backup() {
    print_header "🔄 Restaurar Backup"
    echo ""
    
    if [[ ! -d "${BACKUP_DIR}" ]]; then
        print_warning "Nenhum backup disponível"
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
        print_warning "Nenhum backup disponível"
        return 0
    fi
    
    read -p "Selecione o backup para restaurar [1-$count]: " choice
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt $count ]]; then
        print_error "Opção inválida"
        return 1
    fi
    
    local backup_file=$(ls -1 "${BACKUP_DIR}"/sudoers_backup_* | sed -n "${choice}p")
    
    if [[ -f "$backup_file" ]]; then
        cp "$backup_file" /etc/sudoers
        print_success "Backup restaurado: $(basename $backup_file)"
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
                print_success "Encerrando..."
                exit 0
                ;;
            *)
                print_error "Opção inválida"
                ;;
        esac
        
        echo ""
        read -p "Pressione ENTER para continuar..."
    done
}

# Executar main
main "$@"
