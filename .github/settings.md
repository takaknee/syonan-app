# GitHub Pages Configuration

このリポジトリはGitHub ActionsワークフローでFlutter Webアプリをデプロイします。

## 必要な設定

1. GitHub Pages設定を「GitHub Actions」ソースに変更する必要があります
2. リポジトリ設定 > Pages > Source を「Deploy from a branch」から「GitHub Actions」に変更

## ワークフロー

- `.github/workflows/deploy-github-pages.yml` - Flutter Web デプロイメント
- `.github/workflows/jekyll-gh-pages.yml` - 無効化済み

## デプロイメント確認

最新のデプロイメント状況:
- Build時刻: ビルド情報はアプリ内で確認可能
- URL: https://takaknee.github.io/syonan-app/
