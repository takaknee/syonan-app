# 算数れんしゅう (Syonan App)
小学三年生向けの算数学習アプリ

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

## 開発環境セットアップ

このプロジェクトはGitHub CopilotとFlutter開発に最適化された設定になっています。

### 必要な環境
- Flutter SDK
- 推奨拡張機能を含むVS Code
- GitHub Copilotサブスクリプション

### 始め方
1. リポジトリをクローンする
2. VS Codeで開く - 推奨拡張機能のインストールを促されます
3. `flutter pub get`を実行して依存関係をインストールする
4. 設定済みのlaunch configurationを使ってデバッグする

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
