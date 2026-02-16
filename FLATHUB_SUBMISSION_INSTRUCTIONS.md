# Instruções para Submissão ao Flathub

## ✅ Arquivos Preparados

Todos os arquivos necessários foram preparados e estão prontos em `/tmp/flathub-submission/`:

- ✅ `com.github._1985epma.ChecklistLinux.yml` - Manifesto Flatpak
- ✅ `com.github._1985epma.ChecklistLinux.desktop` - Arquivo Desktop Entry
- ✅ `com.github._1985epma.ChecklistLinux.appdata.xml` - Metadados AppData
- ✅ `com.github._1985epma.ChecklistLinux.svg` - Ícone da aplicação

## 📋 Próximos Passos

### 1. Fazer Fork do Repositório Flathub

Acesse https://github.com/flathub/flathub/fork e crie um fork **SEM marcar** a opção "Copy the master branch only" (deixe desmarcada).

### 2. Adicionar o Remote do seu Fork

```bash
cd /tmp/flathub-submission
git remote add myfork git@github.com:1985epma/flathub.git
# ou se preferir HTTPS:
# git remote add myfork https://github.com/1985epma/flathub.git
```

### 3. Fazer Push da Branch

```bash
cd /tmp/flathub-submission
git push myfork com.github._1985epma.ChecklistLinux
```

### 4. Criar Pull Request

1. Acesse: https://github.com/flathub/flathub/compare/new-pr...1985epma:flathub:com.github._1985epma.ChecklistLinux

2. Clique em "Create Pull Request"

3. Use o seguinte título:
   ```
   Add CHECK LINUX Security Tools
   ```

4. Use a seguinte descrição:
   ```
   ## Application Information
   
   - **Name**: CHECK LINUX Security Tools
   - **App ID**: com.github._1985epma.ChecklistLinux
   - **Homepage**: https://github.com/1985epma/checklist_linux
   - **License**: MIT
   
   ## Description
   
   Comprehensive security audit and system optimization toolkit for Ubuntu Linux.
   
   ## Features
   
   - Security Checklist with HTML/CSV report generation
   - System Updates verification
   - Firewall analysis (UFW)
   - Running Services review
   - User Accounts audit
   - File Permissions check
   - SSH Configuration analysis
   - Malware scanning (rkhunter integration)
   - Service Optimizer with GUI
   - Sudo Permissions Checker
   - Corporate Sudo Configurator
   - Multi-language support (English, Portuguese BR, Spanish)
   
   ## Technical Details
   
   - Runtime: org.freedesktop.Platform 23.08
   - Build system: simple
   - Language: Shell Script
   - GUI: Bash with dialog/whiptail
   
   ## Testing
   
   The application has been tested locally and all features are working correctly.
   
   ## Checklist
   
   - [x] Application builds and runs locally
   - [x] AppData file is valid
   - [x] Desktop file is valid
   - [x] Icon is provided (SVG format)
   - [x] Manifest follows Flathub requirements
   - [x] Application is open source (MIT license)
   - [x] Repository is publicly accessible
   
   I am the original author/maintainer of this application.
   ```

5. Clique em **"Create Pull Request"**

## 🔍 Revisão

Após criar o PR:

1. O Flathub bot fará verificações automáticas
2. Revisores do Flathub irão analisar sua submissão
3. Eles podem solicitar mudanças ou aprovação
4. Uma vez aprovado, sua aplicação será publicada no Flathub!

## 📚 Referências

- [Documentação de Submissão do Flathub](https://docs.flathub.org/docs/for-app-authors/submission)
- [Requisitos do Flathub](https://docs.flathub.org/docs/for-app-authors/requirements)
- [Guia de Metainfo](https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/)

## ⚠️ Notas Importantes

- O PR deve ser feito contra a branch `new-pr` do repositório flathub/flathub (já está correto)
- **NUNCA** faça PR contra a branch `master`
- Responda prontamente aos comentários dos revisores
- O processo de revisão pode levar alguns dias

## 🆘 Suporte

Se tiver problemas durante o processo:

1. Canal Matrix: https://matrix.to/#/#flathub:matrix.org
2. Discourse: https://discourse.flathub.org/
3. GitHub Issues: https://github.com/flathub/flathub/issues

---

**Status Atual**: Arquivos preparados e commitados. Aguardando fork manual e push.
