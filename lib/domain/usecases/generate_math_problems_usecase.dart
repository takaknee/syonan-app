import '../../core/errors/failures.dart';
import '../entities/math_problem_entity.dart';
import '../repositories/math_problem_repository.dart';

/// 算数問題生成のユースケース
class GenerateMathProblemsUseCase {
  final MathProblemRepository _repository;

  const GenerateMathProblemsUseCase(this._repository);

  /// 複数の問題を生成する
  Future<Result<List<MathProblemEntity>>> call({
    required MathOperationType operation,
    required int count,
    int? difficultyLevel,
  }) async {
    // 入力検証
    if (count <= 0) {
      return ResultFailure(
        ValidationFailure('問題数は1以上である必要があります'),
      );
    }

    if (count > 50) {
      return ResultFailure(
        ValidationFailure('問題数は50以下である必要があります'),
      );
    }

    if (difficultyLevel != null &&
        (difficultyLevel < 1 || difficultyLevel > 5)) {
      return ResultFailure(
        ValidationFailure('難易度レベルは1～5の範囲である必要があります'),
      );
    }

    try {
      return await _repository.generateProblems(
        operation: operation,
        count: count,
        difficultyLevel: difficultyLevel,
      );
    } catch (e) {
      return ResultFailure(
        DataFailure('問題生成中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }
}

/// 単一の算数問題生成のユースケース
class GenerateSingleMathProblemUseCase {
  final MathProblemRepository _repository;

  const GenerateSingleMathProblemUseCase(this._repository);

  /// 単一の問題を生成する
  Future<Result<MathProblemEntity>> call({
    required MathOperationType operation,
    int? difficultyLevel,
  }) async {
    // 入力検証
    if (difficultyLevel != null &&
        (difficultyLevel < 1 || difficultyLevel > 5)) {
      return ResultFailure(
        ValidationFailure('難易度レベルは1～5の範囲である必要があります'),
      );
    }

    try {
      return await _repository.generateProblem(
        operation: operation,
        difficultyLevel: difficultyLevel,
      );
    } catch (e) {
      return ResultFailure(
        DataFailure('問題生成中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }
}

/// 問題設定取得のユースケース
class GetProblemSettingsUseCase {
  final MathProblemRepository _repository;

  const GetProblemSettingsUseCase(this._repository);

  /// 問題設定を取得する
  Future<Result<Map<String, dynamic>>> call() async {
    try {
      return await _repository.getProblemSettings();
    } catch (e) {
      return ResultFailure(
        DataFailure('問題設定の取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }
}

/// 問題統計取得のユースケース
class GetProblemStatisticsUseCase {
  final MathProblemRepository _repository;

  const GetProblemStatisticsUseCase(this._repository);

  /// 問題統計を取得する
  Future<Result<Map<String, dynamic>>> call() async {
    try {
      return await _repository.getProblemStatistics();
    } catch (e) {
      return ResultFailure(
        DataFailure('問題統計の取得中にエラーが発生しました: ${e.toString()}'),
      );
    }
  }
}
