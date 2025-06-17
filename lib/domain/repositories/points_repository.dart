import 'math_problem_repository.dart'; // Resultクラスを使用

/// ポイントシステムリポジトリの抽象クラス
abstract class PointsRepository {
  /// 現在のポイント数を取得
  Future<Result<int>> getTotalPoints();

  /// ポイントを追加
  Future<Result<void>> addPoints(int points);

  /// ポイントを使用
  Future<Result<void>> usePoints(int points);

  /// ポイントを設定
  Future<Result<void>> setPoints(int points);

  /// ポイント履歴を取得
  Future<Result<List<Map<String, dynamic>>>> getPointsHistory();

  /// 今日獲得したポイントを取得
  Future<Result<int>> getTodayPoints();

  /// 今週獲得したポイントを取得
  Future<Result<int>> getWeeklyPoints();

  /// 今月獲得したポイントを取得
  Future<Result<int>> getMonthlyPoints();

  /// 累計獲得ポイントを取得
  Future<Result<int>> getTotalEarnedPoints();

  /// 累計使用ポイントを取得
  Future<Result<int>> getTotalUsedPoints();

  /// ポイント統計を取得
  Future<Result<Map<String, dynamic>>> getPointsStatistics();

  /// ポイント履歴をクリア
  Future<Result<void>> clearPointsHistory();

  /// すべてのポイントデータをリセット
  Future<Result<void>> resetAllPoints();
}
