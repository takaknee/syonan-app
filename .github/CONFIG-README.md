# GitHub Copilot Configuration Files

このディレクトリには、GitHub Copilot開発環境のファイアウォール問題を解決するための設定ファイルが含まれています。

## 設定ファイル概要

### 1. `copilot-firewall-config.yml`
ファイアウォールで許可するドメインとURLの設定
- Flutter/Dart SDK ダウンロード用のGoogle サービス
- Ubuntu/Canonical のパッケージ管理サービス
- GitHub Actions ランナー用のAzure サービス

### 2. `copilot-setup-steps.yml`
ファイアウォール有効化前に実行すべきセットアップ手順
- Dart SDK の事前ダウンロード
- Flutter リリース情報の取得
- パッケージリポジトリの設定

### 3. `enhanced-workflow.yml`
ファイアウォール問題に対応した改善版 GitHub Actions ワークフロー
- 環境セットアップジョブの追加
- キャッシュ機能の活用
- テスト実行ジョブの分離

### 4. `copilot-environment-config.yml`
GitHub Copilot 環境の包括的な設定ファイル
- ネットワーク設定
- 開発ツール設定
- セキュリティ考慮事項
- 使用ガイドライン

## 使用方法

### GitHub Actions での使用
1. `enhanced-workflow.yml` を `.github/workflows/` ディレクトリにコピー
2. 既存のワークフローファイルと置き換える、または統合する
3. ファイアウォール設定が自動的に適用される

### ローカル開発での使用
1. `copilot-firewall-config.yml` の設定を参考にファイアウォール設定を更新
2. `.vscode/settings.json` の GitHub Copilot 設定を確認
3. `.github/instructions/` の指示書を参照して開発を進める

## トラブルシューティング

### ファイアウォールブロックエラーが発生する場合
1. `copilot-firewall-config.yml` の `allow_domains` を確認
2. 新しいURLがブロックされている場合は設定に追加
3. GitHub Actions の setup steps でキャッシュが有効になっているか確認

### Flutter/Dart のダウンロードが失敗する場合
1. `copilot-setup-steps.yml` の手順を参考に事前セットアップを実行
2. インターネット接続とプロキシ設定を確認
3. GitHub Actions のキャッシュ設定を確認

## セキュリティノート

このファイルで許可されているドメインとURLは、すべて公式の開発ツールリポジトリです：
- `storage.googleapis.com` - Google の公式ストレージ（Flutter/Dart用）
- `dl-ssl.google.com` - Google のセキュアダウンロードサービス
- `api.snapcraft.io` - Canonical の Snap パッケージマネージャー
- `esm.ubuntu.com` - Ubuntu 拡張セキュリティメンテナンス

これらの設定により、開発ツールの正常な動作が保証されます。