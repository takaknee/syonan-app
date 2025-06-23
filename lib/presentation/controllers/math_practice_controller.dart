import 'package:flutter/foundation.dart';

import '../../domain/entities/math_problem_entity.dart';
import '../../domain/usecases/generate_math_problems_usecase.dart';

/// 算数練習のコントローラー
class MathPracticeController extends ChangeNotifier {
  MathPracticeController({
    required GenerateMathProblemsUseCase generateProblemsUseCase,
  }) : _generateProblemsUseCase = generateProblemsUseCase;
  final GenerateMathProblemsUseCase _generateProblemsUseCase;

  // 状態管理
  List<MathProblemEntity> _problems = [];
  List<int?> _userAnswers = [];
  List<bool> _isCorrect = [];
  int _currentProblemIndex = 0;
  bool _isLoading = false;
  bool _isCompleted = false;
  String? _error;

  // ゲッター
  List<MathProblemEntity> get problems => _problems;
  List<int?> get userAnswers => _userAnswers;
  List<bool> get isCorrect => _isCorrect;
  int get currentProblemIndex => _currentProblemIndex;
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  bool get hasError => _error != null;
  String? get error => _error;

  MathProblemEntity? get currentProblem =>
      _problems.isNotEmpty && _currentProblemIndex < _problems.length
          ? _problems[_currentProblemIndex]
          : null;

  int get correctCount => _isCorrect.where((correct) => correct).length;
  double get accuracy =>
      _problems.isEmpty ? 0.0 : correctCount / _problems.length;
  int get totalProblems => _problems.length;
  bool get hasCurrentAnswer =>
      _currentProblemIndex < _userAnswers.length &&
      _userAnswers[_currentProblemIndex] != null;

  /// 練習セッションを開始
  Future<void> startPractice({
    required MathOperationType operation,
    int problemCount = 10,
    int? difficultyLevel,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _generateProblemsUseCase(
        operation: operation,
        count: problemCount,
        difficultyLevel: difficultyLevel,
      );

      if (result.isSuccess) {
        _problems = result.data;
        _userAnswers = List.filled(_problems.length, null);
        _isCorrect = List.filled(_problems.length, false);
        _currentProblemIndex = 0;
        _isCompleted = false;
        notifyListeners();
      } else {
        _setError(result.failure.message);
      }
    } catch (e) {
      _setError('練習の開始中にエラーが発生しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 答えを提出
  void submitAnswer(int answer) {
    if (_currentProblemIndex >= _problems.length) return;

    _userAnswers[_currentProblemIndex] = answer;
    _isCorrect[_currentProblemIndex] =
        _problems[_currentProblemIndex].isCorrectAnswer(answer);

    notifyListeners();
  }

  /// 次の問題に進む
  void nextProblem() {
    if (_currentProblemIndex < _problems.length - 1) {
      _currentProblemIndex++;
      notifyListeners();
    } else {
      _completePractice();
    }
  }

  /// 前の問題に戻る
  void previousProblem() {
    if (_currentProblemIndex > 0) {
      _currentProblemIndex--;
      notifyListeners();
    }
  }

  /// 特定の問題に移動
  void goToProblem(int index) {
    if (index >= 0 && index < _problems.length) {
      _currentProblemIndex = index;
      notifyListeners();
    }
  }

  /// 練習を完了
  void _completePractice() {
    _isCompleted = true;
    notifyListeners();
  }

  /// 練習をリセット
  void resetPractice() {
    _problems.clear();
    _userAnswers.clear();
    _isCorrect.clear();
    _currentProblemIndex = 0;
    _isCompleted = false;
    _clearError();
    notifyListeners();
  }

  /// 現在の答えを取得
  int? getCurrentAnswer() {
    if (_currentProblemIndex < _userAnswers.length) {
      return _userAnswers[_currentProblemIndex];
    }
    return null;
  }

  /// 現在の問題が正解かどうかを確認
  bool isCurrentAnswerCorrect() {
    if (_currentProblemIndex < _isCorrect.length) {
      return _isCorrect[_currentProblemIndex];
    }
    return false;
  }

  /// 進捗率を取得（0.0 - 1.0）
  double get progress {
    if (_problems.isEmpty) return 0.0;
    return (_currentProblemIndex + 1) / _problems.length;
  }

  /// エキスパートモードかどうか
  bool get isExpertMode {
    return _problems.isNotEmpty && _problems.first.isExpertMode;
  }

  // プライベートメソッド
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
