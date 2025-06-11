# 自動修正システム使用ガイド

## 概要
このプロジェクトでは、コードフォーマットと解析エラーの自動修正システムを導入しています。GitHub ActionsとCopilot Coding Agentが連携して、品質問題を自動的に検出・修正します。

## 自動修正の種類

### 1. コードフォーマット
- **対象**: インデント、改行、空白の統一
- **ツール**: `dart format`
- **実行**: 自動 (PR作成時) または手動

### 2. 基本的な解析エラー
- **対象**: 
  - 不足しているインポート文
  - const修飾子の追加
  - 基本的な構文エラー
- **ツール**: カスタムスクリプト + `flutter analyze`
- **実行**: 自動 (PR作成時) または手動

## 使用方法

### 🚀 自動実行 (推奨)

#### プルリクエスト時
1. PRを作成すると自動的に品質チェックが実行
2. 問題が見つかると自動修正が適用
3. 修正はPRに自動コミット
4. 結果はPRにコメントで報告

#### Issue経由
1. **Issueキーワード**: タイトルや本文に以下を含む
   - `format` / `formatting`
   - `analysis` / `analyze`
   - `lint` / `linting`

2. **コメントコマンド**:
   ```
   @copilot-fix        # 自動修正を実行
   @copilot-status     # 修正状況を確認
   @copilot-helper     # 使用方法のヘルプ
   ```

### 🔧 手動実行

#### VS Codeタスク
1. `Ctrl+Shift+P` → "Tasks: Run Task"
2. 以下のタスクを選択:
   - `AutoFix: コード品質の自動修正` - 全自動修正
   - `AutoFix: フォーマットのみ修正` - フォーマットのみ
   - `AutoFix: インポート修正` - インポート追加
   - `AutoFix: Const修飾子追加` - const修飾子追加

#### コマンドライン
```bash
# 全自動修正
make autofix

# 個別修正
dart format .                    # フォーマット
flutter analyze                  # 解析
```

#### GitHub Actions手動実行
1. GitHub → Actions → "Auto-Fix Code Quality Issues"
2. "Run workflow" → 対象ブランチ選択 → "Run workflow"

## 修正対象の詳細

### ✅ 自動修正可能

#### フォーマット
- インデント統一
- 改行コードの統一
- 末尾スペースの削除
- 括弧の位置調整

#### 基本的な解析エラー
- **不足インポート**: よく使われるFlutterインポートの自動追加
  ```dart
  // 自動追加される
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  ```

- **const修飾子**: 推奨される箇所への自動追加
  ```dart
  // 修正前
  Text('Hello')
  SizedBox(height: 10)
  
  // 修正後
  const Text('Hello')
  const SizedBox(height: 10)
  ```

### ⚠️ 手動修正必要

#### 複雑な解析エラー
- ロジックエラー
- 型エラー
- 未使用変数の削除
- 複雑なリファクタリング

#### 設計レベルの問題
- アーキテクチャの改善
- パフォーマンス最適化
- セキュリティ問題

## トラブルシューティング

### 自動修正が動作しない場合

1. **Flutter環境の確認**
   ```bash
   flutter doctor
   ```

2. **依存関係の更新**
   ```bash
   flutter pub get
   ```

3. **手動実行でテスト**
   ```bash
   dart format .
   flutter analyze
   ```

### 修正が不完全な場合

1. **ログの確認**: GitHub Actions の実行ログを確認
2. **段階的修正**: 一部を手動で修正してから再実行
3. **Issue作成**: 修正できない問題は具体的なIssueを作成

### 修正が壊れた場合

1. **git reset**: 最新の修正を取り消し
   ```bash
   git reset --hard HEAD~1
   ```

2. **個別修正**: 問題のある修正のみ手動で実行
3. **Issue報告**: 修正システムの改善のためIssue作成

## 設定とカスタマイズ

### 修正ルールの変更
- **analysis_options.yaml**: 解析ルールの設定
- **ワークフロー**: `.github/workflows/auto-fix-quality.yml`
- **VS Codeタスク**: `.vscode/tasks.json`

### 新しい修正ルールの追加
1. ワークフローファイルの編集
2. カスタムスクリプトの作成
3. テストでの動作確認

## 関連ドキュメント

- [品質チェック・トラブルシューティング](quality-check-troubleshooting.md)
- [フォーマットガイド](formatting-guide.md)
- [GitHub Actions設定](github-actions-improvements.md)

## サポート

質問や問題がある場合:
1. **Issue作成**: 具体的な問題を説明
2. **@copilot-helper**: コメントでヘルプを要求
3. **ドキュメント参照**: 上記の関連ドキュメントを確認
