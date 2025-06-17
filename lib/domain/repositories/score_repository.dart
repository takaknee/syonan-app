import '../entities/score_record_entity.dart';
import 'math_problem_repository.dart'; // Resultクラスを使用

/// スコア記録リポジトリの抽象クラス
abstract class ScoreRepository {
  /// スコアを保存
  Future<Result<void>> saveScore(ScoreRecordEntity score);

  /// すべてのスコアを取得
  Future<Result<List<ScoreRecordEntity>>> getAllScores();

  /// ユーザー別のスコアを取得
  Future<Result<List<ScoreRecordEntity>>> getScoresByUser(String userId);

  /// ゲームタイプ別のスコアを取得
  Future<Result<List<ScoreRecordEntity>>> getScoresByGameType(
    GameType gameType, {
    String? userId,
  });

  /// 操作タイプ別のスコアを取得
  Future<Result<List<ScoreRecordEntity>>> getScoresByOperation(
    MathOperationType operation,
  );

  /// 難易度別のスコアを取得
  Future<Result<List<ScoreRecordEntity>>> getScoresByDifficulty(
    int difficultyLevel,
  );

  /// 期間指定でスコアを取得
  Future<Result<List<ScoreRecordEntity>>> getScoresByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// 最新のスコアを取得
  Future<Result<List<ScoreRecordEntity>>> getRecentScores({
    int limit = 10,
    String? userId,
  });

  /// 平均スコアを取得
  Future<Result<double>> getAverageScore(MathOperationType operation);

  /// 最高スコアを取得
  Future<Result<ScoreRecordEntity?>> getBestScore(MathOperationType operation);

  /// 最新のスコアを取得
  Future<Result<ScoreRecordEntity?>> getLatestScore(MathOperationType operation);

  /// スコア統計を取得
  Future<Result<Map<String, dynamic>>> getScoreStatistics({String? userId});

  /// 連続練習日数を取得
  Future<Result<int>> getStreakDays();

  /// 週間練習回数を取得
  Future<Result<int>> getWeeklyPracticeCount();

  /// 月間練習回数を取得
  Future<Result<int>> getMonthlyPracticeCount();

  /// スコアを削除
  Future<Result<void>> deleteScore(String scoreId);

  /// すべてのスコアを削除
  Future<Result<void>> clearAllScores();
}
