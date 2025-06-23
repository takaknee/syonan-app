import '../../core/errors/failures.dart';
import '../../domain/entities/math_problem_entity.dart';
import '../../domain/repositories/math_problem_repository.dart';
import '../datasources/math_problem_local_datasource.dart';

/// 算数問題リポジトリの実装
class MathProblemRepositoryImpl implements MathProblemRepository {
  const MathProblemRepositoryImpl(this._localDataSource);
  final MathProblemLocalDataSource _localDataSource;

  @override
  Future<Result<MathProblemEntity>> generateProblem({
    required MathOperationType operation,
    int? difficultyLevel,
  }) async {
    try {
      final problemModel = _localDataSource.generateProblem(
        operation: operation,
        difficultyLevel: difficultyLevel,
      );

      return Success(problemModel.toEntity());
    } catch (e) {
      return ResultFailure(
        DataFailure('問題生成に失敗しました: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<MathProblemEntity>>> generateProblems({
    required MathOperationType operation,
    required int count,
    int? difficultyLevel,
  }) async {
    try {
      final problemModels = _localDataSource.generateProblems(
        operation: operation,
        count: count,
        difficultyLevel: difficultyLevel,
      );

      final entities = problemModels.map((model) => model.toEntity()).toList();

      return Success(entities);
    } catch (e) {
      return ResultFailure(
        DataFailure('複数問題生成に失敗しました: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getProblemSettings() async {
    try {
      final settings = _localDataSource.getProblemSettings();
      return Success(settings);
    } catch (e) {
      return ResultFailure(
        DataFailure('問題設定の取得に失敗しました: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getProblemStatistics() async {
    try {
      final statistics = _localDataSource.getProblemStatistics();
      return Success(statistics);
    } catch (e) {
      return ResultFailure(
        DataFailure('問題統計の取得に失敗しました: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getDifficultyRange() async {
    try {
      final range = {
        'min': 1,
        'max': 5,
      };
      return Success(range);
    } catch (e) {
      return ResultFailure(
        DataFailure('難易度範囲の取得に失敗しました: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<MathOperationType, int>>>
      getMaxProblemsPerOperation() async {
    try {
      const maxProblems = {
        MathOperationType.multiplication: 81,
        MathOperationType.division: 81,
        MathOperationType.addition: 2000,
        MathOperationType.subtraction: 2000,
      };
      return const Success(maxProblems);
    } catch (e) {
      return ResultFailure(
        const DataFailure('最大問題数の取得に失敗しました'),
      );
    }
  }
}
