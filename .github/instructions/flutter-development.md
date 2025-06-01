# Flutter開発指示書

## プロジェクト概要
これは娘のためのFlutterアプリプロジェクト（syonan-app）です。

## 開発ガイドライン

### コードスタイル
- Dart公式スタイルガイドに従う
- 意味のある変数名と関数名を使用
- 関数は小さく、集中させる
- 複雑なロジックには適切な日本語コメントを使用

### Flutterベストプラクティス
- 可能な場合はconstコンストラクタを使用
- 適切な状態管理を実装
- Material Designガイドラインに従う
- 異なる画面サイズに対応するレスポンシブデザインを確保

### GitHub Copilot使用方法
- **コード提案を求める際は、コメントで具体的に指示**
  - 機能の目的と期待される動作を明記
  - 技術的制約や制限事項を記述
  - パフォーマンス要件がある場合は指定
  - セキュリティ考慮事項を含める

- **より良い提案を得るために説明的な関数名と変数名を使用**
  - 英語で意味のある名前を付ける
  - 日本語コメントで詳細を説明
  - ビジネスロジックを名前で表現

- **複雑なタスクを小さく明確に定義された関数に分解**
  - 単一責任の原則に従う
  - 再利用可能な小さな関数を作成
  - 依存関係を明確にする

- **実装タスクをガイドするためにTODOコメントを使用**
  - 具体的な要件を記述
  - 実装の優先順位を示す
  - エッジケースや制約を明記

- **日本語でコメントを記述し、日本語での応答を求める**
  - コードの意図を日本語で説明
  - エラーメッセージも日本語で分かりやすく
  - ドキュメントは日本語で作成

### Copilot Chat活用法
- **コードレビューの依頼**
  - `@github review this code for security issues`
  - `@github suggest improvements for this Flutter widget`
  - `@github check if this code follows best practices`

- **テスト作成の支援**
  - `@github generate unit tests for this service`
  - `@github create widget tests for this component`
  - `@github suggest edge cases to test`

- **リファクタリングの提案**
  - `@github refactor this code to improve performance`
  - `@github extract reusable components from this widget`
  - `@github optimize this code for better maintainability`

- **デバッグの支援**
  - `@github help debug this Flutter error`
  - `@github explain why this widget is not rendering correctly`
  - `@github suggest fixes for this performance issue`

### テスト
- ビジネスロジックのユニットテストを作成
- UIコンポーネントのウィジェットテストを作成
- テストが保守可能で読みやすいことを確保

### パフォーマンス
- 不要な再構築を避ける
- 用途に適したウィジェットを使用
- アプリのパフォーマンスを定期的にプロファイル
- 画像とアセットを最適化

## ファイル構造
```
lib/
├── main.dart
├── models/
├── screens/
├── widgets/
├── services/
└── utils/
```

## コミットメッセージ形式
- feat: 新機能
- fix: バグ修正
- docs: ドキュメント変更
- style: フォーマット変更
- refactor: コードリファクタリング
- test: テスト追加
- chore: メンテナンスタスク