# Flutter開発のためのGitHub Copilot指示書

## コンテキスト
あなたは「syonan-app」という名前の娘のために設計されたFlutterモバイルアプリケーションで作業しています。このアプリは家族向け、教育的で、魅力的なものである必要があります。

**プロジェクトの特徴:**
- 子供向けの安全で教育的なコンテンツ
- 日本語ファーストのユーザーインターフェース
- アクセシビリティとユーザビリティを重視
- Flutter 3.x + Material Design 3を使用
- GitHub Copilotで開発効率を最大化

## 言語設定
- **応答言語**: 日本語でコメントや説明を提供してください
- **コード**: 英語の変数名・関数名を使用し、日本語コメントを追加
- **ドキュメント**: 日本語で記述してください
- **エラーメッセージ**: 日本語で分かりやすく表示

## Copilotベストプラクティス

### 効果的なプロンプト作成
1. **具体的な要件を明記**
   - 機能の目的と期待される動作
   - 技術的制約や制限事項
   - パフォーマンス要件
   - セキュリティ考慮事項

2. **コンテキスト情報の提供**
   - ファイルの役割と責任
   - 関連するコンポーネントとの関係
   - データフローと状態管理
   - エラーハンドリング方針

3. **段階的なタスク分解**
   - 大きなタスクを小さな単位に分割
   - 各段階での検証ポイントを明確化
   - 依存関係と実装順序を指定

### コード生成の品質向上
1. **型安全性の確保**
   - 適切な型注釈の使用
   - null safetyの活用
   - 型チェックの強化

2. **パフォーマンス最適化**
   - const constructorの使用
   - 不要なrebuildの回避
   - メモリ効率的な実装

3. **テスタビリティの考慮**
   - 依存性注入の活用
   - モック可能な設計
   - テストしやすいアーキテクチャ

## コード生成ガイドライン

### Flutterコードを生成する際:
1. **必要なパッケージを上部でインポートする**
   - Dart core ライブラリを最初に
   - Flutter framework関連を次に
   - サードパーティパッケージを続いて
   - プロジェクト内ファイルを最後に

2. **Material Design 3コンポーネントを優先使用**
   - 新しいMaterial 3ウィジェットを活用
   - テーマ設定に一貫性を保つ
   - アダプティブデザインを考慮

3. **包括的なエラーハンドリングを実装**
   - try-catchブロックの適切な使用
   - ユーザーフレンドリーなエラーメッセージ
   - エラー状態のUIを含める
   - ログ記録とデバッグ情報

4. **複雑なロジックには詳細な日本語コメントを追加**
   - アルゴリズムの説明
   - ビジネスルールの明記
   - 制約事項や注意点
   - パフォーマンス考慮事項

5. **パフォーマンス最適化**
   - constコンストラクタの使用
   - 適切なウィジェット選択
   - buildメソッドの最適化
   - メモリリーク対策

6. **アクセシビリティの実装**
   - Semanticsウィジェットの使用
   - 適切なラベルと説明
   - キーボードナビゲーション
   - 十分なコントラスト比

7. **Flutterベストプラクティスの遵守**
   - 公式ガイドラインに従う
   - コミュニティ標準の採用
   - 最新機能の活用

### 状態管理
- **ローカル状態**: StatefulWidgetまたはuseStateを使用
- **アプリ全体の状態**: Provider、Riverpod、またはBlocを検討
- **状態の永続化**: SharedPreferences、Hive、またはSQLiteを使用
- **適切なライフサイクルメソッドを実装**
- **メモリリークを防ぐためのリソース解放**

### UI/UX考慮事項
- **モバイルファーストの体験を設計**
- **子供向けの直感的なインターフェース**
- **大きめのタッチターゲット（最小44px）**
- **アクセシビリティ機能を確保**
- **子供向けの適切な色とフォント使用**
- **親しみやすく安全なデザイン**
- **レスポンシブレイアウトの実装**
- **異なる画面サイズとデバイスへの対応**

### セキュリティとプライバシー
- **子供のプライバシー保護を最優先**
- **個人情報の最小限収集**
- **COPPA（児童オンラインプライバシー保護法）準拠**
- **データ暗号化と安全な保存**
- **ネットワーク通信のセキュリティ**

### パフォーマンス最適化
- **不要なrebuildの回避**
- **適切なウィジェットの選択**
- **画像とアセットの最適化**
- **遅延読み込みの実装**
- **メモリ使用量の監視**

### コード構造
- **UIコンポーネントを再利用可能なウィジェットに分離**
- **単一責任の原則に従ったウィジェット設計**
- **適切な抽象化レベルの維持**
- **データ構造のためのモデルクラス作成**
- **immutableなデータクラスの使用**
- **API呼び出しとビジネスロジックにはサービスクラス使用**
- **Repository パターンの実装**
- **適切なエラー境界の実装**
- **グローバルエラーハンドリング**

### テストアプローチ
- **依存性注入でテスト可能なコードを生成**
- **説明的で理解しやすいテスト名を記述**
- **Arrange-Act-Assert パターンの使用**
- **外部依存関係を適切にモック化**
- **成功と失敗の両方のシナリオをテスト**
- **エッジケースと境界値のテスト**
- **カバレッジ目標の設定と達成**

### 開発効率向上
- **GitHub Copilot Chatの活用**
  - 複雑な実装についての相談
  - コードレビューの支援
  - リファクタリングの提案
  - デバッグの支援

- **効果的なプロンプト作成**
  - 具体的で明確な要件記述
  - コンテキスト情報の提供
  - 期待される出力の例示

## パターン例

### 効果的なプロンプト例
```dart
// TODO: 子供向けの安全な画像ビューアーウィジェットを作成
// 要件:
// - ズーム機能（ピンチ操作対応）
// - 子供にとって安全な画像のみ表示
// - アクセシビリティ対応（VoiceOver/TalkBack）
// - エラーハンドリング（画像読み込み失敗時）
// 制約:
// - メモリ効率的な実装
// - 60FPSを維持
// - 3歳以上の子供が使いやすいUI
```

### ウィジェット構造のベストプラクティス
```dart
// 子供向け安全カードウィジェット - 情報を見やすく表示するウィジェット
class SafeChildCard extends StatelessWidget {
  const SafeChildCard({
    super.key,
    required this.title,
    required this.content,
    this.onTap,
    this.backgroundColor,
  });

  final String title;
  final String content;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 子供向けの大きめのタッチターゲット
    return Card(
      color: backgroundColor ?? theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アクセシビリティ対応のタイトル
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### エラーハンドリングパターン
```dart
// 安全なAPIサービス実装 - エラーを適切に処理するサービス
class SafeApiService {
  static const Duration _timeout = Duration(seconds: 10);

  Future<Result<T>> safeApiCall<T>(
    Future<T> Function() apiCall,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final result = await apiCall().timeout(_timeout);
      return Result.success(result);
    } on TimeoutException {
      return Result.failure(
        const ApiError(
          message: 'ネットワーク接続がタイムアウトしました',
          code: 'TIMEOUT',
        ),
      );
    } on SocketException {
      return Result.failure(
        const ApiError(
          message: 'インターネット接続を確認してください',
          code: 'NO_INTERNET',
        ),
      );
    } catch (e) {
      return Result.failure(
        ApiError(
          message: '予期しないエラーが発生しました: $e',
          code: 'UNKNOWN',
        ),
      );
    }
  }
}

// 結果型パターン
sealed class Result<T> {
  const Result();

  factory Result.success(T data) => Success(data);
  factory Result.failure(ApiError error) => Failure(error);
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final ApiError error;
}
```

### サービスパターン
```dart
// 子供向けコンテンツサービスの抽象クラス
abstract class ChildContentService {
  Future<Result<List<SafeContent>>> getSafeContent();
  Future<Result<SafeContent>> getContentById(String id);
  Future<Result<void>> reportInappropriateContent(String contentId);
}

// 子供向けコンテンツサービスの実装クラス
class ChildContentServiceImpl implements ChildContentService {
  const ChildContentServiceImpl({
    required this.apiClient,
    required this.contentFilter,
    required this.logger,
  });

  final ApiClient apiClient;
  final ContentFilter contentFilter;
  final Logger logger;

  @override
  Future<Result<List<SafeContent>>> getSafeContent() async {
    try {
      logger.info('安全なコンテンツを取得中...');

      final response = await apiClient.get('/safe-content');
      final contentList = (response.data as List)
          .map((json) => SafeContent.fromJson(json))
          .toList();

      // 追加的な安全性フィルタリング
      final filteredContent = await contentFilter.filterContent(contentList);

      logger.info('${filteredContent.length}件の安全なコンテンツを取得');
      return Result.success(filteredContent);

    } catch (e, stackTrace) {
      logger.error('コンテンツ取得エラー', error: e, stackTrace: stackTrace);
      return Result.failure(
        ApiError(message: 'コンテンツの読み込みに失敗しました', code: 'CONTENT_LOAD_FAILED'),
      );
    }
  }
}

// 依存性注入とテスタビリティを考慮した設計例
class ContentRepository {
  const ContentRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.cacheManager,
  });

  final LocalContentDataSource localDataSource;
  final RemoteContentDataSource remoteDataSource;
  final CacheManager cacheManager;

  Future<Result<List<SafeContent>>> getContent({
    bool forceRefresh = false,
  }) async {
    // キャッシュ戦略の実装
    if (!forceRefresh) {
      final cachedContent = await localDataSource.getCachedContent();
      if (cachedContent.isNotEmpty) {
        return Result.success(cachedContent);
      }
    }

    // リモートからデータを取得
    final remoteResult = await remoteDataSource.fetchContent();
    return remoteResult.when(
      success: (content) async {
        // ローカルキャッシュに保存
        await localDataSource.saveContent(content);
        return Result.success(content);
      },
      failure: (error) => Result.failure(error),
    );
  }
}
```

### 状態管理パターン (Riverpod使用例)
```dart
// 安全なコンテンツの状態管理
@riverpod
class SafeContentNotifier extends _$SafeContentNotifier {
  @override
  Future<List<SafeContent>> build() async {
    // 初期化時にコンテンツを読み込み
    final repository = ref.read(contentRepositoryProvider);
    final result = await repository.getContent();

    return result.when(
      success: (content) => content,
      failure: (error) {
        // エラー状態の処理
        ref.read(errorNotifierProvider.notifier).showError(error.message);
        return <SafeContent>[];
      },
    );
  }

  // コンテンツの更新
  Future<void> refreshContent() async {
    state = const AsyncLoading();

    final repository = ref.read(contentRepositoryProvider);
    final result = await repository.getContent(forceRefresh: true);

    state = result.when(
      success: (content) => AsyncData(content),
      failure: (error) => AsyncError(error, StackTrace.current),
    );
  }

  // 安全でないコンテンツの報告
  Future<void> reportContent(String contentId) async {
    final service = ref.read(childContentServiceProvider);
    final result = await service.reportInappropriateContent(contentId);

    result.when(
      success: (_) {
        // 成功時の処理（コンテンツリストから除去など）
        state.whenData((currentContent) {
          final updatedContent = currentContent
              .where((content) => content.id != contentId)
              .toList();
          state = AsyncData(updatedContent);
        });
      },
      failure: (error) {
        ref.read(errorNotifierProvider.notifier).showError(error.message);
      },
    );
  }
}