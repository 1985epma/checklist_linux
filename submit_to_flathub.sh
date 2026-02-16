#!/bin/bash

# Script auxiliar para submissão ao Flathub
# Este script ajuda a completar o processo de submissão

set -e

echo "🚀 CHECK LINUX - Submissão ao Flathub"
echo "======================================"
echo ""

# Verificar se o diretório existe
if [ ! -d "/tmp/flathub-submission" ]; then
    echo "❌ Erro: Diretório /tmp/flathub-submission não encontrado"
    echo "Execute primeiro os passos de preparação."
    exit 1
fi

cd /tmp/flathub-submission

# Verificar se há um remote chamado myfork
if git remote | grep -q "myfork"; then
    echo "✅ Remote 'myfork' já está configurado"
else
    echo "📝 Configurando remote do seu fork..."
    echo ""
    echo "Escolha o método de autenticação:"
    echo "1) SSH (recomendado se você tem chave SSH configurada)"
    echo "2) HTTPS"
    read -p "Digite 1 ou 2: " choice
    
    case $choice in
        1)
            git remote add myfork git@github.com:1985epma/flathub.git
            echo "✅ Remote configurado via SSH"
            ;;
        2)
            git remote add myfork https://github.com/1985epma/flathub.git
            echo "✅ Remote configurado via HTTPS"
            ;;
        *)
            echo "❌ Opção inválida"
            exit 1
            ;;
    esac
fi

echo ""
echo "📤 Fazendo push da branch..."
echo ""

if git push myfork com.github._1985epma.ChecklistLinux; then
    echo ""
    echo "✅ Push realizado com sucesso!"
    echo ""
    echo "🎉 Próximo passo: Criar Pull Request"
    echo ""
    echo "Acesse o link abaixo para criar o PR:"
    echo "👉 https://github.com/flathub/flathub/compare/new-pr...1985epma:flathub:com.github._1985epma.ChecklistLinux"
    echo ""
    echo "Use as informações do arquivo FLATHUB_SUBMISSION_INSTRUCTIONS.md"
    echo "para preencher o título e descrição do PR."
    echo ""
else
    echo ""
    echo "❌ Erro ao fazer push"
    echo ""
    echo "Possíveis soluções:"
    echo "1. Verifique se você fez o fork em: https://github.com/flathub/flathub/fork"
    echo "2. Certifique-se de que NÃO marcou 'Copy the master branch only'"
    echo "3. Verifique suas credenciais do GitHub"
    echo "4. Se usar SSH, verifique se sua chave SSH está configurada"
    echo ""
    exit 1
fi
