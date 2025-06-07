#!/bin/bash

# GitHub Pages設定確認・修正スクリプト

echo "🔍 GitHub Pages 設定確認スクリプト"
echo "=================================="
echo

# 現在のPages設定を確認
echo "📋 現在のGitHub Pages設定を確認しています..."
echo

# リポジトリ情報取得
REPO_URL=$(git remote get-url origin)
REPO_NAME=$(echo $REPO_URL | sed 's/.*github.com[:/]//' | sed 's/.git$//')
echo "リポジトリ: $REPO_NAME"

# 現在のサイト確認
echo
echo "🌐 現在のサイト内容:"
SITE_CONTENT=$(curl -s "https://takaknee.github.io/syonan-app/" | head -10)
if echo "$SITE_CONTENT" | grep -q "Jekyll"; then
    echo "❌ Jekyllページが表示されています"
    echo "   → GitHub Pages設定がブランチベースになっている可能性があります"
else
    echo "✅ Flutterアプリが表示されています"
fi

echo
echo "🔧 必要な対応:"
echo "1. GitHubのWebインターフェースにアクセス:"
echo "   https://github.com/$REPO_NAME/settings/pages"
echo
echo "2. 「Source」セクションで「Deploy from a branch」から"
echo "   「GitHub Actions」に変更してください"
echo
echo "3. 変更後、以下のコマンドでワークフローを手動実行:"
echo "   gh workflow run deploy-github-pages.yml"
echo "   または GitHub Web UIの Actions タブから実行"

echo
echo "📊 最新のコミット情報:"
git log --oneline -3
