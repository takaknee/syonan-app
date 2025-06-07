# コードフォーマッティング ガイド

このドキュメントは、syonan-appプロジェクトでのコードフォーマッティングに関するガイドラインと解決方法を説明します。

## 🎯 目的

- 一貫性のあるコードスタイルの維持
- CI/CDワークフローでのフォーマットエラーの回避
- 開発体験の向上

## 🚨 CI/CDエラーを防ぐ最重要設定

### 初回セットアップ（必須）

新しい開発環境では、まず以下を実行してください：

```bash
# 完全な開発環境セットアップ（推奨）
make setup

# または手動セットアップ
flutter pub get
./scripts/install-hooks.sh  # プリコミットフックをインストール
```

### PR作成前の必須チェック

**全てのPR作成前に以下を実行してください：**

```bash
# 全品質チェック（フォーマット + 解析 + テスト）
make qa
```

これにより、GitHub ActionsでのCI/CDエラーを99%防げます。

## 🔧 自動フォーマット設定

### VS Code設定

プロジェクトは以下の設定で自動フォーマットが有効になっています：

- **保存時フォーマット**: `editor.formatOnSave: true`
- **行長**: 80文字
- **デフォルトフォーマッター**: Dart-Code

### 設定場所

- `.vscode/settings.json` - VS Code設定
- `analysis_options.yaml` - Dart解析設定

## 🛠️ フォーマット実行方法

### 1. 自動実行（推奨）

```bash
# VS Codeで保存時に自動実行（設定済み）
# またはキーボードショートカット: Shift+Alt+F
```

### 2. Makeコマンド（簡単）

```bash
# フォーマット確認
make format-check

# フォーマット修正
make format

# コード解析も実行
make lint

# すべての品質チェック
make qa
```

### 3. スクリプト実行

```bash
# フォーマット確認
./scripts/format.sh check

# フォーマット修正
./scripts/format.sh fix
```

### 4. 手動実行

```bash
# 全ファイルフォーマット
dart format .

# 特定ファイルのフォーマット
dart format lib/main.dart

# フォーマット確認（変更なし）
dart format --dry-run .
```

### 5. VS Codeタスク

1. `Ctrl+Shift+P` でコマンドパレットを開く
2. "Tasks: Run Task" を選択
3. 以下のいずれかを選択：
   - "Dart: フォーマット" - 即座にフォーマット
   - "Dart: フォーマット確認" - フォーマットが必要かチェック
   - "Dart: フォーマット修正" - フォーマットを修正

## 🚨 CI/CDでのフォーマットエラー

### 問題の症状

GitHub Actionsで以下のようなエラーが発生する場合：

```
dart format --set-exit-if-changed .
Process completed with exit code 1.
```

### 解決方法

1. **ローカルでフォーマット修正**：
   ```bash
   ./scripts/format.sh fix
   git add .
   git commit -m "Fix code formatting"
   git push
   ```

2. **自動修正の有効化**：
   GitHub Actionsワークフローは自動でフォーマットを修正するように設定されています。

### ワークフローの改善

現在のワークフロー（`.github/workflows/copilot-workflow.yml`）は：

- ✅ フォーマットが必要な場合に自動修正
- ✅ 修正されたファイルの表示
- ✅ 開発者への明確な指示提供
- ✅ CI失敗の回避

## 📋 フォーマット規則

### Dart標準規則

- インデント: 2スペース
- 行長: 80文字
- 文字列: シングルクォート推奨
- コンストラクタ: ファイル先頭配置
- import整理: 自動実行

### プロジェクト固有の規則

`analysis_options.yaml`で定義：

```yaml
linter:
  rules:
    prefer_single_quotes: true
    sort_child_properties_last: true
    sort_constructors_first: true
    prefer_const_constructors: true
```

## 🔄 開発ワークフロー

### 推奨手順

1. コードを書く
2. VS Codeで保存（自動フォーマット）
3. コミット前に確認：
   ```bash
   ./scripts/format.sh check
   ```
4. 必要に応じて修正：
   ```bash
   ./scripts/format.sh fix
   ```
5. コミット・プッシュ

### プリコミットフック（オプション）

将来的にプリコミットフックを追加する場合：

```bash
# プリコミットフックのインストール
./scripts/install-hooks.sh

# 手動でインストールする場合
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

インストール後、コミット時に自動でフォーマットチェックが実行されます：

```bash
git commit -m "Update feature"
# 🔍 Pre-commit checks...
# 🎨 Checking code formatting...
# ✅ Code formatting check passed!
# ✅ Pre-commit checks completed!
```

## 🆘 トラブルシューティング

### よくある問題

#### 1. dart/flutterコマンドが見つからない

```bash
# Flutter SDKのインストール確認
flutter doctor

# PATHの設定確認
echo $PATH | grep flutter
```

#### 2. VS Codeでフォーマットが動作しない

- Dart拡張機能が有効か確認
- `.vscode/settings.json`の設定確認
- VS Codeの再起動

#### 3. 大量のフォーマット変更

```bash
# 段階的にフォーマット
dart format lib/
dart format test/
dart format .
```

## 📚 関連ドキュメント

- [Dart コードスタイルガイド](https://dart.dev/guides/language/effective-dart/style)
- [Flutter フォーマッティング](https://docs.flutter.dev/development/tools/formatting)
- `.vscode/settings.json` - VS Code設定
- `analysis_options.yaml` - 解析設定
- `scripts/format.sh` - フォーマッティングスクリプト
- `Makefile` - 開発コマンド集
- `.githooks/pre-commit` - プリコミットフック template