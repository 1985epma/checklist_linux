#!/bin/bash

# ============================================================================
# Script de Otimização de Serviços Linux
# Autor: Everton Araujo
# Data: 2025-12-21
# Versão: 1.0
# 
# Descrição: Remove/desativa serviços desnecessários baseado no tipo de sistema
# ============================================================================

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Variáveis globais
MODE=""
SYSTEM_TYPE=""
DRY_RUN=false
LOG_FILE="service_optimizer_$(date +%Y%m%d_%H%M%S).log"

# ============================================================================
# DEFINIÇÃO DE SERVIÇOS POR CATEGORIA
# ============================================================================

# Serviços desnecessários em DESKTOP
DESKTOP_UNNECESSARY=(
    # Servidores
    "apache2:Servidor web Apache"
    "nginx:Servidor web Nginx"
    "mysql:Banco de dados MySQL"
    "mariadb:Banco de dados MariaDB"
    "postgresql:Banco de dados PostgreSQL"
    "mongodb:Banco de dados MongoDB"
    "redis-server:Cache Redis"
    "memcached:Cache Memcached"
    "docker:Container Docker (se não usar)"
    "containerd:Runtime de containers"
    
    # Serviços de rede/servidor
    "sshd:Servidor SSH (se não precisar acesso remoto)"
    "vsftpd:Servidor FTP"
    "proftpd:Servidor FTP"
    "smbd:Samba (compartilhamento Windows)"
    "nmbd:Samba NetBIOS"
    "nfs-server:Servidor NFS"
    "rpcbind:RPC para NFS"
    "bind9:Servidor DNS"
    "named:Servidor DNS BIND"
    "postfix:Servidor de email"
    "dovecot:Servidor IMAP/POP3"
    "exim4:Servidor de email"
    
    # Serviços de impressão (se não usar impressora)
    "cups:Sistema de impressão CUPS"
    "cups-browsed:Descoberta de impressoras"
    
    # Bluetooth (se não usar)
    "bluetooth:Serviço Bluetooth"
    "blueman-mechanism:Gerenciador Bluetooth"
    
    # Outros
    "avahi-daemon:Descoberta de rede mDNS"
    "ModemManager:Gerenciador de modem 3G/4G"
    "wpa_supplicant:WiFi (em desktop com cabo)"
    "thermald:Controle térmico Intel (em AMD)"
    "irqbalance:Balanceamento de IRQ (desktop simples)"
    "lxd:Containers LXD"
    "snapd:Snap packages (se preferir apt)"
    "fwupd:Atualização de firmware"
    "packagekit:PackageKit"
    "unattended-upgrades:Atualizações automáticas"
    "apport:Relatório de crashes"
    "whoopsie:Relatório de erros Ubuntu"
)

# Serviços desnecessários em SERVIDOR
SERVER_UNNECESSARY=(
    # Interface gráfica
    "gdm:GNOME Display Manager"
    "gdm3:GNOME Display Manager 3"
    "lightdm:LightDM Display Manager"
    "sddm:KDE Display Manager"
    "xdm:X Display Manager"
    
    # Desktop environment
    "gnome-shell:GNOME Shell"
    "plasmashell:KDE Plasma"
    "xfce4:XFCE Desktop"
    
    # Som e multimídia
    "pulseaudio:Servidor de áudio PulseAudio"
    "pipewire:Servidor de áudio PipeWire"
    "pipewire-pulse:PipeWire PulseAudio"
    "alsa-state:Estado do ALSA"
    "alsa-restore:Restauração ALSA"
    
    # Bluetooth
    "bluetooth:Serviço Bluetooth"
    "blueman-mechanism:Gerenciador Bluetooth"
    
    # Impressão (geralmente)
    "cups:Sistema de impressão CUPS"
    "cups-browsed:Descoberta de impressoras"
    
    # Rede desktop
    "avahi-daemon:Descoberta de rede mDNS"
    "ModemManager:Gerenciador de modem"
    "NetworkManager:Gerenciador de rede (se usar netplan)"
    
    # Outros desktop
    "colord:Gerenciamento de cores"
    "accounts-daemon:Contas de usuário GUI"
    "whoopsie:Relatório de erros"
    "apport:Relatório de crashes"
    "kerneloops:Relatório de kernel oops"
    "speech-dispatcher:Síntese de voz"
    "brltty:Suporte a Braille"
    "udisks2:Montagem automática de discos"
    "gvfs:Sistema de arquivos virtual GNOME"
    "tracker:Indexador de arquivos"
    "tracker-miner-fs:Minerador de arquivos"
    "evolution-data-server:Dados do Evolution"
    "gnome-keyring:Chaveiro GNOME"
    "geoclue:Serviço de geolocalização"
    "switcheroo-control:Controle de GPU híbrida"
    "bolt:Gerenciador Thunderbolt"
    "fwupd:Atualização de firmware"
    "packagekit:PackageKit"
)

# Serviços desnecessários em CONTAINER
CONTAINER_UNNECESSARY=(
    # Init systems (containers usam PID 1 diferente)
    "systemd-journald:Journal do systemd"
    "systemd-udevd:Gerenciador de dispositivos"
    "systemd-logind:Login do systemd"
    "systemd-resolved:Resolvedor DNS systemd"
    "systemd-networkd:Rede do systemd"
    "systemd-timesyncd:Sincronização de tempo"
    
    # Kernel/Hardware
    "udev:Gerenciador de dispositivos"
    "dbus:Message bus (geralmente)"
    "polkit:PolicyKit"
    "udisks2:Montagem de discos"
    "thermald:Controle térmico"
    "irqbalance:Balanceamento de IRQ"
    "lvm2-monitor:Monitor LVM"
    "multipathd:Multipath"
    "mdadm:RAID software"
    
    # Rede (gerenciada pelo host)
    "NetworkManager:Gerenciador de rede"
    "networking:Rede SysV"
    "wpa_supplicant:WiFi"
    "ModemManager:Gerenciador de modem"
    "avahi-daemon:mDNS"
    "bluetooth:Bluetooth"
    
    # Cron (use jobs do orquestrador)
    "cron:Agendador de tarefas"
    "anacron:Anacron"
    "atd:At daemon"
    
    # Logs (use log driver do container)
    "rsyslog:Syslog"
    "syslog-ng:Syslog NG"
    
    # SSH (acesse via docker exec)
    "ssh:Servidor SSH"
    "sshd:Servidor SSH daemon"
    
    # Outros
    "snapd:Snap packages"
    "lxd:LXD"
    "fwupd:Firmware"
    "packagekit:PackageKit"
    "apport:Crash reports"
    "whoopsie:Error reports"
    "unattended-upgrades:Auto updates"
    "cups:Impressão"
    "postfix:Email"
)

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║        🔧 OTIMIZADOR DE SERVIÇOS LINUX 🔧                         ║"
    echo "║          Remova serviços desnecessários                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "📅 $(date)"
    echo -e "🖥️  $(hostname) - $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo ""
}

show_help() {
    print_banner
    echo -e "${BOLD}USO:${NC}"
    echo "  $0 [OPÇÕES]"
    echo ""
    echo -e "${BOLD}OPÇÕES:${NC}"
    echo "  -t, --type TYPE      Tipo de sistema: desktop, server, container"
    echo "  -m, --mode MODE      Modo de operação: 1 (auto), 2 (avançado), 3 (interativo)"
    echo "  -d, --dry-run        Simular sem fazer alterações"
    echo "  -l, --list           Listar serviços sem executar"
    echo "  -h, --help           Mostrar esta ajuda"
    echo ""
    echo -e "${BOLD}MODOS:${NC}"
    echo -e "  ${GREEN}1 - Automático${NC}     Desativa todos os serviços recomendados automaticamente"
    echo -e "  ${YELLOW}2 - Avançado${NC}       Permite selecionar categorias de serviços"
    echo -e "  ${CYAN}3 - Interativo${NC}     Pergunta para cada serviço individualmente"
    echo ""
    echo -e "${BOLD}EXEMPLOS:${NC}"
    echo "  $0 -t desktop -m 1              # Auto-otimizar desktop"
    echo "  $0 -t server -m 3               # Interativo para servidor"
    echo "  $0 -t container -m 1 --dry-run  # Simular em container"
    echo "  $0 --list -t desktop            # Listar serviços de desktop"
    echo ""
}

check_root() {
    if [ "$EUID" -ne 0 ] && [ "$DRY_RUN" = false ]; then
        echo -e "${RED}❌ Este script precisa ser executado como root!${NC}"
        echo -e "   Use: sudo $0"
        exit 1
    fi
}

get_service_status() {
    local service="$1"
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "running"
    elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
        echo "enabled"
    elif systemctl list-unit-files | grep -q "^${service}"; then
        echo "installed"
    else
        echo "not-found"
    fi
}

disable_service() {
    local service="$1"
    local description="$2"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[DRY-RUN]${NC} Desativaria: $service"
        log "[DRY-RUN] Would disable: $service"
        return 0
    fi
    
    local status
    status=$(get_service_status "$service")
    
    if [ "$status" = "not-found" ]; then
        echo -e "  ${BLUE}⊘${NC} $service - não instalado"
        return 0
    fi
    
    echo -e "  ${YELLOW}⏳${NC} Desativando $service..."
    
    if systemctl stop "$service" 2>/dev/null; then
        log "Stopped: $service"
    fi
    
    if systemctl disable "$service" 2>/dev/null; then
        log "Disabled: $service"
        echo -e "  ${GREEN}✓${NC} $service desativado com sucesso"
        return 0
    else
        echo -e "  ${RED}✗${NC} Falha ao desativar $service"
        log "Failed to disable: $service"
        return 1
    fi
}

mask_service() {
    local service="$1"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[DRY-RUN]${NC} Mascararia: $service"
        return 0
    fi
    
    systemctl mask "$service" 2>/dev/null
    log "Masked: $service"
}

# ============================================================================
# FUNÇÕES DE LISTAGEM
# ============================================================================

list_services() {
    local -n services=$1
    local type_name="$2"
    
    echo -e "\n${BOLD}${MAGENTA}═══ Serviços desnecessários para $type_name ═══${NC}\n"
    
    printf "%-25s %-10s %s\n" "SERVIÇO" "STATUS" "DESCRIÇÃO"
    echo "─────────────────────────────────────────────────────────────────────"
    
    local running=0
    local enabled=0
    local installed=0
    
    for item in "${services[@]}"; do
        local service="${item%%:*}"
        local description="${item#*:}"
        local status
        status=$(get_service_status "$service")
        
        case $status in
            "running")
                printf "${RED}%-25s${NC} ${RED}%-10s${NC} %s\n" "$service" "ATIVO" "$description"
                ((running++))
                ;;
            "enabled")
                printf "${YELLOW}%-25s${NC} ${YELLOW}%-10s${NC} %s\n" "$service" "HABILITADO" "$description"
                ((enabled++))
                ;;
            "installed")
                printf "${BLUE}%-25s${NC} ${BLUE}%-10s${NC} %s\n" "$service" "INSTALADO" "$description"
                ((installed++))
                ;;
            *)
                printf "${GREEN}%-25s${NC} ${GREEN}%-10s${NC} %s\n" "$service" "N/A" "$description"
                ;;
        esac
    done
    
    echo ""
    echo -e "${BOLD}RESUMO:${NC}"
    echo -e "  ${RED}● Ativos: $running${NC}"
    echo -e "  ${YELLOW}● Habilitados: $enabled${NC}"
    echo -e "  ${BLUE}● Instalados: $installed${NC}"
    echo ""
}

# ============================================================================
# MODO 1: AUTOMÁTICO
# ============================================================================

mode_automatic() {
    local -n services=$1
    
    echo -e "\n${GREEN}${BOLD}═══ MODO AUTOMÁTICO ═══${NC}"
    echo -e "Desativando todos os serviços desnecessários...\n"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  MODO SIMULAÇÃO - Nenhuma alteração será feita${NC}\n"
    fi
    
    local success=0
    local failed=0
    local skipped=0
    
    for item in "${services[@]}"; do
        local service="${item%%:*}"
        local description="${item#*:}"
        local status
        status=$(get_service_status "$service")
        
        if [ "$status" = "not-found" ]; then
            ((skipped++))
            continue
        fi
        
        if [ "$status" = "running" ] || [ "$status" = "enabled" ]; then
            if disable_service "$service" "$description"; then
                ((success++))
            else
                ((failed++))
            fi
        else
            ((skipped++))
        fi
    done
    
    echo ""
    echo -e "${BOLD}═══ RESULTADO ═══${NC}"
    echo -e "  ${GREEN}✓ Desativados: $success${NC}"
    echo -e "  ${RED}✗ Falharam: $failed${NC}"
    echo -e "  ${BLUE}⊘ Pulados: $skipped${NC}"
    
    if [ "$DRY_RUN" = false ]; then
        echo -e "\n${YELLOW}💡 Reinicie o sistema para aplicar todas as alterações${NC}"
    fi
}

# ============================================================================
# MODO 2: AVANÇADO (por categorias)
# ============================================================================

mode_advanced() {
    local -n services=$1
    
    echo -e "\n${YELLOW}${BOLD}═══ MODO AVANÇADO ═══${NC}"
    echo -e "Selecione categorias de serviços para desativar\n"
    
    # Categorias
    declare -A categories
    categories["Servidores Web"]="apache2 nginx"
    categories["Banco de Dados"]="mysql mariadb postgresql mongodb redis-server memcached"
    categories["Containers"]="docker containerd lxd snapd"
    categories["Impressão"]="cups cups-browsed"
    categories["Bluetooth"]="bluetooth blueman-mechanism"
    categories["Som/Áudio"]="pulseaudio pipewire pipewire-pulse alsa-state alsa-restore"
    categories["Interface Gráfica"]="gdm gdm3 lightdm sddm xdm"
    categories["Rede"]="avahi-daemon ModemManager NetworkManager smbd nmbd nfs-server"
    categories["Email"]="postfix dovecot exim4"
    categories["Relatórios"]="apport whoopsie kerneloops"
    categories["Outros"]="fwupd packagekit unattended-upgrades tracker tracker-miner-fs"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  MODO SIMULAÇÃO - Nenhuma alteração será feita${NC}\n"
    fi
    
    local i=1
    declare -A cat_index
    
    echo -e "${BOLD}Categorias disponíveis:${NC}\n"
    for cat in "${!categories[@]}"; do
        local cat_services="${categories[$cat]}"
        local active=0
        for svc in $cat_services; do
            local status
            status=$(get_service_status "$svc")
            if [ "$status" = "running" ] || [ "$status" = "enabled" ]; then
                ((active++))
            fi
        done
        
        if [ $active -gt 0 ]; then
            echo -e "  ${CYAN}[$i]${NC} $cat (${RED}$active ativos${NC})"
        else
            echo -e "  ${CYAN}[$i]${NC} $cat (${GREEN}nenhum ativo${NC})"
        fi
        cat_index[$i]="$cat"
        ((i++))
    done
    
    echo -e "\n  ${CYAN}[A]${NC} Selecionar TODAS"
    echo -e "  ${CYAN}[0]${NC} Sair"
    echo ""
    
    read -rp "Digite os números separados por espaço (ex: 1 3 5) ou 'A' para todas: " selection
    
    if [ "$selection" = "0" ]; then
        echo "Saindo..."
        exit 0
    fi
    
    local selected_services=""
    
    if [ "$selection" = "A" ] || [ "$selection" = "a" ]; then
        for cat in "${!categories[@]}"; do
            selected_services+=" ${categories[$cat]}"
        done
    else
        for num in $selection; do
            if [ -n "${cat_index[$num]}" ]; then
                local cat="${cat_index[$num]}"
                selected_services+=" ${categories[$cat]}"
                echo -e "  ${GREEN}✓${NC} Selecionado: $cat"
            fi
        done
    fi
    
    echo ""
    echo -e "${BOLD}Desativando serviços selecionados...${NC}\n"
    
    local success=0
    local failed=0
    
    for service in $selected_services; do
        local status
        status=$(get_service_status "$service")
        
        if [ "$status" = "running" ] || [ "$status" = "enabled" ]; then
            if disable_service "$service" ""; then
                ((success++))
            else
                ((failed++))
            fi
        fi
    done
    
    echo ""
    echo -e "${BOLD}═══ RESULTADO ═══${NC}"
    echo -e "  ${GREEN}✓ Desativados: $success${NC}"
    echo -e "  ${RED}✗ Falharam: $failed${NC}"
}

# ============================================================================
# MODO 3: INTERATIVO
# ============================================================================

mode_interactive() {
    local -n services=$1
    
    echo -e "\n${CYAN}${BOLD}═══ MODO INTERATIVO ═══${NC}"
    echo -e "Você será questionado sobre cada serviço ativo\n"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  MODO SIMULAÇÃO - Nenhuma alteração será feita${NC}\n"
    fi
    
    echo -e "${BOLD}Teclas:${NC}"
    echo -e "  ${GREEN}[S/s/Enter]${NC} - Sim, desativar"
    echo -e "  ${RED}[N/n]${NC}       - Não, manter"
    echo -e "  ${YELLOW}[P/p]${NC}       - Pular todos restantes"
    echo -e "  ${CYAN}[A/a]${NC}       - Desativar todos restantes"
    echo -e "  ${MAGENTA}[Q/q]${NC}       - Sair"
    echo ""
    
    local success=0
    local skipped=0
    local auto_yes=false
    
    for item in "${services[@]}"; do
        local service="${item%%:*}"
        local description="${item#*:}"
        local status
        status=$(get_service_status "$service")
        
        # Pular serviços não instalados ou já desativados
        if [ "$status" = "not-found" ] || [ "$status" = "installed" ]; then
            continue
        fi
        
        # Se auto_yes está ativo, desativa automaticamente
        if [ "$auto_yes" = true ]; then
            if disable_service "$service" "$description"; then
                ((success++))
            fi
            continue
        fi
        
        echo ""
        echo -e "╭─────────────────────────────────────────────────────────────"
        echo -e "│ ${BOLD}Serviço:${NC} ${CYAN}$service${NC}"
        echo -e "│ ${BOLD}Status:${NC}  ${RED}$status${NC}"
        echo -e "│ ${BOLD}Descrição:${NC} $description"
        echo -e "╰─────────────────────────────────────────────────────────────"
        
        read -rp "  Desativar este serviço? [S/n/p/a/q]: " answer
        
        case ${answer,,} in
            ""|"s"|"y"|"sim"|"yes")
                if disable_service "$service" "$description"; then
                    ((success++))
                fi
                ;;
            "n"|"não"|"no")
                echo -e "  ${BLUE}⊘${NC} Mantendo $service"
                ((skipped++))
                ;;
            "p"|"pular"|"skip")
                echo -e "  ${YELLOW}⏭️  Pulando todos os restantes${NC}"
                break
                ;;
            "a"|"all"|"todos")
                echo -e "  ${CYAN}⚡ Desativando todos os restantes${NC}"
                auto_yes=true
                if disable_service "$service" "$description"; then
                    ((success++))
                fi
                ;;
            "q"|"quit"|"sair")
                echo -e "  ${MAGENTA}👋 Saindo...${NC}"
                break
                ;;
            *)
                echo -e "  ${BLUE}⊘${NC} Mantendo $service (resposta inválida)"
                ((skipped++))
                ;;
        esac
    done
    
    echo ""
    echo -e "${BOLD}═══ RESULTADO ═══${NC}"
    echo -e "  ${GREEN}✓ Desativados: $success${NC}"
    echo -e "  ${BLUE}⊘ Mantidos: $skipped${NC}"
    
    if [ "$DRY_RUN" = false ] && [ $success -gt 0 ]; then
        echo -e "\n${YELLOW}💡 Reinicie o sistema para aplicar todas as alterações${NC}"
    fi
}

# ============================================================================
# SELEÇÃO DE TIPO DE SISTEMA
# ============================================================================

select_system_type() {
    echo -e "\n${BOLD}Selecione o tipo de sistema:${NC}\n"
    echo -e "  ${CYAN}[1]${NC} 🖥️  Desktop - Computador pessoal com interface gráfica"
    echo -e "  ${CYAN}[2]${NC} 🖧  Servidor - Servidor sem interface gráfica"
    echo -e "  ${CYAN}[3]${NC} 📦 Container - Ambiente containerizado (Docker/LXC)"
    echo ""
    
    read -rp "Escolha [1-3]: " choice
    
    case $choice in
        1) SYSTEM_TYPE="desktop" ;;
        2) SYSTEM_TYPE="server" ;;
        3) SYSTEM_TYPE="container" ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            exit 1
            ;;
    esac
}

select_mode() {
    echo -e "\n${BOLD}Selecione o modo de operação:${NC}\n"
    echo -e "  ${GREEN}[1]${NC} ⚡ Automático   - Desativa todos os serviços recomendados"
    echo -e "  ${YELLOW}[2]${NC} 🔧 Avançado     - Seleciona categorias de serviços"
    echo -e "  ${CYAN}[3]${NC} 💬 Interativo   - Pergunta para cada serviço"
    echo ""
    
    read -rp "Escolha [1-3]: " choice
    
    case $choice in
        1) MODE="automatic" ;;
        2) MODE="advanced" ;;
        3) MODE="interactive" ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            exit 1
            ;;
    esac
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local list_only=false
    
    # Processar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                SYSTEM_TYPE="$2"
                shift 2
                ;;
            -m|--mode)
                case $2 in
                    1) MODE="automatic" ;;
                    2) MODE="advanced" ;;
                    3) MODE="interactive" ;;
                    *) MODE="$2" ;;
                esac
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Opção desconhecida: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_banner
    
    # Se não especificou tipo, perguntar
    if [ -z "$SYSTEM_TYPE" ]; then
        select_system_type
    fi
    
    # Selecionar array de serviços baseado no tipo
    local services_ref
    case $SYSTEM_TYPE in
        "desktop")
            services_ref="DESKTOP_UNNECESSARY"
            ;;
        "server"|"servidor")
            services_ref="SERVER_UNNECESSARY"
            ;;
        "container"|"docker")
            services_ref="CONTAINER_UNNECESSARY"
            ;;
        *)
            echo -e "${RED}Tipo de sistema inválido: $SYSTEM_TYPE${NC}"
            echo "Use: desktop, server ou container"
            exit 1
            ;;
    esac
    
    # Se é apenas listagem
    if [ "$list_only" = true ]; then
        case $SYSTEM_TYPE in
            "desktop") list_services DESKTOP_UNNECESSARY "DESKTOP" ;;
            "server"|"servidor") list_services SERVER_UNNECESSARY "SERVIDOR" ;;
            "container"|"docker") list_services CONTAINER_UNNECESSARY "CONTAINER" ;;
        esac
        exit 0
    fi
    
    # Verificar root (exceto em dry-run)
    if [ "$DRY_RUN" = false ]; then
        check_root
    fi
    
    # Se não especificou modo, perguntar
    if [ -z "$MODE" ]; then
        select_mode
    fi
    
    # Log inicial
    log "=== Starting Service Optimizer ==="
    log "System Type: $SYSTEM_TYPE"
    log "Mode: $MODE"
    log "Dry Run: $DRY_RUN"
    
    # Executar modo selecionado
    case $MODE in
        "automatic"|"auto"|"1")
            case $SYSTEM_TYPE in
                "desktop") mode_automatic DESKTOP_UNNECESSARY ;;
                "server"|"servidor") mode_automatic SERVER_UNNECESSARY ;;
                "container"|"docker") mode_automatic CONTAINER_UNNECESSARY ;;
            esac
            ;;
        "advanced"|"2")
            case $SYSTEM_TYPE in
                "desktop") mode_advanced DESKTOP_UNNECESSARY ;;
                "server"|"servidor") mode_advanced SERVER_UNNECESSARY ;;
                "container"|"docker") mode_advanced CONTAINER_UNNECESSARY ;;
            esac
            ;;
        "interactive"|"3")
            case $SYSTEM_TYPE in
                "desktop") mode_interactive DESKTOP_UNNECESSARY ;;
                "server"|"servidor") mode_interactive SERVER_UNNECESSARY ;;
                "container"|"docker") mode_interactive CONTAINER_UNNECESSARY ;;
            esac
            ;;
        *)
            echo -e "${RED}Modo inválido: $MODE${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}📝 Log salvo em: $LOG_FILE${NC}"
    log "=== Finished ==="
}

main "$@"
