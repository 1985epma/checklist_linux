#!/bin/bash

################################################################################
# SUDO PERMISSIONS CHECKER
# Script para verificar e auditar permissões de sudo no sistema
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
NC='\033[0m' # No Color

# Variáveis
REPORT_DIR="./sudo_reports"
REPORT_FILE="${REPORT_DIR}/sudo_audit_$(date +%Y%m%d_%H%M%S).html"
CSV_FILE="${REPORT_DIR}/sudo_audit_$(date +%Y%m%d_%H%M%S).csv"

################################################################################
# Funções
################################################################################

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script deve ser executado com sudo"
        exit 1
    fi
}

create_report_dir() {
    mkdir -p "${REPORT_DIR}"
    chmod 700 "${REPORT_DIR}"
}

# Verificar configuração do sudo
check_sudo_config() {
    print_header "Verificando Configuração do Sudoers"
    
    echo "" >> "$CSV_FILE"
    echo "=== CONFIGURAÇÃO DO SUDOERS ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    if [[ -f /etc/sudoers ]]; then
        print_success "Arquivo /etc/sudoers encontrado"
        echo "sudoers_file,/etc/sudoers,presente" >> "$CSV_FILE"
        
        # Verificar permissões
        local perms=$(stat -c "%a" /etc/sudoers 2>/dev/null || echo "N/A")
        if [[ "$perms" == "440" ]] || [[ "$perms" == "400" ]]; then
            print_success "Permissões do sudoers corretas: $perms"
            echo "sudoers_permissions,$perms,correto" >> "$CSV_FILE"
        else
            print_warning "Permissões do sudoers podem ser inseguras: $perms (esperado: 440 ou 400)"
            echo "sudoers_permissions,$perms,atencao" >> "$CSV_FILE"
        fi
    else
        print_error "Arquivo /etc/sudoers não encontrado"
        echo "sudoers_file,N/A,nao_encontrado" >> "$CSV_FILE"
    fi
}

# Verificar usuários com acesso sudo
check_sudo_users() {
    print_header "Verificando Usuários com Acesso Sudo"
    
    echo "" >> "$CSV_FILE"
    echo "=== USUÁRIOS COM ACESSO SUDO ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    # Verificar grupo sudo/wheel
    if getent group sudo &>/dev/null; then
        local sudo_users=$(getent group sudo | cut -d: -f4)
        if [[ -n "$sudo_users" ]]; then
            print_success "Usuários no grupo 'sudo': $sudo_users"
            echo "grupo_sudo,$sudo_users,presente" >> "$CSV_FILE"
            
            # Listar cada usuário
            IFS=',' read -ra USERS <<< "$sudo_users"
            for user in "${USERS[@]}"; do
                user=$(echo "$user" | xargs) # trim whitespace
                echo "usuario_sudo,$user,ativo" >> "$CSV_FILE"
            done
        else
            print_warning "Nenhum usuário no grupo 'sudo'"
            echo "grupo_sudo,vazio,sem_usuarios" >> "$CSV_FILE"
        fi
    fi
}

# Verificar arquivos sudoers.d
check_sudoers_d() {
    print_header "Verificando Diretório /etc/sudoers.d"
    
    echo "" >> "$CSV_FILE"
    echo "=== ARQUIVOS EM /etc/sudoers.d ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    if [[ -d /etc/sudoers.d ]]; then
        print_success "Diretório /etc/sudoers.d encontrado"
        
        local file_count=$(ls -1 /etc/sudoers.d 2>/dev/null | wc -l)
        echo "total_arquivos,$file_count" >> "$CSV_FILE"
        
        if [[ $file_count -gt 0 ]]; then
            echo ""
            while IFS= read -r file; do
                local perms=$(stat -c "%a" "/etc/sudoers.d/$file" 2>/dev/null || echo "N/A")
                local owner=$(stat -c "%U:%G" "/etc/sudoers.d/$file" 2>/dev/null || echo "N/A")
                
                if [[ "$perms" == "440" ]] || [[ "$perms" == "400" ]]; then
                    print_success "[$file] Permissões: $perms, Dono: $owner"
                else
                    print_warning "[$file] Permissões potencialmente inseguras: $perms"
                fi
                
                echo "sudoers_d_arquivo,$file,perms=$perms,owner=$owner" >> "$CSV_FILE"
            done < <(ls -1 /etc/sudoers.d 2>/dev/null)
        else
            print_warning "Nenhum arquivo personalizado em /etc/sudoers.d"
        fi
    fi
}

# Verificar histórico de sudo
check_sudo_log() {
    print_header "Verificando Atividade de Sudo (últimos 10 registros)"
    
    echo "" >> "$CSV_FILE"
    echo "=== ATIVIDADE RECENTE DE SUDO ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    if [[ -f /var/log/auth.log ]]; then
        local count=$(grep -c "sudo" /var/log/auth.log 2>/dev/null || echo "0")
        echo "total_registros_sudo,$count" >> "$CSV_FILE"
        
        print_success "Últimos comandos sudo executados:"
        echo ""
        grep "sudo" /var/log/auth.log 2>/dev/null | tail -10 | while IFS= read -r line; do
            echo "  $line"
            echo "sudo_log,$(echo "$line" | sed 's/,/ /g')" >> "$CSV_FILE"
        done
    else
        print_warning "Arquivo /var/log/auth.log não encontrado"
    fi
}

# Verificar configuração de password
check_sudo_password() {
    print_header "Verificando Configurações de Autenticação Sudo"
    
    echo "" >> "$CSV_FILE"
    echo "=== CONFIGURAÇÕES DE AUTENTICAÇÃO ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    # Verificar se NOPASSWD está configurado
    if sudo -l 2>/dev/null | grep -q NOPASSWD; then
        print_warning "Existem configurações NOPASSWD ativas"
        echo "nopasswd,ativo,perigo" >> "$CSV_FILE"
        sudo -l 2>/dev/null | grep NOPASSWD | while IFS= read -r line; do
            echo "  Comando: $line"
            echo "nopasswd_comando,$(echo "$line" | sed 's/,/ /g')" >> "$CSV_FILE"
        done
    else
        print_success "Nenhuma configuração NOPASSWD detectada"
        echo "nopasswd,inativo,seguro" >> "$CSV_FILE"
    fi
}

# Gerar relatório HTML
generate_html_report() {
    print_header "Gerando Relatório HTML"
    
    cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Auditoria Sudo</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
        }
        header {
            text-align: center;
            margin-bottom: 40px;
            border-bottom: 3px solid #667eea;
            padding-bottom: 20px;
        }
        h1 { color: #667eea; font-size: 2.5em; margin-bottom: 10px; }
        .timestamp { color: #999; font-size: 0.9em; }
        .section {
            margin: 30px 0;
            padding: 20px;
            background: #f8f9fa;
            border-left: 5px solid #667eea;
            border-radius: 5px;
        }
        .section h2 { color: #667eea; margin-bottom: 15px; font-size: 1.5em; }
        .check {
            display: flex;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #ddd;
        }
        .check:last-child { border-bottom: none; }
        .icon {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            font-weight: bold;
            color: white;
            font-size: 1.2em;
        }
        .success { background: #27ae60; }
        .warning { background: #f39c12; }
        .error { background: #e74c3c; }
        .info { background: #3498db; }
        .message { flex: 1; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #667eea;
            color: white;
            font-weight: bold;
        }
        tr:hover { background: #f5f5f5; }
        footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #ddd;
            color: #999;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🔐 Relatório de Auditoria Sudo</h1>
            <p class="timestamp">Gerado em: <strong>TIMESTAMP_PLACEHOLDER</strong></p>
        </header>
        
        <div class="section">
            <h2>📋 Resumo Executivo</h2>
            <div class="check">
                <div class="icon success">✓</div>
                <div class="message">
                    <strong>Auditoria Completa</strong><br>
                    Relatório detalhado de permissões e configurações de sudo do sistema
                </div>
            </div>
        </div>
        
        <div class="section">
            <h2>🔍 Detalhes Técnicos</h2>
            <p><strong>Sistema:</strong> Linux (Ubuntu)</p>
            <p><strong>Arquivo sudoers:</strong> /etc/sudoers</p>
            <p><strong>Diretório de configuração:</strong> /etc/sudoers.d</p>
            <p><strong>Log de atividade:</strong> /var/log/auth.log</p>
        </div>
        
        <div class="section">
            <h2>📊 Recomendações</h2>
            <ul style="margin-left: 20px;">
                <li>Revise regularmente as permissões de sudo</li>
                <li>Evite usar NOPASSWD a menos que absolutamente necessário</li>
                <li>Mantenha permissões do arquivo sudoers em 440 ou 400</li>
                <li>Monitore logs de sudo para atividades suspeitas</li>
                <li>Use /etc/sudoers.d para configurações por usuário/aplicação</li>
                <li>Restrinja comandos sudo aos necessários (princípio do menor privilégio)</li>
            </ul>
        </div>
        
        <footer>
            <p>Relatório gerado automaticamente pelo SUDO PERMISSIONS CHECKER v1.0</p>
            <p>Para mais informações: https://github.com/1985epma/checklist_linux</p>
        </footer>
    </div>
</body>
</html>
EOF
    
    # Substituir timestamp
    sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%d\/%m\/%Y %H:%M:%S')/g" "$REPORT_FILE"
    
    print_success "Relatório HTML gerado: $REPORT_FILE"
}

# Main
main() {
    print_header "🔐 SUDO PERMISSIONS CHECKER"
    echo "Auditoria de permissões e configurações de sudo"
    echo ""
    
    check_root
    create_report_dir
    
    # Inicializar CSV
    echo "campo,valor,status" > "$CSV_FILE"
    
    # Executar verificações
    check_sudo_config
    check_sudo_users
    check_sudoers_d
    check_sudo_log
    check_sudo_password
    
    # Gerar relatórios
    generate_html_report
    
    print_header "✅ Auditoria Concluída"
    echo ""
    print_success "Relatório HTML: $REPORT_FILE"
    print_success "Relatório CSV: $CSV_FILE"
    echo ""
    echo "Use os relatórios para auditar e melhorar as configurações de sudo do seu sistema."
}

# Executar main
main "$@"
