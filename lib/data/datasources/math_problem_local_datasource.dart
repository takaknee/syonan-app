import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/math_problem_entity.dart';
import '../models/math_problem_model.dart';

/// 算数問題のローカルデータソース
class MathProblemLocalDataSource {
  final SharedPreferences _prefs;
  final Random _random = Random();

  MathProblemLocalDataSource(this._prefs);

  /// 問題を生成する
  MathProblemModel generateProblem({
    required MathOperationType operation,
    int? difficultyLevel,
  }) {
    try {
      switch (operation) {
        case MathOperationType.multiplication:
          return _generateMultiplicationProblem(difficultyLevel);
        case MathOperationType.division:
          return _generateDivisionProblem(difficultyLevel);
        case MathOperationType.addition:
          return _generateAdditionProblem(difficultyLevel);
        case MathOperationType.subtraction:
          return _generateSubtractionProblem(difficultyLevel);
      }
    } catch (e) {
      throw DataException(
        message: '問題生成中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 複数の問題を生成する
  List<MathProblemModel> generateProblems({
    required MathOperationType operation,
    required int count,
    int? difficultyLevel,
  }) {
    try {
      final problems = <MathProblemModel>[];
      final usedProblems = <String>{};
      final maxUniqueProblems =
          _getMaxUniqueProblems(operation, difficultyLevel);
      final maxAttempts = maxUniqueProblems * 3; // 無限ループ防止
      int attempts = 0;

      while (problems.length < count &&
          problems.length < maxUniqueProblems &&
          attempts < maxAttempts) {
        final problem = generateProblem(
          operation: operation,
          difficultyLevel: difficultyLevel,
        );

        final problemKey =
            '${problem.firstNumber}_${problem.secondNumber}_${problem.operation.value}';

        if (!usedProblems.contains(problemKey)) {
          problems.add(problem);
          usedProblems.add(problemKey);
        }

        attempts++;
      }

      return problems;
    } catch (e) {
      throw DataException(
        message: '複数問題生成中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 問題設定を取得
  Map<String, dynamic> getProblemSettings() {
    try {
      return {
        'defaultProblemCount': AppConstants.defaultProblemCount,
        'maxProblemCount': AppConstants.maxProblemCount,
        'minDifficultyLevel': AppConstants.minDifficultyLevel,
        'maxDifficultyLevel': AppConstants.maxDifficultyLevel,
        'multiplicationRange': {
          'min': AppConstants.multiplicationMin,
          'max': AppConstants.multiplicationMax,
        },
        'generalRange': {
          'min': AppConstants.minNumber,
          'max': AppConstants.maxNumber,
        },
      };
    } catch (e) {
      throw DataException(
        message: '問題設定の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 問題統計を取得
  Map<String, dynamic> getProblemStatistics() {
    try {
      return {
        'totalProblemsGenerated':
            _prefs.getInt('total_problems_generated') ?? 0,
        'problemsByOperation': _getProblemsByOperation(),
        'lastGeneratedAt': _prefs.getString('last_problem_generated_at'),
      };
    } catch (e) {
      throw DataException(
        message: '問題統計の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 掛け算問題を生成
  MathProblemModel _generateMultiplicationProblem(int? difficultyLevel) {
    final level = difficultyLevel ?? 1;
    int firstNumber, secondNumber;

    switch (level) {
      case 1: // 初級：1-5の九九
        firstNumber = _random.nextInt(5) + 1;
        secondNumber = _random.nextInt(5) + 1;
        break;
      case 2: // 中級：1-7の九九
        firstNumber = _random.nextInt(7) + 1;
        secondNumber = _random.nextInt(7) + 1;
        break;
      case 3: // 上級：1-9の九九
        firstNumber = _random.nextInt(9) + 1;
        secondNumber = _random.nextInt(9) + 1;
        break;
      case 4: // 挑戦：1-12の範囲
        firstNumber = _random.nextInt(12) + 1;
        secondNumber = _random.nextInt(12) + 1;
        break;
      case 5: // エキスパート：1-15の範囲
        firstNumber = _random.nextInt(15) + 1;
        secondNumber = _random.nextInt(15) + 1;
        break;
      default:
        firstNumber = _random.nextInt(9) + 1;
        secondNumber = _random.nextInt(9) + 1;
    }

    return MathProblemModel(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: MathOperationType.multiplication,
      correctAnswer: firstNumber * secondNumber,
      difficultyLevel: difficultyLevel,
      createdAt: DateTime.now(),
    );
  }

  /// 割り算問題を生成
  MathProblemModel _generateDivisionProblem(int? difficultyLevel) {
    final level = difficultyLevel ?? 1;
    int divisor, quotient;

    switch (level) {
      case 1: // 初級
        divisor = _random.nextInt(5) + 1;
        quotient = _random.nextInt(5) + 1;
        break;
      case 2: // 中級
        divisor = _random.nextInt(7) + 1;
        quotient = _random.nextInt(7) + 1;
        break;
      case 3: // 上級
        divisor = _random.nextInt(9) + 1;
        quotient = _random.nextInt(9) + 1;
        break;
      case 4: // 挑戦
        divisor = _random.nextInt(12) + 1;
        quotient = _random.nextInt(12) + 1;
        break;
      case 5: // エキスパート
        divisor = _random.nextInt(15) + 1;
        quotient = _random.nextInt(15) + 1;
        break;
      default:
        divisor = _random.nextInt(9) + 1;
        quotient = _random.nextInt(9) + 1;
    }

    final dividend = divisor * quotient;

    return MathProblemModel(
      firstNumber: dividend,
      secondNumber: divisor,
      operation: MathOperationType.division,
      correctAnswer: quotient,
      difficultyLevel: difficultyLevel,
      createdAt: DateTime.now(),
    );
  }

  /// 足し算問題を生成
  MathProblemModel _generateAdditionProblem(int? difficultyLevel) {
    final level = difficultyLevel ?? 1;
    int firstNumber, secondNumber;

    switch (level) {
      case 1: // 初級：1-20
        firstNumber = _random.nextInt(20) + 1;
        secondNumber = _random.nextInt(20) + 1;
        break;
      case 2: // 中級：1-50
        firstNumber = _random.nextInt(50) + 1;
        secondNumber = _random.nextInt(50) + 1;
        break;
      case 3: // 上級：1-99
        firstNumber = _random.nextInt(99) + 1;
        secondNumber = _random.nextInt(99) + 1;
        break;
      case 4: // 挑戦：1-200
        firstNumber = _random.nextInt(200) + 1;
        secondNumber = _random.nextInt(200) + 1;
        break;
      case 5: // エキスパート：1-500
        firstNumber = _random.nextInt(500) + 1;
        secondNumber = _random.nextInt(500) + 1;
        break;
      default:
        firstNumber = _random.nextInt(50) + 1;
        secondNumber = _random.nextInt(50) + 1;
    }

    return MathProblemModel(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: MathOperationType.addition,
      correctAnswer: firstNumber + secondNumber,
      difficultyLevel: difficultyLevel,
      createdAt: DateTime.now(),
    );
  }

  /// 引き算問題を生成
  MathProblemModel _generateSubtractionProblem(int? difficultyLevel) {
    final level = difficultyLevel ?? 1;
    int firstNumber, secondNumber;

    switch (level) {
      case 1: // 初級
        secondNumber = _random.nextInt(20) + 1;
        firstNumber = secondNumber + _random.nextInt(20) + 1;
        break;
      case 2: // 中級
        secondNumber = _random.nextInt(50) + 1;
        firstNumber = secondNumber + _random.nextInt(50) + 1;
        break;
      case 3: // 上級
        secondNumber = _random.nextInt(99) + 1;
        firstNumber = secondNumber + _random.nextInt(99) + 1;
        break;
      case 4: // 挑戦
        secondNumber = _random.nextInt(200) + 1;
        firstNumber = secondNumber + _random.nextInt(200) + 1;
        break;
      case 5: // エキスパート
        secondNumber = _random.nextInt(500) + 1;
        firstNumber = secondNumber + _random.nextInt(500) + 1;
        break;
      default:
        secondNumber = _random.nextInt(50) + 1;
        firstNumber = secondNumber + _random.nextInt(50) + 1;
    }

    return MathProblemModel(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: MathOperationType.subtraction,
      correctAnswer: firstNumber - secondNumber,
      difficultyLevel: difficultyLevel,
      createdAt: DateTime.now(),
    );
  }

  /// 操作タイプごとの最大ユニーク問題数を取得
  int _getMaxUniqueProblems(MathOperationType operation, int? difficultyLevel) {
    final level = difficultyLevel ?? 1;

    switch (operation) {
      case MathOperationType.multiplication:
        switch (level) {
          case 1:
            return 25; // 5 × 5
          case 2:
            return 49; // 7 × 7
          case 3:
            return 81; // 9 × 9
          case 4:
            return 144; // 12 × 12
          case 5:
            return 225; // 15 × 15
          default:
            return 81;
        }
      case MathOperationType.division:
        switch (level) {
          case 1:
            return 25; // 5 × 5
          case 2:
            return 49; // 7 × 7
          case 3:
            return 81; // 9 × 9
          case 4:
            return 144; // 12 × 12
          case 5:
            return 225; // 15 × 15
          default:
            return 81;
        }
      case MathOperationType.addition:
        switch (level) {
          case 1:
            return 400; // 20 × 20
          case 2:
            return 2500; // 50 × 50
          case 3:
            return 9801; // 99 × 99
          case 4:
            return 40000; // 200 × 200
          case 5:
            return 250000; // 500 × 500
          default:
            return 2500;
        }
      case MathOperationType.subtraction:
        switch (level) {
          case 1:
            return 400; // 20 × 20
          case 2:
            return 2500; // 50 × 50
          case 3:
            return 9801; // 99 × 99
          case 4:
            return 40000; // 200 × 200
          case 5:
            return 250000; // 500 × 500
          default:
            return 2500;
        }
    }
  }

  /// 操作タイプ別の問題生成統計を取得
  Map<String, int> _getProblemsByOperation() {
    return {
      'multiplication': _prefs.getInt('problems_multiplication') ?? 0,
      'division': _prefs.getInt('problems_division') ?? 0,
      'addition': _prefs.getInt('problems_addition') ?? 0,
      'subtraction': _prefs.getInt('problems_subtraction') ?? 0,
    };
  }
}
