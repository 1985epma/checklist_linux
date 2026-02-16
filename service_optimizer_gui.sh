#!/bin/bash

################################################################################
# EPMA Security Tools - Service Optimizer GUI
# Graphical interface with Zenity for service optimization
# Author: Everton Araujo
# Version: 1.0 GUI
# Date: 2026-01-13
################################################################################

set -euo pipefail

# Check if Zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "❌ Zenity is not installed!"
    echo "Install with: sudo apt install zenity"
    exit 1
fi

# Check root
if [[ $EUID -ne 0 ]]; then
    zenity --error --title="Permission Error" \
           --text="This script needs to be run with sudo:\n\nsudo $0" \
           --width=400
    exit 1
fi

# Global variables
SYSTEM_TYPE=""
MODE=""
DRY_RUN=false
LOG_FILE="service_optimizer_gui_$(date +%Y%m%d_%H%M%S).log"

################################################################################
# SERVICE DEFINITIONS
################################################################################

# Desktop Services
DESKTOP_SERVICES=(
    "FALSE" "apache2" "Apache web server"
    "FALSE" "nginx" "Nginx web server"
    "FALSE" "mysql" "MySQL database"
    "FALSE" "postgresql" "PostgreSQL database"
    "FALSE" "mongodb" "MongoDB database"
    "FALSE" "redis-server" "Redis cache"
    "FALSE" "docker" "Docker container"
    "FALSE" "containerd" "Container runtime"
    "FALSE" "sshd" "SSH server"
    "FALSE" "vsftpd" "FTP server"
    "FALSE" "smbd" "Samba (Windows sharing)"
    "FALSE" "cups" "Printing (if not using)"
    "FALSE" "bluetooth" "Bluetooth (if not using)"
    "FALSE" "avahi-daemon" "Network service discovery"
    "FALSE" "ModemManager" "Modem manager"
)

# Server Services
SERVER_SERVICES=(
    "FALSE" "gdm" "GNOME Display Manager"
    "FALSE" "gdm3" "GNOME Display Manager 3"
    "FALSE" "lightdm" "LightDM Display Manager"
    "FALSE" "pulseaudio" "PulseAudio audio server"
    "FALSE" "pipewire" "Pipewire audio server"
    "FALSE" "bluetooth" "Bluetooth"
    "FALSE" "cups" "Printing system"
    "FALSE" "avahi-daemon" "Service discovery"
    "FALSE" "whoopsie" "Ubuntu crash reports"
    "FALSE" "apport" "Error reports"
    "FALSE" "tracker-miner" "File indexer"
    "FALSE" "evolution-data-server" "Evolution server"
)

# Container Services
CONTAINER_SERVICES=(
    "FALSE" "systemd-journald" "Systemd journal"
    "FALSE" "systemd-udevd" "Device manager"
    "FALSE" "systemd-logind" "Login manager"
    "FALSE" "NetworkManager" "Network manager"
    "FALSE" "wpa_supplicant" "WPA Supplicant"
    "FALSE" "cron" "Cron scheduler"
    "FALSE" "rsyslog" "System logs"
    "FALSE" "dbus" "D-Bus (careful!)"
    "FALSE" "snapd" "Snap service"
)

################################################################################
# Interface Functions
################################################################################

show_welcome() {
    zenity --info \
        --title="🚀 Service Optimizer GUI" \
        --text="<big><b>System Service Optimizer</b></big>\n\nThis tool helps to remove or disable\nunnecessary services based on system type.\n\n<b>Available types:</b>\n• Desktop - Removes servers and network services\n• Server - Removes GUI and desktop services\n• Container - Optimizes for containerized environment\n\n<span foreground='red'><b>⚠️ Warning:</b> Always test in development environment first!</span>" \
        --width=550 \
        --height=350
}

select_system_type() {
    SYSTEM_TYPE=$(zenity --list \
        --title="Select System Type" \
        --text="What is your system type?" \
        --radiolist \
        --column="Sel" --column="Type" --column="Description" \
        TRUE "desktop" "Desktop/Workstation - Removes servers" \
        FALSE "server" "Server - Removes GUI and desktop" \
        FALSE "container" "Container - Extreme optimization" \
        --width=600 --height=300)
    
    if [[ -z "$SYSTEM_TYPE" ]]; then
        exit 0
    fi
}

select_services() {
    local services_array=()
    
    case "$SYSTEM_TYPE" in
        desktop)
            services_array=("${DESKTOP_SERVICES[@]}")
            ;;
        server)
            services_array=("${SERVER_SERVICES[@]}")
            ;;
        container)
            services_array=("${CONTAINER_SERVICES[@]}")
            ;;
    esac
    
    local selected
    selected=$(zenity --list \
        --title="Select Services to Disable" \
        --text="<b>System: ${SYSTEM_TYPE^^}</b>\n\nCheck the services you want to disable:" \
        --checklist \
        --column="Remove" --column="Service" --column="Description" \
        "${services_array[@]}" \
        --width=700 --height=500 \
        --separator="|")
    
    if [[ -z "$selected" ]]; then
        zenity --question \
            --title="No Service Selected" \
            --text="No service was selected.\n\nDo you want to return to menu?" \
            --width=400
        
        if [[ $? -eq 0 ]]; then
            return 1
        else
            exit 0
        fi
    fi
    
    echo "$selected"
}

confirm_action() {
    local services="$1"
    local count=$(echo "$services" | tr '|' '\n' | wc -l)
    
    zenity --question \
        --title="⚠️ Confirm Action" \
        --text="<big><b>Attention!</b></big>\n\nYou are about to disable <b>$count service(s)</b>:\n\n$(echo "$services" | tr '|' '\n' | sed 's/^/• /')\n\n<span foreground='red'><b>This action may affect system functionality!</b></span>\n\nDo you want to continue?" \
        --width=500 \
        --height=400 \
        --default-cancel
    
    return $?
}

process_services() {
    local services="$1"
    local total=$(echo "$services" | tr '|' '\n' | wc -l)
    local current=0
    local results=""
    
    # Create named pipe for progress
    local pipe=$(mktemp -u)
    mkfifo "$pipe"
    
    # Start progress dialog
    zenity --progress \
        --title="Processing Services" \
        --text="Initializing..." \
        --percentage=0 \
        --auto-close \
        --width=500 < "$pipe" &
    
    local zenity_pid=$!
    
    exec 3>"$pipe"
    
    # Process each service
    IFS='|' read -ra SERVICE_LIST <<< "$services"
    for service in "${SERVICE_LIST[@]}"; do
        current=$((current + 1))
        local percent=$((current * 100 / total))
        
        echo "$percent" >&3
        echo "# Processing: $service ($current of $total)" >&3
        
        # Check if service exists
        if systemctl list-unit-files | grep -q "^${service}"; then
            if $DRY_RUN; then
                results+="✓ [DRY-RUN] $service would be disabled\n"
            else
                if systemctl stop "$service" 2>/dev/null && systemctl disable "$service" 2>/dev/null; then
                    results+="✓ $service disabled successfully\n"
                    echo "$(date): Disabled $service" >> "$LOG_FILE"
                else
                    results+="⚠ $service: error disabling\n"
                    echo "$(date): Error disabling $service" >> "$LOG_FILE"
                fi
            fi
        else
            results+="ℹ $service: not found on system\n"
        fi
        
        sleep 0.2
    done
    
    echo "100" >&3
    echo "# Completed!" >&3
    
    exec 3>&-
    wait $zenity_pid 2>/dev/null
    rm -f "$pipe"
    
    # Show results
    zenity --text-info \
        --title="📊 Optimization Results" \
        --text="$results" \
        --width=600 \
        --height=400
    
    if [[ -f "$LOG_FILE" ]]; then
        zenity --info \
            --title="Log Saved" \
            --text="The log was saved at:\n\n<tt>$LOG_FILE</tt>" \
            --width=400
    fi
}

show_options_menu() {
    local choice
    choice=$(zenity --list \
        --title="Options" \
        --text="Choose an option:" \
        --radiolist \
        --column="" --column="Option" --column="Description" \
        TRUE "optimize" "Optimize system now" \
        FALSE "dry-run" "Simulate (dry-run) without changes" \
        FALSE "list" "List active services" \
        FALSE "exit" "Exit" \
        --width=500 --height=300)
    
    echo "$choice"
}

list_active_services() {
    local services_list
    services_list=$(systemctl list-units --type=service --state=running --no-pager --plain | \
                    awk '{print $1, $4}' | head -20)
    
    zenity --text-info \
        --title="📋 Active Services (top 20)" \
        --text="$services_list" \
        --width=600 \
        --height=500
}

################################################################################
# Main
################################################################################

main() {
    # Boas-vindas
    show_welcome
    
    while true; do
        # Select system type
        select_system_type
        
        if [[ -z "$SYSTEM_TYPE" ]]; then
            exit 0
        fi
        
        # Options menu
        local option
        option=$(show_options_menu)
        
        case "$option" in
            optimize|dry-run)
                if [[ "$option" == "dry-run" ]]; then
                    DRY_RUN=true
                    zenity --info \
                        --title="Simulation Mode" \
                        --text="<b>Dry-run mode activated</b>\n\nNo real changes will be made to the system." \
                        --width=400
                fi
                
                # Select services
                local selected_services
                selected_services=$(select_services)
                
                if [[ $? -ne 0 ]]; then
                    continue
                fi
                
                if [[ -n "$selected_services" ]]; then
                    # Confirm
                    if confirm_action "$selected_services"; then
                        # Process
                        process_services "$selected_services"
                        
                        # Ask if wants to continue
                        if ! zenity --question \
                            --title="Continue?" \
                            --text="Do you want to optimize another system type?" \
                            --width=400; then
                            break
                        fi
                    fi
                fi
                ;;
            
            list)
                list_active_services
                ;;
            
            exit|"")
                break
                ;;
        esac
    done
    
    zenity --info \
        --title="✅ Completed" \
        --text="Optimization completed!\n\nThank you for using Service Optimizer GUI." \
        --width=400
}

# Execute
main "$@"
