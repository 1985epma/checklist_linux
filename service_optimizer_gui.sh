#!/bin/bash

################################################################################
# EPMA Security Tools - Service Optimizer GUI
# Interface gráfica com Zenity para otimização de serviços
# Autor: Everton Araujo
# Versão: 1.0 GUI
# Data: 2026-01-13
################################################################################

set -euo pipefail

# Verificar se Zenity está instalado
if ! command -v zenity &> /dev/null; then
    echo "❌ Zenity não está instalado!"
    echo "Instale com: sudo apt install zenity"
    exit 1
fi

# Verificar root
if [[ $EUID -ne 0 ]]; then
    zenity --error --title="Erro de Permissão" \
           --text="Este script precisa ser executado com sudo:\n\nsudo $0" \
           --width=400
    exit 1
fi

# Variáveis globais
SYSTEM_TYPE=""
MODE=""
DRY_RUN=false
LOG_FILE="service_optimizer_gui_$(date +%Y%m%d_%H%M%S).log"

################################################################################
# DEFINIÇÃO DE SERVIÇOS
################################################################################

# Serviços Desktop
DESKTOP_SERVICES=(
    "FALSE" "apache2" "Servidor web Apache"
    "FALSE" "nginx" "Servidor web Nginx"
    "FALSE" "mysql" "Banco de dados MySQL"
    "FALSE" "postgresql" "Banco de dados PostgreSQL"
    "FALSE" "mongodb" "Banco de dados MongoDB"
    "FALSE" "redis-server" "Cache Redis"
    "FALSE" "docker" "Container Docker"
    "FALSE" "containerd" "Runtime de containers"
    "FALSE" "sshd" "Servidor SSH"
    "FALSE" "vsftpd" "Servidor FTP"
    "FALSE" "smbd" "Samba (compartilhamento Windows)"
    "FALSE" "cups" "Impressão (se não usar)"
    "FALSE" "bluetooth" "Bluetooth (se não usar)"
    "FALSE" "avahi-daemon" "Descoberta de serviços na rede"
    "FALSE" "ModemManager" "Gerenciador de modem"
)

# Serviços Server
SERVER_SERVICES=(
    "FALSE" "gdm" "GNOME Display Manager"
    "FALSE" "gdm3" "GNOME Display Manager 3"
    "FALSE" "lightdm" "LightDM Display Manager"
    "FALSE" "pulseaudio" "Servidor de áudio PulseAudio"
    "FALSE" "pipewire" "Servidor de áudio Pipewire"
    "FALSE" "bluetooth" "Bluetooth"
    "FALSE" "cups" "Sistema de impressão"
    "FALSE" "avahi-daemon" "Descoberta de serviços"
    "FALSE" "whoopsie" "Relatórios de crash Ubuntu"
    "FALSE" "apport" "Relatórios de erro"
    "FALSE" "tracker-miner" "Indexador de arquivos"
    "FALSE" "evolution-data-server" "Servidor Evolution"
)

# Serviços Container
CONTAINER_SERVICES=(
    "FALSE" "systemd-journald" "Journal do systemd"
    "FALSE" "systemd-udevd" "Gerenciador de dispositivos"
    "FALSE" "systemd-logind" "Gerenciador de login"
    "FALSE" "NetworkManager" "Gerenciador de rede"
    "FALSE" "wpa_supplicant" "WPA Supplicant"
    "FALSE" "cron" "Agendador cron"
    "FALSE" "rsyslog" "Sistema de logs"
    "FALSE" "dbus" "D-Bus (cuidado!)"
    "FALSE" "snapd" "Serviço Snap"
)

################################################################################
# Funções de Interface
################################################################################

show_welcome() {
    zenity --info \
        --title="🚀 Service Optimizer GUI" \
        --text="<big><b>Otimizador de Serviços do Sistema</b></big>\n\nEsta ferramenta ajuda a remover ou desabilitar\nserviços desnecessários baseado no tipo de sistema.\n\n<b>Tipos disponíveis:</b>\n• Desktop - Remove servidores e serviços de rede\n• Servidor - Remove GUI e serviços desktop\n• Container - Otimiza para ambiente containerizado\n\n<span foreground='red'><b>⚠️ Aviso:</b> Sempre teste em ambiente de desenvolvimento primeiro!</span>" \
        --width=550 \
        --height=350
}

select_system_type() {
    SYSTEM_TYPE=$(zenity --list \
        --title="Selecione o Tipo de Sistema" \
        --text="Qual é o tipo do seu sistema?" \
        --radiolist \
        --column="Sel" --column="Tipo" --column="Descrição" \
        TRUE "desktop" "Desktop/Workstation - Remove servidores" \
        FALSE "server" "Servidor - Remove GUI e desktop" \
        FALSE "container" "Container - Otimização extrema" \
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
        --title="Selecione os Serviços para Desabilitar" \
        --text="<b>Sistema: ${SYSTEM_TYPE^^}</b>\n\nMarque os serviços que deseja desabilitar:" \
        --checklist \
        --column="Remover" --column="Serviço" --column="Descrição" \
        "${services_array[@]}" \
        --width=700 --height=500 \
        --separator="|")
    
    if [[ -z "$selected" ]]; then
        zenity --question \
            --title="Nenhum Serviço Selecionado" \
            --text="Nenhum serviço foi selecionado.\n\nDeseja voltar ao menu?" \
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
        --title="⚠️ Confirmar Ação" \
        --text="<big><b>Atenção!</b></big>\n\nVocê está prestes a desabilitar <b>$count serviço(s)</b>:\n\n$(echo "$services" | tr '|' '\n' | sed 's/^/• /')\n\n<span foreground='red'><b>Esta ação pode afetar o funcionamento do sistema!</b></span>\n\nDeseja continuar?" \
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
    
    # Criar named pipe para progresso
    local pipe=$(mktemp -u)
    mkfifo "$pipe"
    
    # Iniciar dialog de progresso
    zenity --progress \
        --title="Processando Serviços" \
        --text="Inicializando..." \
        --percentage=0 \
        --auto-close \
        --width=500 < "$pipe" &
    
    local zenity_pid=$!
    
    exec 3>"$pipe"
    
    # Processar cada serviço
    IFS='|' read -ra SERVICE_LIST <<< "$services"
    for service in "${SERVICE_LIST[@]}"; do
        current=$((current + 1))
        local percent=$((current * 100 / total))
        
        echo "$percent" >&3
        echo "# Processando: $service ($current de $total)" >&3
        
        # Verificar se serviço existe
        if systemctl list-unit-files | grep -q "^${service}"; then
            if $DRY_RUN; then
                results+="✓ [DRY-RUN] $service seria desabilitado\n"
            else
                if systemctl stop "$service" 2>/dev/null && systemctl disable "$service" 2>/dev/null; then
                    results+="✓ $service desabilitado com sucesso\n"
                    echo "$(date): Desabilitado $service" >> "$LOG_FILE"
                else
                    results+="⚠ $service: erro ao desabilitar\n"
                    echo "$(date): Erro ao desabilitar $service" >> "$LOG_FILE"
                fi
            fi
        else
            results+="ℹ $service: não encontrado no sistema\n"
        fi
        
        sleep 0.2
    done
    
    echo "100" >&3
    echo "# Concluído!" >&3
    
    exec 3>&-
    wait $zenity_pid 2>/dev/null
    rm -f "$pipe"
    
    # Mostrar resultados
    zenity --text-info \
        --title="📊 Resultados da Otimização" \
        --text="$results" \
        --width=600 \
        --height=400
    
    if [[ -f "$LOG_FILE" ]]; then
        zenity --info \
            --title="Log Salvo" \
            --text="O log foi salvo em:\n\n<tt>$LOG_FILE</tt>" \
            --width=400
    fi
}

show_options_menu() {
    local choice
    choice=$(zenity --list \
        --title="Opções" \
        --text="Escolha uma opção:" \
        --radiolist \
        --column="" --column="Opção" --column="Descrição" \
        TRUE "optimize" "Otimizar sistema agora" \
        FALSE "dry-run" "Simular (dry-run) sem mudanças" \
        FALSE "list" "Listar serviços ativos" \
        FALSE "exit" "Sair" \
        --width=500 --height=300)
    
    echo "$choice"
}

list_active_services() {
    local services_list
    services_list=$(systemctl list-units --type=service --state=running --no-pager --plain | \
                    awk '{print $1, $4}' | head -20)
    
    zenity --text-info \
        --title="📋 Serviços Ativos (top 20)" \
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
        # Selecionar tipo de sistema
        select_system_type
        
        if [[ -z "$SYSTEM_TYPE" ]]; then
            exit 0
        fi
        
        # Menu de opções
        local option
        option=$(show_options_menu)
        
        case "$option" in
            optimize|dry-run)
                if [[ "$option" == "dry-run" ]]; then
                    DRY_RUN=true
                    zenity --info \
                        --title="Modo Simulação" \
                        --text="<b>Modo dry-run ativado</b>\n\nNenhuma mudança real será feita no sistema." \
                        --width=400
                fi
                
                # Selecionar serviços
                local selected_services
                selected_services=$(select_services)
                
                if [[ $? -ne 0 ]]; then
                    continue
                fi
                
                if [[ -n "$selected_services" ]]; then
                    # Confirmar
                    if confirm_action "$selected_services"; then
                        # Processar
                        process_services "$selected_services"
                        
                        # Perguntar se quer continuar
                        if ! zenity --question \
                            --title="Continuar?" \
                            --text="Deseja otimizar outro tipo de sistema?" \
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
        --title="✅ Concluído" \
        --text="Otimização concluída!\n\nObrigado por usar o Service Optimizer GUI." \
        --width=400
}

# Executar
main "$@"
