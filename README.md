# syonan-app
娘のためのFlutterアプリ

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

### GitHub Copilot連携
- 開発ガイドラインについては`.github/instructions/`を参照
- 効果的なCopilotプロンプトについては`.github/prompts/`を使用
- より良いCopilotサポートのために提供されたテンプレートを使ってissueを作成

### VS Code設定
- `.vscode/settings.json` - Dart/FlutterとCopilotの設定
- `.vscode/launch.json` - デバッグ設定
- `.vscode/mcp.json` - Model Context Protocolの設定
- `.vscode/extensions.json` - 推奨拡張機能
