#!/bin/bash

################################################################################
# SUDO PERMISSIONS CHECKER
# Script to verify and audit sudo permissions on the system
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
NC='\033[0m' # No Color

# Variables
REPORT_DIR="./sudo_reports"
REPORT_FILE="${REPORT_DIR}/sudo_audit_$(date +%Y%m%d_%H%M%S).html"
CSV_FILE="${REPORT_DIR}/sudo_audit_$(date +%Y%m%d_%H%M%S).csv"

################################################################################
# Functions
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
        print_error "This script must be run with sudo"
        exit 1
    fi
}

create_report_dir() {
    mkdir -p "${REPORT_DIR}"
    chmod 700 "${REPORT_DIR}"
}

# Check sudoers configuration
check_sudo_config() {
    print_header "Checking Sudoers Configuration"
    
    echo "" >> "$CSV_FILE"
    echo "=== SUDOERS CONFIGURATION ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    if [[ -f /etc/sudoers ]]; then
        print_success "File /etc/sudoers found"
        echo "sudoers_file,/etc/sudoers,present" >> "$CSV_FILE"
        
        # Check permissions
        local perms=$(stat -c "%a" /etc/sudoers 2>/dev/null || echo "N/A")
        if [[ "$perms" == "440" ]] || [[ "$perms" == "400" ]]; then
            print_success "Sudoers permissions correct: $perms"
            echo "sudoers_permissions,$perms,correct" >> "$CSV_FILE"
        else
            print_warning "Sudoers permissions may be insecure: $perms (expected: 440 or 400)"
            echo "sudoers_permissions,$perms,attention" >> "$CSV_FILE"
        fi
    else
        print_error "File /etc/sudoers not found"
        echo "sudoers_file,N/A,not_found" >> "$CSV_FILE"
    fi
}

# Check users with sudo access
check_sudo_users() {
    print_header "Checking Users with Sudo Access"
    
    echo "" >> "$CSV_FILE"
    echo "=== USERS WITH SUDO ACCESS ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    # Check sudo/wheel group
    if getent group sudo &>/dev/null; then
        local sudo_users=$(getent group sudo | cut -d: -f4)
        if [[ -n "$sudo_users" ]]; then
            print_success "Users in 'sudo' group: $sudo_users"
            echo "grupo_sudo,$sudo_users,present" >> "$CSV_FILE"
            
            # List each user
            IFS=',' read -ra USERS <<< "$sudo_users"
            for user in "${USERS[@]}"; do
                user=$(echo "$user" | xargs) # trim whitespace
                echo "sudo_user,$user,active" >> "$CSV_FILE"
            done
        else
            print_warning "No users in 'sudo' group"
            echo "grupo_sudo,empty,no_users" >> "$CSV_FILE"
        fi
    fi
}

# Check sudoers.d files
check_sudoers_d() {
    print_header "Checking /etc/sudoers.d Directory"
    
    echo "" >> "$CSV_FILE"
    echo "=== FILES IN /etc/sudoers.d ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    if [[ -d /etc/sudoers.d ]]; then
        print_success "Directory /etc/sudoers.d found"
        
        local file_count=$(ls -1 /etc/sudoers.d 2>/dev/null | wc -l)
        echo "total_arquivos,$file_count" >> "$CSV_FILE"
        
        if [[ $file_count -gt 0 ]]; then
            echo ""
            while IFS= read -r file; do
                local perms=$(stat -c "%a" "/etc/sudoers.d/$file" 2>/dev/null || echo "N/A")
                local owner=$(stat -c "%U:%G" "/etc/sudoers.d/$file" 2>/dev/null || echo "N/A")
                
                if [[ "$perms" == "440" ]] || [[ "$perms" == "400" ]]; then
                    print_success "[$file] Permissions: $perms, Owner: $owner"
                else
                    print_warning "[$file] Potentially insecure permissions: $perms"
                fi
                
                echo "sudoers_d_arquivo,$file,perms=$perms,owner=$owner" >> "$CSV_FILE"
            done < <(ls -1 /etc/sudoers.d 2>/dev/null)
        else
            print_warning "No custom files in /etc/sudoers.d"
        fi
    fi
}

# Check sudo log
check_sudo_log() {
    print_header "Checking Sudo Activity (last 10 records)"
    
    echo "" >> "$CSV_FILE"
    echo "=== RECENT SUDO ACTIVITY ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    if [[ -f /var/log/auth.log ]]; then
        local count=$(grep -c "sudo" /var/log/auth.log 2>/dev/null || echo "0")
        echo "total_registros_sudo,$count" >> "$CSV_FILE"
        
        print_success "Last sudo commands executed:"
        echo ""
        grep "sudo" /var/log/auth.log 2>/dev/null | tail -10 | while IFS= read -r line; do
            echo "  $line"
            echo "sudo_log,$(echo "$line" | sed 's/,/ /g')" >> "$CSV_FILE"
        done
    else
        print_warning "File /var/log/auth.log not found"
    fi
}

# Check password configuration
check_sudo_password() {
    print_header "Checking Sudo Authentication Settings"
    
    echo "" >> "$CSV_FILE"
    echo "=== AUTHENTICATION SETTINGS ===" >> "$CSV_FILE"
    echo "" >> "$CSV_FILE"
    
    # Check if NOPASSWD is configured
    if sudo -l 2>/dev/null | grep -q NOPASSWD; then
        print_warning "Active NOPASSWD configurations exist"
        echo "nopasswd,active,danger" >> "$CSV_FILE"
        sudo -l 2>/dev/null | grep NOPASSWD | while IFS= read -r line; do
            echo "  Command: $line"
            echo "nopasswd_command,$(echo "$line" | sed 's/,/ /g')" >> "$CSV_FILE"
        done
    else
        print_success "No NOPASSWD configuration detected"
        echo "nopasswd,inactive,secure" >> "$CSV_FILE"
    fi
}

# Generate HTML report
generate_html_report() {
    print_header "Generating HTML Report"
    
    cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sudo Audit Report</title>
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
            <h1>🔐 Sudo Audit Report</h1>
            <p class="timestamp">Generated on: <strong>TIMESTAMP_PLACEHOLDER</strong></p>
        </header>
        
        <div class="section">
            <h2>📋 Executive Summary</h2>
            <div class="check">
                <div class="icon success">✓</div>
                <div class="message">
                    <strong>Complete Audit</strong><br>
                    Detailed report of system sudo permissions and configurations
                </div>
            </div>
        </div>
        
        <div class="section">
            <h2>🔍 Technical Details</h2>
            <p><strong>System:</strong> Linux (Ubuntu)</p>
            <p><strong>Sudoers file:</strong> /etc/sudoers</p>
            <p><strong>Configuration directory:</strong> /etc/sudoers.d</p>
            <p><strong>Activity log:</strong> /var/log/auth.log</p>
        </div>
        
        <div class="section">
            <h2>📊 Recommendations</h2>
            <ul style="margin-left: 20px;">
                <li>Review sudo permissions regularly</li>
                <li>Avoid using NOPASSWD unless absolutely necessary</li>
                <li>Keep sudoers file permissions at 440 or 400</li>
                <li>Monitor sudo logs for suspicious activity</li>
                <li>Use /etc/sudoers.d for per-user/application configurations</li>
                <li>Restrict sudo commands to necessary ones (principle of least privilege)</li>
            </ul>
        </div>
        
        <footer>
            <p>Report automatically generated by SUDO PERMISSIONS CHECKER v1.0</p>
            <p>For more information: https://github.com/1985epma/checklist_linux</p>
        </footer>
    </div>
</body>
</html>
EOF
    
    # Replace timestamp
    sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%m\/%d\/%Y %H:%M:%S')/g" "$REPORT_FILE"
    
    print_success "HTML report generated: $REPORT_FILE"
}

# Main
main() {
    print_header "🔐 SUDO PERMISSIONS CHECKER"
    echo "Audit of sudo permissions and configurations"
    echo ""
    
    check_root
    create_report_dir
    
    # Initialize CSV
    echo "field,value,status" > "$CSV_FILE"
    
    # Execute checks
    check_sudo_config
    check_sudo_users
    check_sudoers_d
    check_sudo_log
    check_sudo_password
    
    # Generate reports
    generate_html_report
    
    print_header "✅ Audit Completed"
    echo ""
    print_success "HTML Report: $REPORT_FILE"
    print_success "CSV Report: $CSV_FILE"
    echo ""
    echo "Use the reports to audit and improve your system's sudo configurations."
}

# Execute main
main "$@"
