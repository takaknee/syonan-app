import '../../core/errors/failures.dart';
import '../../domain/entities/score_record_entity.dart';
import '../../domain/repositories/math_problem_repository.dart'; // Result型のために必要
import '../../domain/repositories/score_repository.dart';
import '../datasources/score_record_local_datasource.dart';
import '../models/score_record_model.dart';

/// スコア記録のリポジトリ実装
class ScoreRepositoryImpl implements ScoreRepository {
  final ScoreRecordLocalDataSource _localDataSource;

  ScoreRepositoryImpl(this._localDataSource);

  @override
  Future<Result<void>> saveScore(ScoreRecordEntity scoreRecord) async {
    try {
      final model = ScoreRecordModel.fromEntity(scoreRecord);
      await _localDataSource.saveScoreRecord(model);
      return Success(null);
    } catch (e) {
      return ResultFailure(DataFailure('スコアの保存に失敗しました'));
    }
  }

  @override
  Future<Result<List<ScoreRecordEntity>>> getAllScores() async {
    try {
      final models = await _localDataSource.getAllScoreRecords();
      return Success(models.cast<ScoreRecordEntity>());
    } catch (e) {
      return ResultFailure(DataFailure('スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<List<ScoreRecordEntity>>> getScoresByUser(String userId) async {
    try {
      final models = await _localDataSource.getScoreRecordsByUser(userId);
      return Success(models.cast<ScoreRecordEntity>());
    } catch (e) {
      return ResultFailure(DataFailure('ユーザー別スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<List<ScoreRecordEntity>>> getScoresByGameType(
    GameType gameType, {
    String? userId,
  }) async {
    try {
      final models = await _localDataSource.getScoreRecordsByGameType(
        gameType,
        userId: userId,
      );
      return Success(models.cast<ScoreRecordEntity>());
    } catch (e) {
      return ResultFailure(DataFailure('ゲームタイプ別スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<List<ScoreRecordEntity>>> getRecentScores({
    int limit = 10,
    String? userId,
  }) async {
    try {
      final models = await _localDataSource.getRecentScoreRecords(
        limit: limit,
        userId: userId,
      );
      return Success(models.cast<ScoreRecordEntity>());
    } catch (e) {
      return ResultFailure(DataFailure('最新スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getScoreStatistics(
      {String? userId}) async {
    try {
      final stats = await _localDataSource.getScoreStatistics(userId: userId);
      return Success(stats);
    } catch (e) {
      return ResultFailure(DataFailure('スコア統計の取得に失敗しました'));
    }
  }

  @override
  Future<Result<List<ScoreRecordEntity>>> getScoresByOperation(
    MathOperationType operation,
  ) async {
    try {
      final models =
          await _localDataSource.getScoreRecordsByOperation(operation);
      return Success(models.cast<ScoreRecordEntity>());
    } catch (e) {
      return ResultFailure(DataFailure('操作タイプ別スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<List<ScoreRecordEntity>>> getScoresByDifficulty(
    int difficultyLevel,
  ) async {
    try {
      final allModels = await _localDataSource.getAllScoreRecords();
      final filtered = allModels
          .where((score) => score.difficultyLevel == difficultyLevel)
          .toList();
      return Success(filtered.cast<ScoreRecordEntity>());
    } catch (e) {
      return ResultFailure(DataFailure('難易度別スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<List<ScoreRecordEntity>>> getScoresByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allModels = await _localDataSource.getAllScoreRecords();
      final filtered = allModels
          .where((score) =>
              score.timestamp.isAfter(startDate) &&
              score.timestamp.isBefore(endDate))
          .toList();
      return Success(filtered.cast<ScoreRecordEntity>());
    } catch (e) {
      return ResultFailure(DataFailure('期間別スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<double>> getAverageScore(MathOperationType operation) async {
    try {
      final models =
          await _localDataSource.getScoreRecordsByOperation(operation);
      if (models.isEmpty) return Success(0.0);

      final total = models.map((s) => s.score).fold(0, (a, b) => a + b);
      final average = total / models.length;
      return Success(average.toDouble());
    } catch (e) {
      return ResultFailure(DataFailure('平均スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<ScoreRecordEntity?>> getBestScore(
      MathOperationType operation) async {
    try {
      final model = await _localDataSource.getBestScore(operation: operation);
      return Success(model);
    } catch (e) {
      return ResultFailure(DataFailure('ベストスコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<ScoreRecordEntity?>> getLatestScore(
      MathOperationType operation) async {
    try {
      final models =
          await _localDataSource.getScoreRecordsByOperation(operation);
      if (models.isEmpty) return Success(null);

      models.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(models.first);
    } catch (e) {
      return ResultFailure(DataFailure('最新スコアの取得に失敗しました'));
    }
  }

  @override
  Future<Result<int>> getStreakDays() async {
    try {
      final allModels = await _localDataSource.getAllScoreRecords();
      if (allModels.isEmpty) return Success(0);

      // 日付でグループ化して連続日数を計算
      final practicesDays = allModels
          .map((s) =>
              DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day))
          .toSet()
          .toList();

      practicesDays.sort((a, b) => b.compareTo(a));

      int streak = 0;
      DateTime? lastDate;

      for (final date in practicesDays) {
        if (lastDate == null) {
          streak = 1;
          lastDate = date;
        } else if (lastDate.difference(date).inDays == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }

      return Success(streak);
    } catch (e) {
      return ResultFailure(DataFailure('連続練習日数の取得に失敗しました'));
    }
  }

  @override
  Future<Result<int>> getWeeklyPracticeCount() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final result = await getScoresByDateRange(startOfWeek, endOfWeek);
      if (result.isFailure) return ResultFailure(result.failure);

      return Success(result.data.length);
    } catch (e) {
      return ResultFailure(DataFailure('週間練習回数の取得に失敗しました'));
    }
  }

  @override
  Future<Result<int>> getMonthlyPracticeCount() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final result = await getScoresByDateRange(startOfMonth, endOfMonth);
      if (result.isFailure) return ResultFailure(result.failure);

      return Success(result.data.length);
    } catch (e) {
      return ResultFailure(DataFailure('月間練習回数の取得に失敗しました'));
    }
  }

  @override
  Future<Result<void>> deleteScore(String scoreId) async {
    try {
      await _localDataSource.deleteScoreRecord(scoreId);
      return Success(null);
    } catch (e) {
      return ResultFailure(DataFailure('スコアの削除に失敗しました'));
    }
  }

  @override
  Future<Result<void>> clearAllScores() async {
    try {
      await _localDataSource.clearAllScoreRecords();
      return Success(null);
    } catch (e) {
      return ResultFailure(DataFailure('スコアのクリアに失敗しました'));
    }
  }
}
