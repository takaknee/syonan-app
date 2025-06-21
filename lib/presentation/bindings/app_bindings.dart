import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/math_problem_local_datasource.dart';
import '../../data/datasources/score_record_local_datasource.dart';
import '../../data/repositories/math_problem_repository_impl.dart';
import '../../data/repositories/score_repository_impl.dart';
import '../../domain/repositories/math_problem_repository.dart';
import '../../domain/repositories/score_repository.dart';
import '../../domain/usecases/generate_math_problems_usecase.dart';
import '../../domain/usecases/score_usecases.dart';
import '../../presentation/controllers/math_practice_controller.dart';

/// 依存性注入を管理するクラス
class AppBindings {
  static MathProblemRepository? _mathProblemRepository;
  static ScoreRepository? _scoreRepository;
  static GenerateMathProblemsUseCase? _generateMathProblemsUseCase;
  static SaveScoreUseCase? _saveScoreUseCase;
  static GetScoreStatisticsUseCase? _getScoreStatisticsUseCase;
  static MathPracticeController? _mathPracticeController;

  /// SharedPreferencesのインスタンス
  static SharedPreferences? _sharedPreferences;

  /// 初期化
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// SharedPreferencesを取得
  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw Exception('SharedPreferences not initialized. Call AppBindings.init() first.');
    }
    return _sharedPreferences!;
  }

  /// MathProblemRepositoryを取得
  static MathProblemRepository get mathProblemRepository {
    return _mathProblemRepository ??= MathProblemRepositoryImpl(
      MathProblemLocalDataSource(sharedPreferences),
    );
  }

  /// ScoreRepositoryを取得
  static ScoreRepository get scoreRepository {
    return _scoreRepository ??= ScoreRepositoryImpl(
      ScoreRecordLocalDataSource(sharedPreferences),
    );
  }

  /// GenerateMathProblemsUseCaseを取得
  static GenerateMathProblemsUseCase get generateMathProblemsUseCase {
    return _generateMathProblemsUseCase ??= GenerateMathProblemsUseCase(
      mathProblemRepository,
    );
  }

  /// SaveScoreUseCaseを取得
  static SaveScoreUseCase get saveScoreUseCase {
    return _saveScoreUseCase ??= SaveScoreUseCase(scoreRepository);
  }

  /// GetScoreStatisticsUseCaseを取得
  static GetScoreStatisticsUseCase get getScoreStatisticsUseCase {
    return _getScoreStatisticsUseCase ??= GetScoreStatisticsUseCase(scoreRepository);
  }

  /// MathPracticeControllerを取得
  static MathPracticeController get mathPracticeController {
    return _mathPracticeController ??= MathPracticeController(
      generateProblemsUseCase: generateMathProblemsUseCase,
    );
  }

  /// 依存関係をリセット（テスト用）
  static void reset() {
    _mathProblemRepository = null;
    _scoreRepository = null;
    _generateMathProblemsUseCase = null;
    _saveScoreUseCase = null;
    _getScoreStatisticsUseCase = null;
    _mathPracticeController = null;
    _sharedPreferences = null;
  }

  /// モックを設定（テスト用）
  static void setMockSharedPreferences(SharedPreferences mockPrefs) {
    _sharedPreferences = mockPrefs;
  }

  static void setMockMathProblemRepository(MathProblemRepository mockRepo) {
    _mathProblemRepository = mockRepo;
  }

  static void setMockScoreRepository(ScoreRepository mockRepo) {
    _scoreRepository = mockRepo;
  }
}
