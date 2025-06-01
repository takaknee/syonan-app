# Flutter Development Workflow with GitHub Copilot

このドキュメントでは、GitHub Copilot を効果的に活用したFlutterアプリ開発のワークフローを説明します。

## 基本的な開発フロー

### 1. 機能開発の開始
1. GitHub Issues で機能要求テンプレートを使用してissueを作成
2. Copilot に `.github/prompts/flutter-prompts.md` のテンプレートを使用して指示
3. Clean Architecture に従った実装を依頼
4. テストファースト開発でテストコードから作成

### 2. コード作成時のCopilotの活用
- `// TODO: ` コメントを書いてCopilotに実装を提案させる
- 関数名やクラス名を書いてTabキーで補完
- コメントで仕様を書いてからコード生成
- エラーハンドリングも含めた完全な実装を依頼

### 3. テスト作成
- ユニットテスト、ウィジェットテスト、統合テストを包括的に作成
- Copilot にテストケースの提案を依頼
- エッジケースも含めたテスト設計

### 4. コードレビュー
- Copilot Chat でコードレビューを依頼
- パフォーマンス、セキュリティ、可読性の観点でチェック
- Flutter/Dartのベストプラクティス準拠の確認

## Copilot との効果的なコミュニケーション

### 良い指示の例
```
新しいタスク管理機能を作成してください。

要件:
- タスクの追加、編集、削除、完了状態の切り替え
- Clean Architectureに従った実装
- Riverpodを使用した状態管理
- Material Design 3のUI
- 子供向けの親しみやすいカラーとアイコン

実装ファイル:
- lib/features/tasks/domain/entities/task.dart
- lib/features/tasks/domain/repositories/task_repository.dart
- lib/features/tasks/domain/usecases/
- lib/features/tasks/data/
- lib/features/tasks/presentation/

テスト要件:
- すべてのユースケースのユニットテスト
- ウィジェットテスト
- 統合テスト
```

### 避けるべき指示の例
```
タスク機能を作って  // 曖昧すぎる
コードを書いて     // 具体性がない
```

## プロジェクト固有の設定

### アーキテクチャ
- Clean Architecture (Domain, Data, Presentation層)
- Feature-first folder structure
- Dependency Injection (get_it or riverpod)

### 状態管理
- Riverpod (推奨)
- Provider (サブ選択肢)

### UI/UX
- Material Design 3
- 子供向けの親しみやすいデザイン
- ダークモード対応
- アクセシビリティ対応

### テスト
- Unit Tests: domain層のビジネスロジック
- Widget Tests: presentation層のUI
- Integration Tests: 機能全体のフロー
- Golden Tests: UIの見た目の回帰テスト

## VSCode設定の活用

### 推奨エクステンション
- Dart/Flutter extensions
- GitHub Copilot
- GitHub Copilot Chat
- Error Lens
- Bracket Pair Colorizer

### デバッグ設定
- `.vscode/launch.json` に複数の起動構成を用意
- デバイス別、モード別の起動設定
- テスト実行用の設定

## 継続的インテグレーション

### GitHub Actions
- 自動テスト実行
- コード品質チェック
- ビルドの自動化
- デプロイメントの自動化

### コード品質
- flutter_lints の使用
- カスタムlintルールの追加
- コードカバレッジの測定
- 静的解析の強化