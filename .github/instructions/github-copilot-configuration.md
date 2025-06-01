# GitHub Copilot 設定指示書

## コード生成 (CodeGeneration) 設定

GitHub Copilotのコード生成機能を最大限活用するための設定と使用方法です。

### インライン提案の活用
- `github.copilot.inlineSuggest.enable`: インライン提案を有効化
- コード入力中にTab キーで提案を受け入れ
- Ctrl+] で次の提案、Ctrl+[ で前の提案

### 効果的なプロンプト作成
```dart
// ✅ 良い例: 具体的で詳細な要求
// TODO: 小学三年生向けの掛け算練習ウィジェットを作成
// 要件:
// - 1-9の数字を使用
// - 視覚的なヒント付き（ドット表示など）
// - 制限時間30秒
// - アクセシビリティ対応（VoiceOver対応）
// - Material Design 3準拠
// - エラーハンドリング含む
class MultiplicationWidget extends StatefulWidget {
  // Copilotがここで適切なコードを生成
}

// ❌ 悪い例: 曖昧で詳細不足
// ウィジェット作成
class Widget {
}
```

### コードアクション活用
- `github.copilot.editor.enableCodeActions`: コードアクション有効化
- 電球アイコンからCopilot提案を利用
- クイックフィックスとリファクタリング提案

## コードレビュー (CodeReview) 設定

Copilot Chatを使用したコードレビュー機能の活用方法です。

### チャット機能の活用
- `github.copilot.chat.editorFixing`: エディタ内修正機能
- `github.copilot.chat.followUps`: フォローアップ質問を常に表示
- `github.copilot.chat.codesearch.enabled`: コード検索機能有効化

### 効果的なレビュー依頼
```
# セキュリティレビュー
@github このコードが子供向けアプリのセキュリティ要件を満たしているかレビューしてください。特に個人情報の取り扱いとデータ保護について確認してください。

# パフォーマンスレビュー  
@github このFlutterウィジェットのパフォーマンス問題を特定し、最適化案を提案してください。60FPSを維持する必要があります。

# アクセシビリティレビュー
@github このUIが小学生向けアプリとして適切なアクセシビリティを提供しているかチェックしてください。

# コード品質レビュー
@github このDartコードがFlutterのベストプラクティスに従っているかレビューし、改善点を提案してください。
```

### 自動修正機能
- `github.copilot.chat.agent.autoFix`: 自動修正提案
- エラーや警告に対する修正案の自動生成
- リファクタリング提案の自動生成

## コメント生成 (CommentGeneration) 設定

プロジェクトに特化したコメントとドキュメント生成の設定です。

### プロジェクト固有設定
- `github.copilot.conversation.additionalInstructions`: プロジェクト固有指示
- `github.copilot.chat.localeOverride`: 日本語優先設定

### ドキュメント生成パターン

#### クラスドキュメント
```dart
/// 小学三年生向けの算数練習問題を管理するクラス
/// 
/// このクラスは以下の機能を提供します：
/// - 年齢に適した問題の生成
/// - 学習進捗の追跡
/// - 適切なフィードバックの提供
/// 
/// 使用例:
/// ```dart
/// final exercises = MathExerciseManager(level: 3);
/// final problem = await exercises.generateProblem();
/// ```
class MathExerciseManager {
  // 実装...
}
```

#### 関数ドキュメント
```dart
/// 学生の回答を検証し、適切なフィードバックを提供します
/// 
/// [studentAnswer] 学生が入力した回答
/// [correctAnswer] 正しい答え
/// [timeSpent] 回答にかかった時間（秒）
/// 
/// Returns: 詳細なフィードバック情報を含む[AnswerResult]
/// 
/// Throws: 
/// - [ArgumentError] 無効な引数が渡された場合
/// - [ValidationError] 回答形式が正しくない場合
Future<AnswerResult> validateAnswer({
  required int studentAnswer,
  required int correctAnswer,
  required int timeSpent,
}) async {
  // 実装...
}
```

### コメント生成の依頼方法
```
# JavaDocコメント生成
@github この関数に教育アプリに適したJavaDocコメントを日本語で生成してください

# READMEセクション生成
@github この機能の使用方法を説明するREADMEセクションを日本語で作成してください

# コードの説明コメント
@github この複雑なアルゴリズムに理解しやすい日本語コメントを追加してください
```

## 設定値の説明

### 基本設定
```json
{
  // インライン提案を有効化
  "github.copilot.inlineSuggest.enable": true,
  
  // コードアクションを有効化
  "github.copilot.editor.enableCodeActions": true,
  
  // 反復的修正機能を有効化
  "github.copilot.editor.iterativeFixing": true,
  
  // 次の編集提案を有効化
  "github.copilot.nextEdit.enabled": true
}
```

### チャット設定
```json
{
  // エディタ内修正機能
  "github.copilot.chat.editorFixing": true,
  
  // ウェルカムメッセージを常に表示
  "github.copilot.chat.welcomeMessage": "always",
  
  // フォローアップ質問を常に有効
  "github.copilot.chat.followUps": "always",
  
  // 自動修正エージェント
  "github.copilot.chat.agent.autoFix": true,
  
  // コード検索機能
  "github.copilot.chat.codesearch.enabled": true
}
```

### ローカライゼーション設定
```json
{
  // 日本語でのやり取りを優先
  "github.copilot.chat.localeOverride": "ja",
  
  // プロジェクト固有の指示
  "github.copilot.conversation.additionalInstructions": "このプロジェクトは小学三年生向けの日本語算数練習アプリ「syonan-app」です。安全で教育的なコードを心がけ、子供向けのアクセシブルなデザインを優先してください。コメントとドキュメントは日本語で記述してください。"
}
```

## 使用例とベストプラクティス

### 段階的開発アプローチ
1. **要件定義をコメントで記述**
   ```dart
   // TODO: 小学三年生向けの引き算練習画面を作成
   // 要件: 0-100の範囲、ビジュアルヒント、制限時間あり
   ```

2. **Copilotに基本構造を生成させる**
   ```dart
   // 上記のコメントから基本的なウィジェット構造を生成
   ```

3. **詳細機能を段階的に追加**
   ```dart
   // TODO: タイマー機能を追加
   // TODO: アニメーション効果を追加
   // TODO: アクセシビリティ対応を強化
   ```

4. **レビューと改善**
   ```
   @github この実装をレビューしてパフォーマンスとアクセシビリティの改善点を提案してください
   ```

### エラー処理パターン
```dart
// TODO: 子供向けの分かりやすいエラーハンドリングを実装
// 要件: 
// - 怖がらせない優しいメッセージ
// - 再試行の促し
// - 保護者への通知オプション
// - ログ記録（デバッグ用）
try {
  // メイン処理
} catch (e) {
  // Copilotが適切なエラーハンドリングを生成
}
```

### テストコード生成
```dart
// TODO: このウィジェットの包括的なテストを作成
// テスト項目:
// - 正常な表示確認
// - ユーザー入力の処理
// - エラー状態の処理
// - アクセシビリティ対応確認
```

## トラブルシューティング

### 提案の品質が低い場合
1. **より具体的なコンテキストを提供**
   - 機能の目的を明確に記述
   - 技術的制約を詳細に説明
   - 期待される動作を具体的に記述

2. **コメントの改善**
   - 曖昧な表現を避ける
   - 技術用語を正確に使用
   - 期待される出力例を提供

3. **段階的なアプローチ**
   - 大きなタスクを小さく分割
   - 一度に一つの機能に集中
   - 前回の結果を基に次のステップを依頼

### 設定の検証
```typescript
// VS Code設定の検証用コマンド
// Ctrl+Shift+P → "GitHub Copilot: Check Status"
// 設定が正しく適用されているか確認
```