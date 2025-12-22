#!/bin/bash

# ============================================================================
# EPMA Security Tools - Security Checklist
# Autor: Everton Araujo
# Data: 2025-12-22
# Versão: 2.0
# 
# Descrição: Checklist de segurança para Ubuntu Linux com relatórios HTML/CSV
# ============================================================================

# Cores para output no terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis globais
REPORT_FORMAT="terminal"
OUTPUT_FILE=""
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HOSTNAME=$(hostname)
UBUNTU_VERSION=$(lsb_release -ds 2>/dev/null || echo "N/A")
CURRENT_DATE=$(date)

# Arrays para armazenar resultados
declare -a RESULTS=()

# Função de ajuda
show_help() {
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "Opções:"
    echo "  -f, --format FORMAT    Formato de saída: terminal (padrão), html, csv"
    echo "  -o, --output FILE      Arquivo de saída (padrão: report_TIMESTAMP.FORMAT)"
    echo "  -h, --help             Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0                           # Saída no terminal"
    echo "  $0 -f html                   # Gera relatório HTML"
    echo "  $0 -f csv -o relatorio.csv   # Gera relatório CSV personalizado"
    echo "  $0 --format html --output security_report.html"
}

# Processar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--format)
            REPORT_FORMAT="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Definir arquivo de saída padrão
if [ -z "$OUTPUT_FILE" ] && [ "$REPORT_FORMAT" != "terminal" ]; then
    OUTPUT_FILE="security_report_${TIMESTAMP}.${REPORT_FORMAT}"
fi

# Função para adicionar resultado
add_result() {
    local category="$1"
    local item="$2"
    local status="$3"  # OK, WARNING, CRITICAL, INFO
    local description="$4"
    local recommendation="$5"
    
    RESULTS+=("$category|$item|$status|$description|$recommendation")
}

# ============================================
# FUNÇÕES DE VERIFICAÇÃO
# ============================================

check_updates() {
    sudo apt update > /dev/null 2>&1
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -c '/')
    
    if [ "$UPDATES" -gt 0 ]; then
        if [ "$UPDATES" -gt 50 ]; then
            add_result "Sistema" "Atualizações" "CRITICAL" "$UPDATES pacotes desatualizados" "Execute: sudo apt upgrade"
        else
            add_result "Sistema" "Atualizações" "WARNING" "$UPDATES pacotes desatualizados" "Execute: sudo apt upgrade"
        fi
    else
        add_result "Sistema" "Atualizações" "OK" "Sistema atualizado" "-"
    fi
}

check_firewall() {
    if ! command -v ufw &> /dev/null; then
        add_result "Firewall" "UFW" "CRITICAL" "UFW não instalado" "Instale: sudo apt install ufw"
    else
        STATUS=$(sudo ufw status | grep Status | awk '{print $2}')
        if [ "$STATUS" = "active" ]; then
            RULES=$(sudo ufw status | grep -c "ALLOW\|DENY\|REJECT")
            add_result "Firewall" "UFW" "OK" "Ativo com $RULES regras" "-"
        else
            add_result "Firewall" "UFW" "CRITICAL" "Firewall inativo" "Ative: sudo ufw enable"
        fi
    fi
}

check_services() {
    SERVICES_COUNT=$(systemctl list-units --type=service --state=running --no-pager | grep -c "running")
    
    # Verificar serviços potencialmente perigosos
    DANGEROUS_SERVICES=("telnet" "ftp" "rsh" "rlogin")
    FOUND_DANGEROUS=""
    
    for service in "${DANGEROUS_SERVICES[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            FOUND_DANGEROUS="$FOUND_DANGEROUS $service"
        fi
    done
    
    if [ -n "$FOUND_DANGEROUS" ]; then
        add_result "Serviços" "Serviços Perigosos" "CRITICAL" "Encontrados:$FOUND_DANGEROUS" "Desative serviços inseguros"
    else
        add_result "Serviços" "Serviços Perigosos" "OK" "Nenhum serviço perigoso ativo" "-"
    fi
    
    add_result "Serviços" "Total Ativos" "INFO" "$SERVICES_COUNT serviços em execução" "Revise periodicamente"
}

check_users() {
    # Usuários com shell
    SHELL_USERS=$(awk -F: '$7 ~ /\/bin\/(bash|sh)$/{print $1}' /etc/passwd | tr '\n' ', ' | sed 's/,$//')
    SHELL_COUNT=$(awk -F: '$7 ~ /\/bin\/(bash|sh)$/{print $1}' /etc/passwd | wc -l)
    
    add_result "Usuários" "Com Shell" "INFO" "$SHELL_COUNT usuários: $SHELL_USERS" "Revise contas desnecessárias"
    
    # Usuários root-like
    ROOT_USERS=$(awk -F: '($3 == 0) {print $1}' /etc/passwd | tr '\n' ', ' | sed 's/,$//')
    ROOT_COUNT=$(awk -F: '($3 == 0) {print $1}' /etc/passwd | wc -l)
    
    if [ "$ROOT_COUNT" -gt 1 ]; then
        add_result "Usuários" "UID 0 (root)" "WARNING" "$ROOT_COUNT contas root: $ROOT_USERS" "Apenas root deveria ter UID 0"
    else
        add_result "Usuários" "UID 0 (root)" "OK" "Apenas root tem UID 0" "-"
    fi
    
    # Usuários sem senha
    NOPASS=$(sudo awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    if [ -n "$NOPASS" ]; then
        add_result "Usuários" "Sem Senha" "CRITICAL" "Contas sem senha: $NOPASS" "Defina senhas fortes"
    else
        add_result "Usuários" "Sem Senha" "OK" "Todas as contas têm senha" "-"
    fi
}

check_permissions() {
    local files=("/etc/passwd:644" "/etc/shadow:600" "/etc/ssh/sshd_config:600" "/etc/gshadow:600")
    
    for item in "${files[@]}"; do
        FILE="${item%%:*}"
        EXPECTED="${item##*:}"
        
        if [ -f "$FILE" ]; then
            PERMS=$(stat -c "%a" "$FILE")
            if [ "$PERMS" != "$EXPECTED" ]; then
                add_result "Permissões" "$FILE" "WARNING" "Atual: $PERMS (esperado: $EXPECTED)" "Execute: sudo chmod $EXPECTED $FILE"
            else
                add_result "Permissões" "$FILE" "OK" "Permissões corretas ($EXPECTED)" "-"
            fi
        else
            add_result "Permissões" "$FILE" "INFO" "Arquivo não encontrado" "-"
        fi
    done
}

check_ssh() {
    if [ ! -f /etc/ssh/sshd_config ]; then
        add_result "SSH" "Instalação" "INFO" "SSH não instalado" "-"
        return
    fi
    
    # PermitRootLogin
    PERMIT_ROOT=$(grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
    if [ "$PERMIT_ROOT" = "yes" ]; then
        add_result "SSH" "PermitRootLogin" "CRITICAL" "Login root habilitado" "Desative em /etc/ssh/sshd_config"
    elif [ -z "$PERMIT_ROOT" ]; then
        add_result "SSH" "PermitRootLogin" "WARNING" "Não configurado (padrão pode ser inseguro)" "Configure explicitamente como 'no'"
    else
        add_result "SSH" "PermitRootLogin" "OK" "Valor: $PERMIT_ROOT" "-"
    fi
    
    # PasswordAuthentication
    PASSWORD_AUTH=$(grep "^PasswordAuthentication" /etc/ssh/sshd_config | awk '{print $2}')
    if [ "$PASSWORD_AUTH" = "yes" ]; then
        add_result "SSH" "PasswordAuthentication" "WARNING" "Autenticação por senha ativa" "Considere usar apenas chaves SSH"
    elif [ -z "$PASSWORD_AUTH" ]; then
        add_result "SSH" "PasswordAuthentication" "INFO" "Usando configuração padrão" "Configure explicitamente"
    else
        add_result "SSH" "PasswordAuthentication" "OK" "Valor: $PASSWORD_AUTH" "-"
    fi
    
    # Porta SSH
    SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')
    if [ -z "$SSH_PORT" ] || [ "$SSH_PORT" = "22" ]; then
        add_result "SSH" "Porta" "INFO" "Usando porta padrão (22)" "Considere mudar para porta alternativa"
    else
        add_result "SSH" "Porta" "OK" "Porta alternativa: $SSH_PORT" "-"
    fi
}

check_malware() {
    if command -v rkhunter &> /dev/null; then
        WARNINGS=$(sudo rkhunter --check --skip-keypress --quiet 2>/dev/null | grep -c "Warning")
        if [ "$WARNINGS" -gt 0 ]; then
            add_result "Malware" "rkhunter" "WARNING" "$WARNINGS avisos encontrados" "Execute: sudo rkhunter --check para detalhes"
        else
            add_result "Malware" "rkhunter" "OK" "Nenhum problema detectado" "-"
        fi
    else
        add_result "Malware" "rkhunter" "INFO" "rkhunter não instalado" "Instale: sudo apt install rkhunter"
    fi
    
    if command -v clamav &> /dev/null; then
        add_result "Malware" "ClamAV" "OK" "ClamAV instalado" "-"
    else
        add_result "Malware" "ClamAV" "INFO" "ClamAV não instalado" "Instale: sudo apt install clamav"
    fi
}

check_network() {
    # Portas abertas
    LISTENING=$(ss -tuln | grep LISTEN | wc -l)
    add_result "Rede" "Portas Abertas" "INFO" "$LISTENING portas em escuta" "Revise com: ss -tuln"
    
    # IPv6
    if [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
        IPV6_DISABLED=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)
        if [ "$IPV6_DISABLED" = "1" ]; then
            add_result "Rede" "IPv6" "OK" "IPv6 desabilitado" "-"
        else
            add_result "Rede" "IPv6" "INFO" "IPv6 habilitado" "Desabilite se não usar"
        fi
    fi
}

# ============================================
# FUNÇÕES DE OUTPUT
# ============================================

output_terminal() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      🛡️  CHECKLIST DE SEGURANÇA - UBUNTU LINUX  🛡️           ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "📅 Data/Hora: ${CURRENT_DATE}"
    echo -e "🖥️  Hostname: ${HOSTNAME}"
    echo -e "🐧 Sistema: ${UBUNTU_VERSION}"
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    
    local current_category=""
    
    for result in "${RESULTS[@]}"; do
        IFS='|' read -r category item status description recommendation <<< "$result"
        
        if [ "$category" != "$current_category" ]; then
            current_category="$category"
            echo ""
            echo -e "${BLUE}📁 ${category}${NC}"
            echo -e "${BLUE}────────────────────────────────────────${NC}"
        fi
        
        case $status in
            "OK")       status_icon="${GREEN}✅ OK${NC}" ;;
            "WARNING")  status_icon="${YELLOW}⚠️  WARNING${NC}" ;;
            "CRITICAL") status_icon="${RED}❌ CRITICAL${NC}" ;;
            "INFO")     status_icon="${BLUE}ℹ️  INFO${NC}" ;;
        esac
        
        echo -e "  ${status_icon} | ${item}"
        echo -e "      └─ ${description}"
        if [ "$recommendation" != "-" ]; then
            echo -e "      └─ 💡 ${recommendation}"
        fi
    done
    
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    
    # Resumo
    local ok_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|OK|")
    local warn_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|WARNING|")
    local crit_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|CRITICAL|")
    local info_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|INFO|")
    
    echo ""
    echo -e "${BLUE}📊 RESUMO${NC}"
    echo -e "  ${GREEN}✅ OK: $ok_count${NC} | ${YELLOW}⚠️  Avisos: $warn_count${NC} | ${RED}❌ Críticos: $crit_count${NC} | ${BLUE}ℹ️  Info: $info_count${NC}"
    echo ""
}

output_html() {
    local ok_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|OK|")
    local warn_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|WARNING|")
    local crit_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|CRITICAL|")
    local info_count=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|INFO|")
    
    cat > "$OUTPUT_FILE" << 'HTMLHEADER'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Checklist Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a2e; color: #eee; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header .info { display: flex; justify-content: center; gap: 30px; flex-wrap: wrap; margin-top: 20px; }
        .header .info span { background: rgba(255,255,255,0.2); padding: 8px 15px; border-radius: 20px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .summary-card { padding: 25px; border-radius: 12px; text-align: center; }
        .summary-card.ok { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); }
        .summary-card.warning { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .summary-card.critical { background: linear-gradient(135deg, #eb3349 0%, #f45c43 100%); }
        .summary-card.info { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
        .summary-card h3 { font-size: 3em; }
        .summary-card p { font-size: 1.2em; opacity: 0.9; }
        .category { background: #16213e; border-radius: 12px; margin-bottom: 20px; overflow: hidden; }
        .category-header { background: #0f3460; padding: 15px 20px; font-size: 1.3em; font-weight: bold; }
        .category-header::before { content: '📁 '; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #0f3460; }
        th { background: #0f3460; font-weight: 600; }
        tr:hover { background: #1f4068; }
        .status { padding: 5px 12px; border-radius: 20px; font-weight: bold; font-size: 0.85em; }
        .status.ok { background: #38ef7d; color: #000; }
        .status.warning { background: #ffc107; color: #000; }
        .status.critical { background: #f45c43; color: #fff; }
        .status.info { background: #4facfe; color: #000; }
        .recommendation { color: #ffc107; font-style: italic; font-size: 0.9em; }
        .footer { text-align: center; padding: 30px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Security Checklist Report</h1>
            <p>Relatório de Segurança do Sistema</p>
            <div class="info">
HTMLHEADER

    echo "                <span>📅 $CURRENT_DATE</span>" >> "$OUTPUT_FILE"
    echo "                <span>🖥️ $HOSTNAME</span>" >> "$OUTPUT_FILE"
    echo "                <span>🐧 $UBUNTU_VERSION</span>" >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << HTMLSUMMARY
            </div>
        </div>
        
        <div class="summary">
            <div class="summary-card ok"><h3>$ok_count</h3><p>✅ OK</p></div>
            <div class="summary-card warning"><h3>$warn_count</h3><p>⚠️ Avisos</p></div>
            <div class="summary-card critical"><h3>$crit_count</h3><p>❌ Críticos</p></div>
            <div class="summary-card info"><h3>$info_count</h3><p>ℹ️ Info</p></div>
        </div>
HTMLSUMMARY

    local current_category=""
    local table_open=false
    
    for result in "${RESULTS[@]}"; do
        IFS='|' read -r category item status description recommendation <<< "$result"
        
        if [ "$category" != "$current_category" ]; then
            if [ "$table_open" = true ]; then
                echo "            </table></div>" >> "$OUTPUT_FILE"
            fi
            current_category="$category"
            echo "        <div class=\"category\">" >> "$OUTPUT_FILE"
            echo "            <div class=\"category-header\">$category</div>" >> "$OUTPUT_FILE"
            echo "            <table>" >> "$OUTPUT_FILE"
            echo "                <tr><th>Item</th><th>Status</th><th>Descrição</th><th>Recomendação</th></tr>" >> "$OUTPUT_FILE"
            table_open=true
        fi
        
        local status_class=$(echo "$status" | tr '[:upper:]' '[:lower:]')
        echo "                <tr>" >> "$OUTPUT_FILE"
        echo "                    <td><strong>$item</strong></td>" >> "$OUTPUT_FILE"
        echo "                    <td><span class=\"status $status_class\">$status</span></td>" >> "$OUTPUT_FILE"
        echo "                    <td>$description</td>" >> "$OUTPUT_FILE"
        if [ "$recommendation" != "-" ]; then
            echo "                    <td class=\"recommendation\">💡 $recommendation</td>" >> "$OUTPUT_FILE"
        else
            echo "                    <td>-</td>" >> "$OUTPUT_FILE"
        fi
        echo "                </tr>" >> "$OUTPUT_FILE"
    done
    
    if [ "$table_open" = true ]; then
        echo "            </table></div>" >> "$OUTPUT_FILE"
    fi
    
    cat >> "$OUTPUT_FILE" << 'HTMLFOOTER'
        
        <div class="footer">
            <p>Relatório gerado por Security Checklist Script v2.0</p>
            <p>🔒 Mantenha seu sistema seguro!</p>
        </div>
    </div>
</body>
</html>
HTMLFOOTER

    echo -e "${GREEN}✅ Relatório HTML gerado: ${OUTPUT_FILE}${NC}"
}

output_csv() {
    # Header
    echo "Categoria,Item,Status,Descrição,Recomendação,Data,Hostname,Sistema" > "$OUTPUT_FILE"
    
    for result in "${RESULTS[@]}"; do
        IFS='|' read -r category item status description recommendation <<< "$result"
        # Escapar aspas duplas e envolver campos com vírgulas
        description=$(echo "$description" | sed 's/"/""/g')
        recommendation=$(echo "$recommendation" | sed 's/"/""/g')
        echo "\"$category\",\"$item\",\"$status\",\"$description\",\"$recommendation\",\"$CURRENT_DATE\",\"$HOSTNAME\",\"$UBUNTU_VERSION\"" >> "$OUTPUT_FILE"
    done
    
    echo -e "${GREEN}✅ Relatório CSV gerado: ${OUTPUT_FILE}${NC}"
}

# ============================================
# EXECUÇÃO PRINCIPAL
# ============================================

main() {
    echo -e "${BLUE}🔍 Executando verificações de segurança...${NC}"
    echo ""
    
    check_updates
    check_firewall
    check_services
    check_users
    check_permissions
    check_ssh
    check_malware
    check_network
    
    case $REPORT_FORMAT in
        "terminal")
            output_terminal
            ;;
        "html")
            output_html
            ;;
        "csv")
            output_csv
            ;;
        *)
            echo -e "${RED}Formato desconhecido: $REPORT_FORMAT${NC}"
            echo "Use: terminal, html ou csv"
            exit 1
            ;;
    esac
}

main

