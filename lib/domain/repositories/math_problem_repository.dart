import '../entities/math_problem_entity.dart';
import '../../core/errors/failures.dart';

/// Either-likeな結果を表現するクラス
abstract class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure;

  T get data => (this as Success<T>).data;
  Failure get failure => (this as ResultFailure<T>).failure;

  T? get dataOrNull => isSuccess ? data : null;
  Failure? get failureOrNull => isFailure ? failure : null;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}

/// 算数問題リポジトリの抽象クラス
abstract class MathProblemRepository {
  /// 指定された操作タイプと難易度で問題を生成
  Future<Result<MathProblemEntity>> generateProblem({
    required MathOperationType operation,
    int? difficultyLevel,
  });

  /// 複数の問題を生成
  Future<Result<List<MathProblemEntity>>> generateProblems({
    required MathOperationType operation,
    required int count,
    int? difficultyLevel,
  });

  /// 問題の設定を取得
  Future<Result<Map<String, dynamic>>> getProblemSettings();

  /// 問題の統計情報を取得
  Future<Result<Map<String, dynamic>>> getProblemStatistics();

  /// 難易度レベルの範囲を取得
  Future<Result<Map<String, int>>> getDifficultyRange();

  /// 操作タイプごとの問題数制限を取得
  Future<Result<Map<MathOperationType, int>>> getMaxProblemsPerOperation();
}
