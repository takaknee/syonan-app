# syonan-app プロジェクト コンテキスト

## プロジェクト概要
「syonan-app」は小学三年生向けの日本語算数練習アプリケーションです。
このFlutterアプリは教育目的で設計され、子供の学習をサポートすることを主目的としています。

## 開発方針

### 教育的価値
- 小学三年生レベルの算数（加算、減算、乗算、除算）に特化
- 段階的な学習進度をサポート
- 正解・不正解に対する建設的なフィードバック
- 学習モチベーションを高める仕組み

### 安全性とプライバシー
- 子供向けの安全なコンテンツのみ
- 個人情報の最小限収集
- COPPA（児童オンラインプライバシー保護法）準拠
- オフライン優先の設計

### ユーザビリティ
- 直感的で分かりやすいインターフェース
- 大きめのタッチターゲット（最小44px）
- 読みやすいフォントとコントラスト
- アクセシビリティ機能の完全サポート

## 技術仕様

### 開発環境
- Flutter 3.x
- Dart 3.x
- Material Design 3
- VS Code + GitHub Copilot

### 対象プラットフォーム
- Android（メイン）
- iOS（サブ）
- Web（補助的）

### アーキテクチャ
- Clean Architecture
- Repository Pattern
- Provider/Riverpod for State Management
- オフライン優先設計

## コード生成指針

### 命名規則
```dart
// クラス名: UpperCamelCase
class MathExerciseWidget extends StatelessWidget {}

// 変数名・関数名: lowerCamelCase
int studentAnswer = 0;
void calculateScore() {}

// 定数: lowerCamelCase with descriptive names
const int maxExerciseCount = 10;
const Duration answerTimeLimit = Duration(seconds: 30);

// ファイル名: snake_case
// math_exercise_screen.dart
// student_progress_service.dart
```

### コメント指針
```dart
// 機能の説明は日本語で記述
/// 学生の回答を検証し、正誤判定を行う
///
/// [studentAnswer] 学生が入力した回答
/// [correctAnswer] 正しい回答
///
/// Returns: 正解の場合true、不正解の場合false
bool validateAnswer(int studentAnswer, int correctAnswer) {
  // 実装...
}
```

### エラーハンドリング
```dart
// 子供向けの分かりやすいエラーメッセージ
try {
  // 処理...
} catch (e) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('おっと！'),
      content: const Text('何か問題が発生しました。もう一度試してみてください。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('わかりました'),
        ),
      ],
    ),
  );
}
```

## UI/UXガイドライン

### カラーパレット
```dart
// 子供向けの親しみやすい色使い
const primaryColor = Color(0xFF2196F3);    // 青
const secondaryColor = Color(0xFF4CAF50);  // 緑
const errorColor = Color(0xFFFF5722);      // オレンジ（優しいエラー色）
const successColor = Color(0xFF8BC34A);    // ライトグリーン
```

### タイポグラフィ
```dart
// 読みやすいフォントサイズ
const double headingFontSize = 24.0;
const double bodyFontSize = 18.0;
const double buttonFontSize = 16.0;

// フォントウェイト
const FontWeight headingWeight = FontWeight.bold;
const FontWeight bodyWeight = FontWeight.normal;
```

### レイアウト
```dart
// 適切な間隔とパディング
const double standardPadding = 16.0;
const double largePadding = 24.0;
const double smallPadding = 8.0;

// タッチターゲットサイズ
const double minTouchTarget = 44.0;
const double buttonHeight = 48.0;
```

## 教育コンテンツ指針

### 問題生成
- 年齢に適した難易度設定
- 段階的な複雑さの増加
- 実生活に関連した問題設定
- 多様性のある問題パターン

### フィードバック設計
```dart
// 正解時のメッセージ例
const List<String> correctAnswerMessages = [
  'すごい！正解です！',
  'よくできました！',
  'その調子です！',
  'すばらしい！',
];

// 不正解時の励ましメッセージ例
const List<String> incorrectAnswerMessages = [
  'あと少しです！もう一度考えてみましょう',
  '惜しい！もう一度挑戦してみてください',
  '大丈夫！ゆっくり考えてみてください',
];
```

### 進捗管理
```dart
// 学習進捗の追跡
class LearningProgress {
  final int correctAnswers;
  final int totalAttempts;
  final double accuracyRate;
  final Duration studyTime;
  final List<String> masteredTopics;
  final List<String> challengingTopics;

  // 子供の自信を築く進捗表示
  String get encouragementMessage {
    if (accuracyRate >= 0.9) return 'すばらしい成績です！';
    if (accuracyRate >= 0.7) return 'とても良くできています！';
    if (accuracyRate >= 0.5) return '順調に成長しています！';
    return '一歩ずつ頑張りましょう！';
  }
}
```

## セキュリティ要件

### データ保護
- ローカルストレージのみ使用
- 個人を特定できる情報は保存しない
- 学習データの暗号化
- ペアレンタルコントロール対応

### 安全なコンテンツ
- 暴力的・不適切なコンテンツの排除
- 子供向けの安全な言葉遣い
- 教育的価値のあるコンテンツのみ

## テスト戦略

### 単体テスト
- 算数計算ロジックの正確性
- 問題生成アルゴリズムの検証
- 進捗計算の正確性

### ウィジェットテスト
- ユーザーインタラクションの動作確認
- アクセシビリティ機能の検証
- 異なる画面サイズでの表示確認

### 統合テスト
- 学習フローの完全性
- データ永続化の確認
- パフォーマンステスト

## GitHub Copilot活用例

### CodeGeneration使用例
```dart
// TODO: 小学三年生向けの足し算問題を生成するウィジェットを作成
// 要件:
// - 1桁〜2桁の数字を使用
// - ランダムな問題生成
// - 視覚的に分かりやすい表示
// - アクセシビリティ対応
// - 正解・不正解のフィードバック
```

### CodeReview活用例
```
@github このコードが小学生向けアプリのセキュリティ要件を満たしているかレビューしてください
@github このウィジェットのアクセシビリティ改善点を提案してください
@github この算数ロジックが年齢に適切かチェックしてください
```

### CommentGeneration活用例
```
@github この関数に教育アプリに適したJavaDocコメントを日本語で生成してください
@github このクラスの役割と使用方法を説明するドキュメントを作成してください
```

## 品質保証

### コードレビューチェックリスト
- [ ] 子供向けの安全なコンテンツか
- [ ] アクセシビリティ要件を満たしているか
- [ ] 教育的価値があるか
- [ ] パフォーマンスは適切か
- [ ] エラーハンドリングは適切か
- [ ] 日本語コメントが適切に記述されているか

### リリース前チェック
- [ ] 子供によるユーザビリティテスト
- [ ] 保護者によるコンテンツレビュー
- [ ] アクセシビリティ専門家による検証
- [ ] セキュリティ監査の完了
