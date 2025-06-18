import '../../core/errors/failures.dart';
import '../entities/score_record_entity.dart';
import '../repositories/math_problem_repository.dart';
import '../repositories/score_repository.dart';

/// スコア保存のユースケース
class SaveScoreUseCase {
  final ScoreRepository _repository;

  const SaveScoreUseCase(this._repository);

  /// スコアを保存する
  Future<Result<void>> call(ScoreRecordEntity score) async {
    // 入力検証
    if (score.totalCount <= 0) {
      return ResultFailure(
        ValidationFailure('総問題数は1以上である必要があります'),
      );
    }

    if (score.correctCount < 0 || score.correctCount > score.totalCount) {
      return ResultFailure(
        ValidationFailure('正答数が無効です'),
      );
    }

    if (score.accuracy < 0.0 || score.accuracy > 1.0) {
      return ResultFailure(
        ValidationFailure('正答率は0.0～1.0の範囲である必要があります'),
      );
    }

    try {
      return await _repository.saveScore(score);
    } catch (e) {
      return ResultFailure(
        StorageFailure('スコアの保存中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }
}

/// スコア取得のユースケース
class GetScoresUseCase {
  final ScoreRepository _repository;

  const GetScoresUseCase(this._repository);

  /// すべてのスコアを取得する
  Future<Result<List<ScoreRecordEntity>>> getAllScores() async {
    try {
      return await _repository.getAllScores();
    } catch (e) {
      return ResultFailure(
        DataFailure('スコアの取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }

  /// 操作タイプ別のスコアを取得する
  Future<Result<List<ScoreRecordEntity>>> getScoresByOperation(
    MathOperationType operation,
  ) async {
    try {
      return await _repository.getScoresByOperation(operation);
    } catch (e) {
      return ResultFailure(
        DataFailure('スコアの取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }

  /// 期間指定でスコアを取得する
  Future<Result<List<ScoreRecordEntity>>> getScoresByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // 入力検証
    if (startDate.isAfter(endDate)) {
      return ResultFailure(
        ValidationFailure('開始日は終了日より前である必要があります'),
      );
    }

    try {
      return await _repository.getScoresByDateRange(startDate, endDate);
    } catch (e) {
      return ResultFailure(
        DataFailure('スコアの取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }
}

/// スコア統計取得のユースケース
class GetScoreStatisticsUseCase {
  final ScoreRepository _repository;

  const GetScoreStatisticsUseCase(this._repository);

  /// 平均スコアを取得する
  Future<Result<double>> getAverageScore(MathOperationType operation) async {
    try {
      return await _repository.getAverageScore(operation);
    } catch (e) {
      return ResultFailure(
        DataFailure('平均スコアの取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }

  /// 最高スコアを取得する
  Future<Result<ScoreRecordEntity?>> getBestScore(
      MathOperationType operation) async {
    try {
      return await _repository.getBestScore(operation);
    } catch (e) {
      return ResultFailure(
        DataFailure('最高スコアの取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }

  /// 連続練習日数を取得する
  Future<Result<int>> getStreakDays() async {
    try {
      return await _repository.getStreakDays();
    } catch (e) {
      return ResultFailure(
        DataFailure('連続練習日数の取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }

  /// 週間練習回数を取得する
  Future<Result<int>> getWeeklyPracticeCount() async {
    try {
      return await _repository.getWeeklyPracticeCount();
    } catch (e) {
      return ResultFailure(
        DataFailure('週間練習回数の取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }

  /// スコア統計を取得する
  Future<Result<Map<String, dynamic>>> getScoreStatistics() async {
    try {
      return await _repository.getScoreStatistics();
    } catch (e) {
      return ResultFailure(
        DataFailure('スコア統計の取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }
}
