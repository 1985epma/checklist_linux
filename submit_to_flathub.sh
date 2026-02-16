#!/bin/bash

# Helper script for Flathub submission
# This script helps complete the submission process

set -e

echo "🚀 CHECK LINUX - Flathub Submission"
echo "======================================"
echo ""

# Check if directory exists
if [ ! -d "/tmp/flathub-submission" ]; then
    echo "❌ Error: Directory /tmp/flathub-submission not found"
    echo "Run the preparation steps first."
    exit 1
fi

cd /tmp/flathub-submission

# Check if there's a remote called myfork
if git remote | grep -q "myfork"; then
    echo "✅ Remote 'myfork' is already configured"
else
    echo "📝 Configuring your fork remote..."
    echo ""
    echo "Choose authentication method:"
    echo "1) SSH (recommended if you have SSH key configured)"
    echo "2) HTTPS"
    read -p "Enter 1 or 2: " choice
    
    case $choice in
        1)
            git remote add myfork git@github.com:1985epma/flathub.git
            echo "✅ Remote configured via SSH"
            ;;
        2)
            git remote add myfork https://github.com/1985epma/flathub.git
            echo "✅ Remote configured via HTTPS"
            ;;
        *)
            echo "❌ Invalid option"
            exit 1
            ;;
    esac
fi

echo ""
echo "📤 Pushing branch..."
echo ""

if git push myfork com.github._1985epma.ChecklistLinux; then
    echo ""
    echo "✅ Push completed successfully!"
    echo ""
    echo "🎉 Next step: Create Pull Request"
    echo ""
    echo "Access the link below to create the PR:"
    echo "👉 https://github.com/flathub/flathub/compare/new-pr...1985epma:flathub:com.github._1985epma.ChecklistLinux"
    echo ""
    echo "Use the information from FLATHUB_SUBMISSION_INSTRUCTIONS.md"
    echo "to fill in the PR title and description."
    echo ""
else
    echo ""
    echo "❌ Error during push"
    echo ""
    echo "Possible solutions:"
    echo "1. Check if you forked at: https://github.com/flathub/flathub/fork"
    echo "2. Make sure you did NOT check 'Copy the master branch only'"
    echo "3. Verify your GitHub credentials"
    echo "4. If using SSH, check if your SSH key is configured"
    echo ""
    exit 1
fi
