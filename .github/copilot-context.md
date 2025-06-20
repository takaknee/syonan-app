# Copilot Context for syonan-app

## プロジェクト概要
**syonan-app** は娘のために設計されたFlutterモバイルアプリケーションです。
このプロジェクトは家族向け、教育的で、魅力的なアプリケーションの構築を目指しています。

## 技術スタック
- **フレームワーク**: Flutter 3.x
- **言語**: Dart 3.x
- **状態管理**: Provider/Riverpod（推奨）
- **UI/UX**: Material Design 3
- **テスト**: flutter_test, mockito
- **開発ツール**: VS Code + GitHub Copilot

## プロジェクト構造
```
syonan-app/
├── .github/
│   ├── instructions/           # Copilot開発ガイドライン
│   ├── prompts/               # 効果的なプロンプトテンプレート
│   ├── ISSUE_TEMPLATE/        # イシューテンプレート
│   └── copilot-context.md     # このファイル
├── .vscode/
│   ├── settings.json          # VS Code + Copilot設定
│   ├── extensions.json        # 推奨拡張機能
│   ├── launch.json           # デバッグ設定
│   └── mcp.json              # Model Context Protocol設定
├── lib/                       # Dartソースコード（予定）
│   ├── main.dart             # アプリエントリーポイント
│   ├── models/               # データモデル
│   ├── screens/              # 画面ウィジェット
│   ├── widgets/              # 再利用可能ウィジェット
│   ├── services/             # APIサービス
│   └── utils/                # ユーティリティ関数
├── test/                     # テストファイル（予定）
└── pubspec.yaml              # Flutter依存関係（予定）
```

## 開発原則
1. **子供にとって安全で教育的**なコンテンツのみ
2. **日本語ファーストのUI**と開発体験
3. **アクセシビリティ**を最優先に考慮
4. **パフォーマンス**と**使いやすさ**のバランス
5. **テスト駆動開発**でコード品質を保証

## Copilotの効果的な使用方法

### コメント記述ルール
- **日本語**でコメントと説明を記述
- **具体的な要件**を詳細に説明
- **エッジケース**や**制約事項**を明記

## 自動修正システム

### コード品質の自動修正
このプロジェクトでは以下の自動修正機能が利用可能です：

#### 1. プルリクエスト時の自動修正
- **ワークフロー**: `.github/workflows/auto-fix-quality.yml`
- **対象**: コードフォーマット、基本的な解析エラー
- **実行**: PR作成時に自動実行、変更は自動コミット

#### 2. Issue経由の自動修正
- **ワークフロー**: `.github/workflows/issue-auto-handler.yml`
- **トリガー**: 
  - Issueに「format」「analysis」「lint」キーワード
  - コメントに `@copilot-fix`
- **機能**: 自動修正PR作成、進捗報告

#### 3. 利用可能なコマンド
```bash
# 手動実行コマンド
@copilot-fix          # Issue内で自動修正をトリガー
@copilot-status       # 自動修正の進捗状況を確認
@copilot-helper       # 一般的なヘルプとガイダンス
```

#### 4. 自動修正対象
- **コードフォーマット**: `dart format --line-length=120` による整形（120文字制限）
- **インポート追加**: よく使われるFlutterインポートの自動追加
- **const修飾子**: 推奨されるconst修飾子の自動追加
- **基本的な構文エラー**: 単純な構文問題の修正

#### 5. 手動での品質チェック
```bash
# ローカルでの確認
flutter analyze                    # コード解析
dart format --line-length=120 --set-exit-if-changed . # フォーマットチェック（120文字制限）
flutter test                       # テスト実行
```
- **パフォーマンス要件**があれば指定

### プロンプトの書き方
```dart
// TODO: 子供向けの安全な[機能名]ウィジェットを作成
// 要件: [具体的な要件リスト]
// 制約: [技術的制約や制限事項]
// パフォーマンス: [パフォーマンス要件]
```

### 推奨パターン
- **const constructor**の使用
- **適切な状態管理**の実装
- **エラーハンドリング**の追加
- **アクセシビリティ**の考慮
- **レスポンシブデザイン**の実装

## コードスタイルガイド

### ファイル命名規則
- **snake_case**でファイル名を記述
- **機能別**にディレクトリを分割
- **テストファイル**は`_test.dart`サフィックス

### クラス・関数命名
- **PascalCase**でクラス名
- **camelCase**で関数・変数名
- **日本語コメント**で機能説明

### インポート順序
1. Dart core ライブラリ
2. Flutter framework
3. サードパーティパッケージ
4. プロジェクト内ファイル

## UI/UXガイドライン

### デザインシステム
- **Material Design 3**を基準
- **子供向けの親しみやすい色彩**
- **大きめのタッチターゲット**
- **明確で分かりやすいナビゲーション**

### アクセシビリティ
- **Semantics**ウィジェットの適切な使用
- **十分なコントラスト比**の確保
- **音声読み上げ**への対応
- **キーボードナビゲーション**のサポート

## テスト戦略

### ユニットテスト
- **ビジネスロジック**の徹底的なテスト
- **エッジケース**と**エラーシナリオ**のカバー
- **モック**を使用した依存関係の分離

### ウィジェットテスト
- **UI コンポーネント**の動作確認
- **ユーザーインタラクション**のテスト
- **状態変化**の検証

### 統合テスト
- **エンドツーエンド**のユーザーフロー
- **パフォーマンス**の検証
- **実機での動作確認**

## パフォーマンス考慮事項

### 最適化ポイント
- **不要な rebuild の回避**
- **適切な widget lifecycle の管理**
- **画像とアセットの最適化**
- **メモリ使用量の監視**

### 監視・測定
- **Flutter Inspector**の活用
- **performance overlay**での確認
- **メモリプロファイリング**の実施

## セキュリティとプライバシー

### データ保護
- **子供のプライバシー**を最優先
- **個人情報の最小限の収集**
- **セキュアなデータ保存**
- **COPPA準拠**の実装

## 開発ワークフロー

### ブランチ戦略
- **main**: 本番リリース可能なコード
- **develop**: 開発統合ブランチ
- **feature/***: 機能開発ブランチ
- **hotfix/***: 緊急修正ブランチ

### コミットメッセージ
```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
style: コードフォーマット
refactor: リファクタリング
test: テスト追加・修正
chore: その他の変更
```

## Copilot使用時の注意点
1. **生成されたコード**は必ずレビューする
2. **セキュリティ**と**プライバシー**を常に考慮
3. **テスト**を必ず作成・実行する
4. **アクセシビリティ**要件を確認する
5. **パフォーマンス**への影響を評価する
