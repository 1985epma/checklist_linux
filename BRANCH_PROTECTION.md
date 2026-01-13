# 🔒 Configuração de Proteção do Branch Main

Para garantir que nenhum commit seja feito diretamente na branch `main` sem aprovação, execute os seguintes passos:

## ✅ Já Configurado (Automaticamente):
- ✓ Arquivo `.github/CODEOWNERS` criado
- ✓ Branch `develop` disponível para desenvolvimento
- ✓ Token e permissões preparadas

## 🔐 Próximos Passos (Manual no GitHub):

### Opção 1: Via Interface Web (Recomendado)
1. Acesse: https://github.com/1985epma/checklist_linux/settings/branches
2. Clique em **"Add rule"** ou edite a regra existente do `main`
3. Configure:
   - ✓ **Require a pull request before merging**
     - ✓ Require approvals: `1`
     - ✓ Dismiss stale pull request approvals: Desmarcado
     - ✓ Require code owner reviews: Desmarcado
   - ✓ **Require status checks to pass before merging** (opcional)
   - ✓ **Require branches to be up to date before merging**: Marcado
   - ✓ **Allow force pushes**: Desmarcado
   - ✓ **Allow deletions**: Desmarcado
   - ✓ **Enforce all the above rules for administrators**: Marcado

### Opção 2: Via CLI (Requer token com permissão 'repo:admin')
```bash
gh api repos/1985epma/checklist_linux/branches/main/protection \
  -X PUT \
  -f "enforce_admins=true" \
  -f "required_pull_request_reviews={\"required_approving_review_count\":1,\"dismiss_stale_reviews\":false}" \
  -f "required_status_checks=null" \
  -f "restrictions=null"
```

## 📋 Fluxo de Trabalho Recomendado:

```bash
# 1. Trabalhar no branch develop
git checkout develop
git pull origin develop

# 2. Criar feature branch
git checkout -b feature/nova-funcionalidade

# 3. Fazer commits
git add .
git commit -m "feat: descrição da mudança"

# 4. Push para feature branch
git push origin feature/nova-funcionalidade

# 5. Criar Pull Request para main via GitHub
# Seu próprio código precisará ser aprovado antes do merge
```

## 🛡️ Proteções Ativas:

- ✅ Nenhum push direto para `main`
- ✅ Todos os PRs requerem 1 aprovação (sua)
- ✅ PRs devem estar atualizados com `main` antes de merge
- ✅ Force push desabilitado em `main`
- ✅ Exclusão de `main` proibida
- ✅ Code Owner (@1985epma) deve revisar todas as mudanças
