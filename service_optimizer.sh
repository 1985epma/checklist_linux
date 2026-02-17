#!/bin/bash

# ============================================================================
# EPMA Security Tools - Service Optimizer
# Author: Everton Araujo
# Date: 2025-12-21
# Version: 1.0
# 
# Description: Remove/disable unnecessary services based on system type
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

# Global variables
MODE=""
SYSTEM_TYPE=""
DRY_RUN=false
LOG_FILE="service_optimizer_$(date +%Y%m%d_%H%M%S).log"

# ============================================================================
# SERVICE DEFINITION BY CATEGORY
# ============================================================================

# Unnecessary services on DESKTOP
DESKTOP_UNNECESSARY=(
    # Servers
    "apache2:Apache web server"
    "nginx:Nginx web server"
    "mysql:MySQL database"
    "mariadb:MariaDB database"
    "postgresql:PostgreSQL database"
    "mongodb:MongoDB database"
    "redis-server:Redis cache"
    "memcached:Memcached cache"
    "docker:Docker container (if not using)"
    "containerd:Container runtime"
    
    # Network/server services
    "sshd:SSH server (if remote access not needed)"
    "vsftpd:FTP server"
    "proftpd:FTP server"
    "smbd:Samba (Windows sharing)"
    "nmbd:Samba NetBIOS"
    "nfs-server:NFS server"
    "rpcbind:RPC for NFS"
    "bind9:DNS server"
    "named:BIND DNS server"
    "postfix:Email server"
    "dovecot:IMAP/POP3 server"
    "exim4:Email server"
    
    # Printing services (if not using printer)
    "cups:CUPS printing system"
    "cups-browsed:Printer discovery"
    
    # Bluetooth (if not using)
    "bluetooth:Bluetooth service"
    "blueman-mechanism:Blueman Bluetooth manager"
    
    # Others
    "avahi-daemon:mDNS network discovery"
    "ModemManager:3G/4G modem manager"
    "wpa_supplicant:WiFi (on wired desktop)"
    "thermald:Intel thermal control (on AMD)"
    "irqbalance:IRQ balancing (simple desktop)"
    "lxd:LXD containers"
    "snapd:Snap packages (if preferring apt)"
    "fwupd:Firmware update"
    "packagekit:PackageKit"
    "unattended-upgrades:Automatic updates"
    "apport:Crash reports"
    "whoopsie:Ubuntu error reports"
)

# Unnecessary services on SERVER
SERVER_UNNECESSARY=(
    # Graphical interface
    "gdm:GNOME Display Manager"
    "gdm3:GNOME Display Manager 3"
    "lightdm:LightDM Display Manager"
    "sddm:KDE Display Manager"
    "xdm:X Display Manager"
    
    # Desktop environment
    "gnome-shell:GNOME Shell"
    "plasmashell:KDE Plasma"
    "xfce4:XFCE Desktop"
    
    # Sound and multimedia
    "pulseaudio:PulseAudio audio server"
    "pipewire:PipeWire audio server"
    "pipewire-pulse:PipeWire PulseAudio"
    "alsa-state:ALSA state"
    "alsa-restore:ALSA restore"
    
    # Bluetooth
    "bluetooth:Bluetooth service"
    "blueman-mechanism:Blueman Bluetooth manager"
    
    # Printing (usually)
    "cups:CUPS printing system"
    "cups-browsed:Printer discovery"
    
    # Desktop network
    "avahi-daemon:mDNS network discovery"
    "ModemManager:Modem manager"
    "NetworkManager:Network manager (if using netplan)"
    
    # Other desktop
    "colord:Color management"
    "accounts-daemon:GUI user accounts"
    "whoopsie:Error reports"
    "apport:Crash reports"
    "kerneloops:Kernel oops reports"
    "speech-dispatcher:Speech synthesis"
    "brltty:Braille support"
    "udisks2:Automatic disk mounting"
    "gvfs:GNOME virtual file system"
    "tracker:File indexer"
    "tracker-miner-fs:File miner"
    "evolution-data-server:Evolution data"
    "gnome-keyring:GNOME keyring"
    "geoclue:Geolocation service"
    "switcheroo-control:Hybrid GPU control"
    "bolt:Thunderbolt manager"
    "fwupd:Firmware update"
    "packagekit:PackageKit"
)

# Unnecessary services on CONTAINER
CONTAINER_UNNECESSARY=(
    # Init systems (containers use different PID 1)
    "systemd-journald:Systemd journal"
    "systemd-udevd:Device manager"
    "systemd-logind:Systemd login"
    "systemd-resolved:Systemd DNS resolver"
    "systemd-networkd:Systemd network"
    "systemd-timesyncd:Time synchronization"
    
    # Kernel/Hardware
    "udev:Device manager"
    "dbus:Message bus (usually)"
    "polkit:PolicyKit"
    "udisks2:Disk mounting"
    "thermald:Thermal control"
    "irqbalance:IRQ balancing"
    "lvm2-monitor:LVM monitor"
    "multipathd:Multipath"
    "mdadm:Software RAID"
    
    # Network (managed by host)
    "NetworkManager:Network manager"
    "networking:SysV network"
    "wpa_supplicant:WiFi"
    "ModemManager:Modem manager"
    "avahi-daemon:mDNS"
    "bluetooth:Bluetooth"
    
    # Cron (use orchestrator jobs)
    "cron:Task scheduler"
    "anacron:Anacron"
    "atd:At daemon"
    
    # Logs (use container log driver)
    "rsyslog:Syslog"
    "syslog-ng:Syslog NG"
    
    # SSH (access via docker exec)
    "ssh:SSH server"
    "sshd:SSH daemon"
    
    # Others
    "snapd:Snap packages"
    "lxd:LXD"
    "fwupd:Firmware"
    "packagekit:PackageKit"
    "apport:Crash reports"
    "whoopsie:Error reports"
    "unattended-upgrades:Auto updates"
    "cups:Printing"
    "postfix:Email"
)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║        🔧 LINUX SERVICE OPTIMIZER 🔧                              ║"
    echo "║          Remove unnecessary services                              ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "📅 $(date)"
    echo -e "🖥️  $(hostname) - $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo ""
}

show_help() {
    print_banner
    echo -e "${BOLD}USAGE:${NC}"
    echo "  $0 [OPTIONS]"
    echo ""
    echo -e "${BOLD}OPTIONS:${NC}"
    echo "  -t, --type TYPE      System type: desktop, server, container"
    echo "  -m, --mode MODE      Operation mode: 1 (auto), 2 (advanced), 3 (interactive)"
    echo "  -d, --dry-run        Simulate without making changes"
    echo "  -l, --list           List services without executing"
    echo "  -h, --help           Show this help"
    echo ""
    echo -e "${BOLD}MODES:${NC}"
    echo -e "  ${GREEN}1 - Automatic${NC}     Disables all recommended services automatically"
    echo -e "  ${YELLOW}2 - Advanced${NC}       Allows selecting service categories"
    echo -e "  ${CYAN}3 - Interactive${NC}     Asks for each service individually"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "  $0 -t desktop -m 1              # Auto-optimize desktop"
    echo "  $0 -t server -m 3               # Interactive for server"
    echo "  $0 -t container -m 1 --dry-run  # Simulate in container"
    echo "  $0 --list -t desktop            # List desktop services"
    echo ""
}

check_root() {
    if [ "$EUID" -ne 0 ] && [ "$DRY_RUN" = false ]; then
        echo -e "${RED}❌ This script needs to be run as root!${NC}"
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
        echo -e "  ${YELLOW}[DRY-RUN]${NC} Would disable: $service"
        log "[DRY-RUN] Would disable: $service"
        return 0
    fi
    
    local status
    status=$(get_service_status "$service")
    
    if [ "$status" = "not-found" ]; then
        echo -e "  ${BLUE}⊝${NC} $service - not installed"
        return 0
    fi
    
    echo -e "  ${YELLOW}⏳${NC} Disabling $service..."
    
    if systemctl stop "$service" 2>/dev/null; then
        log "Stopped: $service"
    fi
    
    if systemctl disable "$service" 2>/dev/null; then
        log "Disabled: $service"
        echo -e "  ${GREEN}✓${NC} $service disabled successfully"
        return 0
    else
        echo -e "  ${RED}✗${NC} Failed to disable $service"
        log "Failed to disable: $service"
        return 1
    fi
}

mask_service() {
    local service="$1"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[DRY-RUN]${NC} Would mask: $service"
        return 0
    fi
    
    systemctl mask "$service" 2>/dev/null
    log "Masked: $service"
}

# ============================================================================
# LISTING FUNCTIONS
# ============================================================================

list_services() {
    local -n services=$1
    local type_name="$2"
    
    echo -e "\n${BOLD}${MAGENTA}═══ Unnecessary services for $type_name ═══${NC}\n"
    
    printf "%-25s %-10s %s\n" "SERVICE" "STATUS" "DESCRIPTION"
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
                printf "${RED}%-25s${NC} ${RED}%-10s${NC} %s\n" "$service" "ACTIVE" "$description"
                ((running++))
                ;;
            "enabled")
                printf "${YELLOW}%-25s${NC} ${YELLOW}%-10s${NC} %s\n" "$service" "ENABLED" "$description"
                ((enabled++))
                ;;
            "installed")
                printf "${BLUE}%-25s${NC} ${BLUE}%-10s${NC} %s\n" "$service" "INSTALLED" "$description"
                ((installed++))
                ;;
            *)
                printf "${GREEN}%-25s${NC} ${GREEN}%-10s${NC} %s\n" "$service" "N/A" "$description"
                ;;
        esac
    done
    
    echo ""
    echo -e "${BOLD}SUMMARY:${NC}"
    echo -e "  ${RED}● Active: $running${NC}"
    echo -e "  ${YELLOW}● Enabled: $enabled${NC}"
    echo -e "  ${BLUE}● Installed: $installed${NC}"
    echo ""
}

# ============================================================================
# MODE 1: AUTOMATIC
# ============================================================================

mode_automatic() {
    local -n services=$1
    
    echo -e "\n${GREEN}${BOLD}═══ AUTOMATIC MODE ═══${NC}"
    echo -e "Disabling all unnecessary services...\n"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  SIMULATION MODE - No changes will be made${NC}\n"
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
    echo -e "${BOLD}═══ RESULT ═══${NC}"
    echo -e "  ${GREEN}✓ Disabled: $success${NC}"
    echo -e "  ${RED}✗ Failed: $failed${NC}"
    echo -e "  ${BLUE}⊝ Skipped: $skipped${NC}"
    
    if [ "$DRY_RUN" = false ]; then
        echo -e "\n${YELLOW}💡 Restart the system to apply all changes${NC}"
    fi
}

# ============================================================================
# MODE 2: ADVANCED (by categories)
# ============================================================================

mode_advanced() {
    local -n services=$1
    
    echo -e "\n${YELLOW}${BOLD}═══ ADVANCED MODE ═══${NC}"
    echo -e "Select service categories to disable\n"
    
    # Categories
    declare -A categories
    categories["Web Servers"]="apache2 nginx"
    categories["Databases"]="mysql mariadb postgresql mongodb redis-server memcached"
    categories["Containers"]="docker containerd lxd snapd"
    categories["Printing"]="cups cups-browsed"
    categories["Bluetooth"]="bluetooth blueman-mechanism"
    categories["Sound/Audio"]="pulseaudio pipewire pipewire-pulse alsa-state alsa-restore"
    categories["Graphical Interface"]="gdm gdm3 lightdm sddm xdm"
    categories["Network"]="avahi-daemon ModemManager NetworkManager smbd nmbd nfs-server"
    categories["Email"]="postfix dovecot exim4"
    categories["Reports"]="apport whoopsie kerneloops"
    categories["Others"]="fwupd packagekit unattended-upgrades tracker tracker-miner-fs"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  SIMULATION MODE - No changes will be made${NC}\n"
    fi
    
    local i=1
    declare -A cat_index
    
    echo -e "${BOLD}Available categories:${NC}\n"
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
            echo -e "  ${CYAN}[$i]${NC} $cat (${RED}$active active${NC})"
        else
            echo -e "  ${CYAN}[$i]${NC} $cat (${GREEN}none active${NC})"
        fi
        cat_index[$i]="$cat"
        ((i++))
    done
    
    echo -e "\n  ${CYAN}[A]${NC} Select ALL"
    echo -e "  ${CYAN}[0]${NC} Exit"
    echo ""
    
    read -rp "Enter numbers separated by space (ex: 1 3 5) or 'A' for all: " selection
    
    if [ "$selection" = "0" ]; then
        echo "Exiting..."
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
                echo -e "  ${GREEN}✓${NC} Selected: $cat"
            fi
        done
    fi
    
    echo ""
    echo -e "${BOLD}Disabling selected services...${NC}\n"
    
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
    echo -e "${BOLD}═══ RESULT ═══${NC}"
    echo -e "  ${GREEN}✓ Disabled: $success${NC}"
    echo -e "  ${RED}✗ Failed: $failed${NC}"
}

# ============================================================================
# MODE 3: INTERACTIVE
# ============================================================================

mode_interactive() {
    local -n services=$1
    
    echo -e "\n${CYAN}${BOLD}═══ INTERACTIVE MODE ═══${NC}"
    echo -e "You will be asked about each active service\n"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  SIMULATION MODE - No changes will be made${NC}\n"
    fi
    
    echo -e "${BOLD}Keys:${NC}"
    echo -e "  ${GREEN}[Y/y/Enter]${NC} - Yes, disable"
    echo -e "  ${RED}[N/n]${NC}       - No, keep"
    echo -e "  ${YELLOW}[S/s]${NC}       - Skip all remaining"
    echo -e "  ${CYAN}[A/a]${NC}       - Disable all remaining"
    echo -e "  ${MAGENTA}[Q/q]${NC}       - Quit"
    echo ""
    
    local success=0
    local skipped=0
    local auto_yes=false
    
    for item in "${services[@]}"; do
        local service="${item%%:*}"
        local description="${item#*:}"
        local status
        status=$(get_service_status "$service")
        
        # Skip non-installed or already disabled services
        if [ "$status" = "not-found" ] || [ "$status" = "installed" ]; then
            continue
        fi
        
        # If auto_yes is active, disable automatically
        if [ "$auto_yes" = true ]; then
            if disable_service "$service" "$description"; then
                ((success++))
            fi
            continue
        fi
        
        echo ""
        echo -e "╭─────────────────────────────────────────────────────────────"
        echo -e "│ ${BOLD}Service:${NC} ${CYAN}$service${NC}"
        echo -e "│ ${BOLD}Status:${NC}  ${RED}$status${NC}"
        echo -e "│ ${BOLD}Description:${NC} $description"
        echo -e "╰─────────────────────────────────────────────────────────────"
        
        read -rp "  Disable this service? [Y/n/s/a/q]: " answer
        
        case ${answer,,} in
            ""|"y"|"sim"|"yes")
                if disable_service "$service" "$description"; then
                    ((success++))
                fi
                ;;
            "n"|"no")
                echo -e "  ${BLUE}⊘${NC} Keeping $service"
                ((skipped++))
                ;;
            "s"|"skip")
                echo -e "  ${YELLOW}⏭️  Skipping all remaining${NC}"
                break
                ;;
            "a"|"all")
                echo -e "  ${CYAN}⚡ Disabling all remaining${NC}"
                auto_yes=true
                if disable_service "$service" "$description"; then
                    ((success++))
                fi
                ;;
            "q"|"quit")
                echo -e "  ${MAGENTA}👋 Exiting...${NC}"
                break
                ;;
            *)
                echo -e "  ${BLUE}⊘${NC} Keeping $service (invalid response)"
                ((skipped++))
                ;;
        esac
    done
    
    echo ""
    echo -e "${BOLD}═══ RESULT ═══${NC}"
    echo -e "  ${GREEN}✓ Disabled: $success${NC}"
    echo -e "  ${BLUE}⊝ Kept: $skipped${NC}"
    
    if [ "$DRY_RUN" = false ] && [ $success -gt 0 ]; then
        echo -e "\n${YELLOW}💡 Restart the system to apply all changes${NC}"
    fi
}

# ============================================================================
# SYSTEM TYPE SELECTION
# ============================================================================

select_system_type() {
    echo -e "\n${BOLD}Select system type:${NC}\n"
    echo -e "  ${CYAN}[1]${NC} 🖥️  Desktop - Personal computer with graphical interface"
    echo -e "  ${CYAN}[2]${NC} 🖧  Server - Server without graphical interface"
    echo -e "  ${CYAN}[3]${NC} 📦 Container - Containerized environment (Docker/LXC)"
    echo ""
    
    read -rp "Choose [1-3]: " choice
    
    case $choice in
        1) SYSTEM_TYPE="desktop" ;;
        2) SYSTEM_TYPE="server" ;;
        3) SYSTEM_TYPE="container" ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            exit 1
            ;;
    esac
}

select_mode() {
    echo -e "\n${BOLD}Select operation mode:${NC}\n"
    echo -e "  ${GREEN}[1]${NC} ⚡ Automatic   - Disables all recommended services"
    echo -e "  ${YELLOW}[2]${NC} 🔧 Advanced     - Selects service categories"
    echo -e "  ${CYAN}[3]${NC} 💬 Interactive   - Asks for each service"
    echo ""
    
    read -rp "Choose [1-3]: " choice
    
    case $choice in
        1) MODE="automatic" ;;
        2) MODE="advanced" ;;
        3) MODE="interactive" ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            exit 1
            ;;
    esac
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local list_only=false
    
    # Process arguments
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
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_banner
    
    # If type not specified, ask
    if [ -z "$SYSTEM_TYPE" ]; then
        select_system_type
    fi
    
    # Select service array based on type
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
            echo -e "${RED}Invalid system type: $SYSTEM_TYPE${NC}"
            echo "Use: desktop, server or container"
            exit 1
            ;;
    esac
    
    # If only listing
    if [ "$list_only" = true ]; then
        case $SYSTEM_TYPE in
            "desktop") list_services DESKTOP_UNNECESSARY "DESKTOP" ;;
            "server"|"servidor") list_services SERVER_UNNECESSARY "SERVER" ;;
            "container"|"docker") list_services CONTAINER_UNNECESSARY "CONTAINER" ;;
        esac
        exit 0
    fi
    
    # Check root (except in dry-run)
    if [ "$DRY_RUN" = false ]; then
        check_root
    fi
    
    # If mode not specified, ask
    if [ -z "$MODE" ]; then
        select_mode
    fi
    
    # Log initial
    log "=== Starting Service Optimizer ==="
    log "System Type: $SYSTEM_TYPE"
    log "Mode: $MODE"
    log "Dry Run: $DRY_RUN"
    
    # Execute selected mode
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
            echo -e "${RED}Invalid mode: $MODE${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}📝 Log saved at: $LOG_FILE${NC}"
    log "=== Finished ==="
}

main "$@"
