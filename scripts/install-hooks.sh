#!/bin/bash

# Pre-commit hook installation script for syonan-app

echo "🔧 Syonan App - Pre-commit Hook Setup"
echo "===================================="
echo ""

# Check if .git directory exists
if [ ! -d ".git" ]; then
    echo "❌ Error: .git directory not found!"
    echo "Please run this script from the root of the git repository."
    exit 1
fi

# Check if pre-commit hook template exists
if [ ! -f ".githooks/pre-commit" ]; then
    echo "❌ Error: Pre-commit hook template not found!"
    echo "Expected: .githooks/pre-commit"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy the pre-commit hook
echo "📋 Installing pre-commit hook..."
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "🎯 What does this hook do?"
echo "- Checks code formatting before each commit"
echo "- Runs code analysis (if Flutter is available)"
echo "- Prevents commits with formatting issues"
echo ""
echo "🛠️ To disable the hook temporarily:"
echo "  git commit --no-verify"
echo ""
echo "🗑️ To remove the hook:"
echo "  rm .git/hooks/pre-commit"
echo ""
echo "✨ Happy coding!"