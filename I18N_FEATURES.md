# Sistema de Internacionalização (i18n) - Guia Completo

## 📋 Visão Geral

O sistema de internacionalização foi aprimorado com detecção automática de idioma e um dicionário comum de mensagens padronizadas para garantir consistência entre todos os scripts do projeto.

## 🌍 Idiomas Suportados

- **pt_BR** - Português (Brasil)
- **en_US** - English (United States)
- **es_ES** - Español (España)

## 🔍 Detecção Automática de Idioma com Override

### Ordem de Prioridade

O sistema detecta o idioma seguindo esta ordem de prioridade:

1. **`--lang`** (argumento de linha de comando)
2. **`CHECKLIST_LINUX_LANG`** (variável de ambiente)
3. **`LANG` / `LC_MESSAGES`** (configuração do sistema)
4. **`en_US`** (fallback padrão)

### Exemplos de Uso

#### 1. Forçar idioma via linha de comando

```bash
# Formato: --lang=IDIOMA
sudo ./corporate_sudo_configurator.sh --lang=pt_BR
sudo ./security_checklist.sh --lang=en_US
sudo ./service_optimizer.sh --lang=es_ES

# Formato alternativo: --lang IDIOMA
sudo ./corporate_sudo_configurator.sh --lang pt_BR
```

#### 2. Forçar idioma via variável de ambiente

```bash
# Definir para a sessão atual
export CHECKLIST_LINUX_LANG=pt_BR
sudo -E ./corporate_sudo_configurator.sh

# Definir apenas para um comando
CHECKLIST_LINUX_LANG=en_US sudo -E ./security_checklist.sh
```

#### 3. Usar detecção automática do sistema

```bash
# O script detectará automaticamente via LANG/LC_MESSAGES
sudo ./corporate_sudo_configurator.sh

# Verificar idioma do sistema
echo $LANG          # ex: pt_BR.UTF-8
echo $LC_MESSAGES   # ex: en_US.UTF-8
```

#### 4. Definir permanentemente

```bash
# Adicionar ao ~/.bashrc ou ~/.profile
echo 'export CHECKLIST_LINUX_LANG=pt_BR' >> ~/.bashrc
source ~/.bashrc
```

## 📚 Dicionário Comum de Mensagens

O sistema utiliza um dicionário padronizado para evitar traduções divergentes entre scripts.

### Mensagens Disponíveis

| Variável | pt_BR | en_US | es_ES |
|----------|-------|-------|-------|
| `MSG_OK` | OK | OK | OK |
| `MSG_SUCCESS` | Sucesso | Success | Éxito |
| `MSG_ERROR` | Erro | Error | Error |
| `MSG_WARNING` | Aviso | Warning | Advertencia |
| `MSG_CRITICAL` | Crítico | Critical | Crítico |
| `MSG_INFO` | Informação | Information | Información |
| `MSG_CHECKING` | Verificando | Checking | Verificando |
| `MSG_COMPLETE` | Completo | Complete | Completo |
| `MSG_FAILED` | Falhou | Failed | Fallido |
| `MSG_SKIPPED` | Ignorado | Skipped | Omitido |
| `MSG_YES` | Sim | Yes | Sí |
| `MSG_NO` | Não | No | No |
| `MSG_CONTINUE` | Continuar | Continue | Continuar |
| `MSG_CANCEL` | Cancelar | Cancel | Cancelar |
| `MSG_EXIT` | Sair | Exit | Salir |
| `MSG_LOADING` | Carregando | Loading | Cargando |
| `MSG_READY` | Pronto | Ready | Listo |
| `MSG_PROCESSING` | Processando | Processing | Procesando |
| `MSG_DONE` | Concluído | Done | Hecho |

## 🛠️ Como Usar em Seus Scripts

### 1. Importar o Sistema i18n

```bash
#!/bin/bash

# Detectar diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
I18N_FILE="${SCRIPT_DIR}/i18n/i18n.sh"

# Carregar sistema de i18n
if [[ -f "$I18N_FILE" ]]; then
    source "$I18N_FILE"
    init_i18n "$@"  # Passar todos os argumentos para detectar --lang
else
    echo "Error: i18n system not found"
    exit 1
fi
```

### 2. Usar Mensagens Padronizadas

```bash
# Usar variáveis de tradução diretamente
echo "$MSG_CHECKING sistema..."
echo "$MSG_SUCCESS: Operação concluída"
echo "$MSG_ERROR: Falha na operação"

# Acessar mensagens complexas
echo "$CORP_MENU_1"  # Menu corporativo
echo "$SEC_CHECKING_FIREWALL"  # Verificações de segurança
```

### 3. Usar Funções Helper com Cores

O sistema fornece funções helper que já incluem cores e formatação:

```bash
# Mensagens com status
print_ok "Sistema funcionando corretamente"
print_error "Falha ao conectar ao servidor"
print_warning "Configuração não encontrada, usando padrão"
print_critical "Erro crítico detectado!"
print_info "Versão do sistema: 2.0"

# Mensagens com ícones
print_success "Arquivo criado com sucesso"
print_fail "Falha ao criar arquivo"
print_checking "Verificando permissões..."

# Estrutura
print_header "Título do Script"
print_section "Seção de Configuração"
```

### Exemplo Completo

```bash
#!/bin/bash

set -euo pipefail

# Carregar i18n
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/i18n/i18n.sh"
init_i18n "$@"

# Usar o sistema
print_header "$SEC_TITLE"
print_section "$SEC_CHECKING_FIREWALL"

if systemctl is-active --quiet firewall; then
    print_success "$SEC_FIREWALL_ACTIVE"
else
    print_critical "$SEC_FIREWALL_INACTIVE"
fi

print_info "$MSG_DONE"
```

## 🎨 Funções de Formatação Disponíveis

### Mensagens com Status

- `print_ok "mensagem"` - [OK] em verde
- `print_error "mensagem"` - [Erro] em vermelho
- `print_warning "mensagem"` - [Aviso] em amarelo
- `print_critical "mensagem"` - [Crítico] em vermelho
- `print_info "mensagem"` - [Info] em azul
- `print_checking "mensagem"` - [Verificando] em ciano

### Mensagens com Ícones

- `print_success "mensagem"` - ✓ em verde
- `print_fail "mensagem"` - ✗ em vermelho

### Estrutura

- `print_header "título"` - Título com bordas decorativas
- `print_section "seção"` - Subtítulo com seta

## 📁 Estrutura de Arquivos

```
i18n/
├── i18n.sh       # Sistema principal de i18n
├── pt_BR.sh      # Traduções em português
├── en_US.sh      # Traduções em inglês
└── es_ES.sh      # Traduções em espanhol
```

## 🔧 Adicionar Novas Traduções

### 1. Editar os arquivos de tradução

Adicione sua nova mensagem nos três arquivos:

**i18n/pt_BR.sh:**
```bash
MINHA_MENSAGEM="Minha mensagem em português"
```

**i18n/en_US.sh:**
```bash
MINHA_MENSAGEM="My message in English"
```

**i18n/es_ES.sh:**
```bash
MINHA_MENSAGEM="Mi mensaje en español"
```

### 2. Usar no script

```bash
echo "$MINHA_MENSAGEM"
```

## 🧪 Testar o Sistema

```bash
# Testar com diferentes idiomas
sudo ./corporate_sudo_configurator.sh --lang=pt_BR
sudo ./corporate_sudo_configurator.sh --lang=en_US
sudo ./corporate_sudo_configurator.sh --lang=es_ES

# Testar detecção automática
LANG=pt_BR.UTF-8 sudo ./corporate_sudo_configurator.sh
LANG=en_US.UTF-8 sudo ./corporate_sudo_configurator.sh

# Verificar variável de ambiente
export CHECKLIST_LINUX_LANG=es_ES
sudo -E ./corporate_sudo_configurator.sh
```

## ⚠️ Notas Importantes

1. **Sempre passe `"$@"` para `init_i18n`** para habilitar o suporte a `--lang`
2. **Use `sudo -E`** quando precisar preservar variáveis de ambiente como `CHECKLIST_LINUX_LANG`
3. **Mensagens padronizadas** devem sempre usar as variáveis do dicionário comum
4. **Fallback**: Se um idioma não for encontrado, o sistema usa `en_US` automaticamente

## 📊 Benefícios do Sistema

✅ **Consistência**: Todas as mensagens comuns usam o mesmo dicionário  
✅ **Flexibilidade**: Múltiplas formas de definir o idioma  
✅ **Priorização**: Ordem clara de precedência  
✅ **Facilidade**: Funções helper prontas para uso  
✅ **Manutenibilidade**: Fácil adicionar novos idiomas ou mensagens  
✅ **Robustez**: Fallback automático para inglês  

## 🔄 Migração de Scripts Antigos

Para migrar um script existente:

1. Adicione o import do i18n no início
2. Substitua strings hardcoded por variáveis de tradução
3. Use funções helper em vez de `echo` com cores manualmente
4. Teste com diferentes idiomas

Exemplo de migração:

**Antes:**
```bash
echo -e "${GREEN}✓${NC} Sucesso"
echo -e "${RED}✗${NC} Erro"
```

**Depois:**
```bash
print_success "$MSG_SUCCESS"
print_fail "$MSG_ERROR"
```

## 📞 Suporte

Para adicionar novos idiomas ou mensagens, edite os arquivos em `i18n/` e siga as convenções existentes.
