# 🌍 Sistema de Internacionalização (i18n)

Sistema completo de internacionalização para os scripts do projeto, suportando múltiplos idiomas.

## 📋 Idiomas Suportados

| Código | Idioma | Status |
|--------|--------|--------|
| `pt_BR` | Português (Brasil) | ✅ Completo |
| `en_US` | English (United States) | ✅ Completo |
| `es_ES` | Español (España) | ✅ Completo |

## 🚀 Início Rápido

### Demo Interativa

Execute o script de demonstração para ver o sistema em ação:

```bash
# Detectar idioma automaticamente
./i18n_demo.sh

# Escolher idioma manualmente
./i18n_demo.sh --select-lang

# Ver informações do idioma
./i18n_demo.sh --info
```

## 📖 Como Usar em Seus Scripts

### 1. Carregar a Biblioteca

```bash
#!/bin/bash

# Carregar biblioteca i18n
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/i18n/i18n.sh"
```

### 2. Inicializar o Idioma

```bash
# Opção 1: Detecção automática (baseado no sistema)
init_i18n true

# Opção 2: Menu de seleção para o usuário
init_i18n false
```

### 3. Usar as Traduções

```bash
# Usar a função translate
echo "$(translate SEC_TITLE)"
echo "$(translate MSG_SUCCESS)"

# Ou usar o alias 't' (mais curto)
echo "$(t SEC_CHECKING_UPDATES)"
echo "$(t MSG_ERROR)"
```

## 📚 Exemplo Completo

```bash
#!/bin/bash
set -euo pipefail

# Carregar i18n
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/i18n/i18n.sh"

# Inicializar (detectar automaticamente)
init_i18n true

# Usar traduções
echo "═══════════════════════════════════════"
echo "$(translate SEC_TITLE)"
echo "═══════════════════════════════════════"
echo ""
echo "$(translate SEC_CHECKING_UPDATES)..."
echo "✓ $(translate SEC_SYSTEM_UPDATED)"
echo ""
echo "$(translate SEC_CHECKING_FIREWALL)..."
echo "✓ $(translate SEC_FIREWALL_ACTIVE)"
```

## 🔧 Funções Disponíveis

### `init_i18n [auto_detect]`
Inicializa o sistema de i18n.
- `auto_detect=true` (padrão): Detecta idioma do sistema
- `auto_detect=false`: Mostra menu de seleção

```bash
init_i18n true   # Detecção automática
init_i18n false  # Menu de seleção
```

### `translate <key>` ou `t <key>`
Retorna a tradução para a chave especificada.

```bash
translate MSG_SUCCESS  # Retorna: "Sucesso" (pt_BR)
t MSG_ERROR           # Retorna: "Erro" (pt_BR)
```

### `load_language <lang>`
Carrega um idioma específico.

```bash
load_language "en_US"  # Carregar inglês
load_language "es_ES"  # Carregar espanhol
load_language "pt_BR"  # Carregar português
```

### `select_language_menu`
Mostra menu interativo de seleção de idioma.

```bash
select_language_menu
```

### `get_current_language_name`
Retorna o nome do idioma atual.

```bash
echo "Idioma: $(get_current_language_name)"
# Saída: Idioma: Português (Brasil)
```

### `list_available_languages`
Lista todos os idiomas disponíveis.

```bash
list_available_languages
# Saída:
# pt_BR: Português (Brasil)
# en_US: English
# es_ES: Español
```

### `is_language_loaded`
Verifica se um idioma foi carregado.

```bash
if is_language_loaded; then
    echo "Idioma carregado com sucesso"
fi
```

## 📝 Categorias de Mensagens

### Mensagens Gerais
```bash
MSG_SUCCESS      # Sucesso / Success / Éxito
MSG_ERROR        # Erro / Error / Error
MSG_WARNING      # Aviso / Warning / Advertencia
MSG_INFO         # Informação / Information / Información
MSG_CHECKING     # Verificando / Checking / Verificando
MSG_YES          # Sim / Yes / Sí
MSG_NO           # Não / No / No
```

### Menu
```bash
MENU_TITLE       # Menu Principal
MENU_SELECT      # Selecione uma opção
MENU_INVALID     # Opção inválida
MENU_PRESS_KEY   # Pressione qualquer tecla...
```

### Security Checklist
```bash
SEC_TITLE                  # Checklist de Segurança
SEC_CHECKING_UPDATES       # Verificando atualizações
SEC_CHECKING_FIREWALL      # Verificando firewall
SEC_FIREWALL_ACTIVE        # Firewall está ativo
SEC_SSH_ROOT_DISABLED      # Login SSH root desabilitado
```

### Service Optimizer
```bash
SRV_TITLE                  # Otimizador de Serviços
SRV_SELECT_TYPE            # Selecione o tipo de sistema
SRV_TYPE_DESKTOP           # Desktop
SRV_TYPE_SERVER            # Servidor
SRV_OPTIMIZATION_COMPLETE  # Otimização completa
```

### Sudo Permissions
```bash
SUDO_TITLE                 # Verificador de Permissões Sudo
SUDO_CHECKING_CONFIG       # Verificando configuração
SUDO_FILE_FOUND            # Arquivo sudoers encontrado
SUDO_PERMS_CORRECT         # Permissões corretas
```

### Corporate Sudo
```bash
CORP_TITLE                 # Configurador Sudo Corporativo
CORP_MENU_1                # Configurar para arquivos
CORP_CONFIG_CREATED        # Configuração criada
CORP_BACKUP_CREATED        # Backup criado
```

## 🎨 Boas Práticas

### 1. Use Chaves Descritivas
```bash
# ✅ Bom
translate SEC_CHECKING_FIREWALL

# ❌ Evite
translate MSG1
```

### 2. Sempre Inicialize
```bash
# ✅ Bom - Inicializa no início do script
init_i18n true

# ❌ Ruim - Usar translate sem inicializar
echo "$(translate MSG_SUCCESS)"
```

### 3. Verificar se Carregou
```bash
# ✅ Bom - Verificar antes de usar
if ! is_language_loaded; then
    echo "Erro ao carregar idioma"
    exit 1
fi
```

### 4. Fallback para Inglês
O sistema automaticamente retorna a chave se a tradução não for encontrada, permitindo que o script continue funcionando.

## 📂 Estrutura de Arquivos

```
i18n/
├── i18n.sh       # Biblioteca principal
├── pt_BR.sh      # Traduções em Português
├── en_US.sh      # Traduções em Inglês
└── es_ES.sh      # Traduções em Espanhol

i18n_demo.sh      # Script de demonstração
I18N_README.md    # Esta documentação
```

## 🔍 Detecção Automática de Idioma

O sistema detecta o idioma com base na variável de ambiente `LANG`:

| Variável LANG | Idioma Detectado |
|---------------|------------------|
| `pt_BR.*` | Português (Brasil) |
| `en_US.*` | English (United States) |
| `es_ES.*` | Español (España) |
| Outro | Português (Brasil) - padrão |

### Forçar um Idioma Específico

```bash
# Método 1: Definir LANG antes de executar
LANG=en_US.UTF-8 ./seu_script.sh

# Método 2: Carregar manualmente no script
load_language "en_US"

# Método 3: Menu interativo
select_language_menu
```

## 🆕 Adicionar Novas Traduções

### 1. Adicionar Nova Chave

Edite os três arquivos de idioma (`pt_BR.sh`, `en_US.sh`, `es_ES.sh`):

```bash
# pt_BR.sh
NEW_MESSAGE="Nova mensagem em português"

# en_US.sh
NEW_MESSAGE="New message in English"

# es_ES.sh
NEW_MESSAGE="Nuevo mensaje en español"
```

### 2. Usar no Script

```bash
echo "$(translate NEW_MESSAGE)"
```

## 🌐 Adicionar Novo Idioma

### 1. Criar Arquivo de Tradução

Crie `i18n/fr_FR.sh` (exemplo: Francês):

```bash
#!/bin/bash
# French (France) translations
# Locale: fr_FR

LANG_NAME="Français"
MSG_SUCCESS="Succès"
MSG_ERROR="Erreur"
# ... adicionar todas as traduções
```

### 2. Atualizar i18n.sh

Adicione o novo idioma à lista:

```bash
AVAILABLE_LANGS=("pt_BR" "en_US" "es_ES" "fr_FR")
```

### 3. Atualizar Menu de Seleção

Edite a função `select_language_menu` em `i18n.sh`:

```bash
echo "  4) Français (France)"
# ...
case $choice in
    # ...
    4)
        load_language "fr_FR"
        ;;
esac
```

## 🧪 Testes

### Teste Manual

```bash
# Testar português
LANG=pt_BR.UTF-8 ./i18n_demo.sh

# Testar inglês
LANG=en_US.UTF-8 ./i18n_demo.sh

# Testar espanhol
LANG=es_ES.UTF-8 ./i18n_demo.sh

# Testar menu de seleção
./i18n_demo.sh --select-lang
```

### Validar Sintaxe

```bash
bash -n i18n/i18n.sh
bash -n i18n/pt_BR.sh
bash -n i18n/en_US.sh
bash -n i18n/es_ES.sh
```

## ❓ FAQ

**P: Como mudar o idioma durante a execução?**
```bash
# Chamar novamente load_language
load_language "en_US"
```

**P: O que acontece se uma tradução não existir?**
```bash
# O sistema retorna a própria chave
echo "$(translate CHAVE_INEXISTENTE)"
# Saída: CHAVE_INEXISTENTE
```

**P: Posso usar variáveis nas traduções?**
```bash
# Sim! Use substituição de variáveis
echo "$(translate SEC_UPDATES_AVAILABLE): $count"
```

**P: Como saber qual idioma está ativo?**
```bash
echo "Idioma atual: $CURRENT_LANG"
echo "Nome: $(get_current_language_name)"
```

## 🤝 Contribuindo

Para adicionar ou melhorar traduções:

1. Edite os arquivos em `i18n/`
2. Mantenha consistência entre os idiomas
3. Use chaves descritivas
4. Teste em todos os idiomas
5. Atualize esta documentação

## 📄 Licença

MIT - Veja LICENSE para detalhes

---

**Versão**: 1.0  
**Data**: 2026-01-13  
**Autor**: Everton Araujo  
**Projeto**: Check Linux Security Tools
