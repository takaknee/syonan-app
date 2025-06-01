# Flutter開発のためのGitHub Copilot指示書

## コンテキスト
あなたは「syonan-app」という名前の娘のために設計されたFlutterモバイルアプリケーションで作業しています。このアプリは家族向け、教育的で、魅力的なものである必要があります。

## 言語設定
- **応答言語**: 日本語でコメントや説明を提供してください
- **コード**: 英語の変数名・関数名を使用し、日本語コメントを追加
- **ドキュメント**: 日本語で記述してください

## コード生成ガイドライン

### Flutterコードを生成する際:
1. 必要なパッケージを上部でインポートする
2. 利用可能な場合はMaterial Design 3コンポーネントを使用
3. 適切なエラーハンドリングを実装
4. 複雑なロジックには意味のある日本語コメントを追加
5. パフォーマンスのためにconstコンストラクタを使用
6. Flutterの命名規則に従う

### 状態管理
- ローカル状態にはStatefulWidgetを使用
- アプリ全体の状態にはProviderやRiverpodを検討
- 適切なライフサイクルメソッドを実装

### UI/UX考慮事項
- モバイルファーストの体験を設計
- アクセシビリティ機能を確保
- 子供向けの適切な色とフォントを使用
- レスポンシブレイアウトを実装

### コード構造
- UIコンポーネントを再利用可能なウィジェットに分離
- データ構造のためのモデルを作成
- API呼び出しとビジネスロジックにはサービスを使用
- 適切なエラー境界を実装

### テストアプローチ
- 依存性注入でテスト可能なコードを生成
- 説明的なテスト名を記述
- 外部依存関係をモック化
- 成功と失敗の両方のシナリオをテスト

## パターン例

### ウィジェット構造
```dart
// マイウィジェット - タイトルを表示するウィジェット
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.title});
  
  final String title;
  
  @override
  Widget build(BuildContext context) {
    // ウィジェットの実装
    return Container(); // 実装部分
  }
}
```

### サービスパターン
```dart
// マイサービスの抽象クラス
abstract class MyService {
  Future<Result> performAction();
}

// マイサービスの実装クラス
class MyServiceImpl implements MyService {
  @override
  Future<Result> performAction() async {
    // 実装部分
  }
}
```