# 算数れんしゅう (Syonan App)
小学三年生向けの算数学習アプリ

## 📑 目次
- [アプリについて](#-アプリについて)
- [オンラインデモ (GitHub Pages)](#-オンラインデモ-github-pages)
- [開発環境セットアップ](#開発環境セットアップ)
- [GitHub Copilot効率化機能](#github-copilot効率化機能)
- [ドキュメント](#-ドキュメント)

## 📱 アプリについて

このアプリは小学三年生の娘のために作られた算数学習アプリです。楽しく勉強できるように、カラフルでわかりやすいデザインと励ましの機能を提供します。

### 🎯 主な機能

- **掛け算練習**: 九九（1×1から9×9）の練習
- **割り算練習**: 割り切れる問題の練習
- **スコア記録**: 練習結果の自動保存と履歴表示
- **励ましシステム**: スコア向上時の褒め言葉表示
- **統計情報**: 連続練習日数、週間練習回数、平均スコアなど
- **子供向けUI**: 大きなボタン、わかりやすいアイコン、優しい色使い

### 🌟 特徴

- **安全設計**: 子供のプライバシーを保護
- **オフライン動作**: インターネット接続不要
- **アクセシビリティ対応**: 音声読み上げやキーボードナビゲーション対応
- **楽しい学習体験**: アニメーションと励ましのメッセージ

## 🌐 オンラインデモ (GitHub Pages)

実際にデバイスにインストールしなくても、Webブラウザで算数れんしゅうアプリを体験できます。

### 📍 アクセス方法

**デモURL**: [https://takaknee.github.io/syonan-app/](https://takaknee.github.io/syonan-app/)

### 🚀 クイックスタート

1. 上記のURLをクリックしてデモページにアクセス
2. ブラウザでアプリが読み込まれるまで数秒お待ちください
3. 「掛け算練習」または「割り算練習」を選択
4. 問題を解いて楽しく算数を練習しましょう！

### 💡 デモの特徴

- **実機同等の体験**: フル機能のアプリをブラウザで体験
- **データ保存**: ブラウザのローカルストレージにスコアを保存
- **モバイル対応**: スマートフォンやタブレットでも快適に利用可能
- **インストール不要**: Webブラウザがあればすぐに開始

### 🔄 更新情報

デモサイトは`main`ブランチの最新コードが自動的にデプロイされます。新機能やバグ修正は通常、コミット後数分以内に反映されます。

詳細な情報については[GitHub Pages デプロイメントガイド](docs/github-pages.md)をご参照ください。

## 開発環境セットアップ

このプロジェクトはGitHub CopilotとFlutter開発に最適化された設定になっています。

### 必要な環境
- Flutter SDK
- 推奨拡張機能を含むVS Code
- GitHub Copilotサブスクリプション

### 始め方
1. リポジトリをクローンする
2. VS Codeで開く - 推奨拡張機能のインストールを促されます
3. 開発環境をセットアップする:
   ```bash
   make setup      # Flutter依存関係をインストール
   ```
4. **🚨 重要**: コード品質チェックを有効にする（PR前エラー防止）:
   ```bash
   ./scripts/install-hooks.sh    # プリコミットフックをインストール
   ```
5. 設定済みのlaunch configurationを使ってデバッグする

### 開発コマンド
```bash
make help          # 利用可能なコマンドを表示
make format        # コードフォーマット
make format-check  # フォーマット確認（PR前チェック推奨）
make lint          # コード解析
make test          # テスト実行
make build         # Webアプリビルド
make qa            # 全品質チェック（PR前推奨）
```

### 🛡️ CI/CDエラー防止
PR作成前のチェックを自動化するため、以下のコマンドを実行することを強く推奨します：
```bash
# プリコミットフックのインストール（一度だけ）
./scripts/install-hooks.sh

# または手動でPR前チェック
make qa    # フォーマット + 解析 + テスト
```

**📋 詳細ガイド**: [CI/CDエラー防止クイックガイド](docs/ci-prevention-guide.md)

## GitHub Copilot効率化機能

このプロジェクトはGitHub Copilotの開発効率を最大化するための包括的な設定とガイドラインを提供します。

### 🤖 Copilot機能強化
- **高度な設定**: `.vscode/settings.json`でCopilotを最適化
- **日本語対応**: コメントと応答を日本語で統一
- **コンテキスト提供**: `.github/copilot-context.md`で詳細なプロジェクト情報
- **効果的なプロンプト**: `.github/prompts/`の豊富なテンプレート
- **自動化ワークフロー**: GitHub Actionsでの開発支援

### 📚 開発ガイドライン
- **Copilot指示書**: `.github/instructions/copilot-guidelines.md`
- **Flutter開発規約**: `.github/instructions/flutter-development.md`
- **セキュリティ重視**: 子供向けアプリのプライバシー保護
- **アクセシビリティ**: 包括的なユーザー体験の実現
- **コードフォーマット**: `docs/formatting-guide.md`でフォーマット規則とトラブルシューティング

### 🚀 開発効率向上機能
- **VS Codeタスク**: `.vscode/tasks.json`で一般的な操作を自動化
- **デバッグ設定**: `.vscode/launch.json`で効率的なデバッグ
- **MCP統合**: `.vscode/mcp.json`でContext Protocol対応
- **GitHub Actions**: 自動コード品質チェックとCopilot提案

### VS Code設定
- `.vscode/settings.json` - Dart/FlutterとCopilotの最適化設定
- `.vscode/launch.json` - デバッグ設定
- `.vscode/mcp.json` - Model Context Protocolの設定
- `.vscode/extensions.json` - 推奨拡張機能（Copilot含む）
- `.vscode/tasks.json` - 開発タスクの自動化

### 🎯 Copilot使用のベストプラクティス

#### 効果的なプロンプト作成
```dart
// TODO: 子供向けの安全な[機能名]を実装
// 要件: [具体的な要件リスト]
// 制約: [技術的制約や制限事項]
// セキュリティ: [プライバシー保護要件]
```

#### Chat機能の活用
- `@github review this code for security`（セキュリティレビュー）
- `@github optimize this Flutter widget`（パフォーマンス最適化）
- `@github generate tests for this function`（テスト生成）
- `@github explain this error message`（エラー解析）

#### 開発ワークフロー統合
- プルリクエスト時の自動コード品質チェック
- Issue作成時のCopilot提案
- コミット時の自動フォーマットと解析

## 📚 ドキュメント

詳細なドキュメントは[docsディレクトリ](docs/)にまとめられています：

- **[GitHub Pages デプロイメントガイド](docs/github-pages.md)** - Webデモの詳細情報
- **[ドキュメント一覧](docs/README.md)** - 利用可能なドキュメントの一覧

## 🤝 コントリビューション

このプロジェクトへの貢献を歓迎します。バグ報告、機能提案、コードの改善などは[Issues](https://github.com/takaknee/syonan-app/issues)までお願いします。

## 📄 ライセンス

このプロジェクトは教育目的で作成されており、個人利用に限定されています。
