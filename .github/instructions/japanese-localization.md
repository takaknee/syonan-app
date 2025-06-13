# GitHub Actions と Copilot の日本語化設定

## 概要
このプロジェクトでは、GitHub ActionsのコメントやCopilotの出力を日本語で統一します。

## Copilot への指示

### 基本原則
- **コメント**: 常に日本語で記述
- **GitHub Actions**: 日本語でのコメント出力
- **エラーメッセージ**: 日本語で説明
- **PR/Issue**: 日本語での説明

### 具体的な指示

#### 1. GitHub Actions ワークフロー
```yaml
# 例: 日本語でのステップ名とコメント
- name: "📦 依存関係のインストール"
  run: |
    echo "🔍 依存関係をインストール中..."
    npm install
    echo "✅ インストール完了"
```

#### 2. Copilot Chat での指示
- 「すべての出力を日本語で記述してください」
- 「コメントは日本語で詳細に説明してください」
- 「エラーメッセージは子供にも分かりやすい日本語で」

#### 3. コード生成時の指示
```dart
// 例: 日本語コメントの例
class MathProblem {
  // 数学問題のデータモデル
  // 子供向けの算数練習用に設計
  
  /// 問題を生成する
  /// [difficulty] - 難易度レベル（1-5）
  /// [operation] - 演算タイプ（足し算、引き算など）
  static MathProblem generate(int difficulty, MathOperationType operation) {
    // 実装...
  }
}
```

## 設定の適用方法

### 1. VS Code Settings
```json
{
  "github.copilot.editor.enableAutoCompletions": true,
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "plaintext": true,
    "markdown": true
  }
}
```

### 2. 環境変数
```bash
export GITHUB_COPILOT_LANGUAGE=ja
export COPILOT_OUTPUT_LANGUAGE=japanese
```

### 3. プロンプトテンプレート
```
以下の指示に従ってコードを生成してください：
- すべてのコメントは日本語で記述
- GitHub Actionsのメッセージは日本語で出力
- エラーハンドリングは日本語で説明
- 子供向けアプリケーションに適した表現を使用
```

## 既存ワークフローの更新

既存のGitHub Actionsワークフローを日本語化するために、以下のパターンを使用：

### Before (英語)
```yaml
- name: "Run tests"
  run: |
    echo "Running tests..."
    npm test
    echo "Tests completed"
```

### After (日本語)
```yaml
- name: "🧪 テスト実行"
  run: |
    echo "🔍 テストを実行中..."
    npm test
    echo "✅ テスト完了"
```

## 継続的な改善

1. **定期的な確認**: 新しいワークフローやスクリプトが日本語化されているか確認
2. **チームガイドライン**: 開発チーム全体での日本語化の統一
3. **自動化**: 可能な限り自動化ツールで日本語化を強制

## 注意点

- **国際化対応**: 将来的に多言語対応する場合を考慮
- **専門用語**: 技術的な用語は適切な日本語訳を使用
- **読みやすさ**: 過度に長い日本語は避け、簡潔で分かりやすい表現を心がける
