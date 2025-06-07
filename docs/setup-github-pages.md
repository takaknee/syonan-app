# GitHub Pages セットアップ手順

このファイルは、リポジトリオーナーがGitHub Pagesを有効化するための手順を説明します。

## 🔧 GitHub Pages 有効化手順

### 1. GitHubリポジトリ設定へアクセス
1. [syonan-app リポジトリ](https://github.com/takaknee/syonan-app)を開く
2. 「Settings」タブをクリック
3. 左サイドバーの「Pages」をクリック

### 2. GitHub Pages設定
1. **Source** セクションで「GitHub Actions」を選択
2. 設定は自動的に保存されます

### 3. 初回デプロイ実行
1. `main`ブランチにコミットをプッシュ（または手動でワークフローを実行）
2. 「Actions」タブでデプロイの進行状況を確認
3. デプロイ完了後、以下のURLでアクセス可能:
   - **https://takaknee.github.io/syonan-app/**

## ✅ 完了確認

以下が正常に動作することを確認してください：

- [ ] GitHub Actionsワークフローが正常に実行される
- [ ] デプロイ後にWebサイトにアクセスできる
- [ ] アプリが正常に読み込まれ、操作できる
- [ ] 算数練習機能が動作する

## 📞 サポート

設定で問題が発生した場合は、GitHubのIssuesまでご報告ください。

---

**注意**: この手順は1回のみ実行すれば、以降は自動的にデプロイされます。