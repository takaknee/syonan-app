import 'dart:math';
import '../models/math_problem.dart';

/// 算数問題生成サービス
/// 小学三年生〜四年生向けの掛け算・割り算・足し算・引き算問題を生成する
class MathService {
  final Random _random = Random();

  /// 掛け算問題を生成
  /// 小学三年生レベル（1〜9の九九）
  MathProblem generateMultiplicationProblem() {
    // 九九の範囲内で問題を生成
    final firstNumber = _random.nextInt(9) + 1; // 1 - 9
    final secondNumber = _random.nextInt(9) + 1; // 1 - 9
    final answer = firstNumber * secondNumber;

    return MathProblem(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: MathOperationType.multiplication,
      correctAnswer: answer,
    );
  }

  /// 割り算問題を生成
  /// 割り切れる問題のみ生成（小学三年生レベル）
  MathProblem generateDivisionProblem() {
    // まず掛け算を作ってから逆算で割り算を作る（割り切れることを保証）
    final divisor = _random.nextInt(9) + 1; // 1 - 9（割る数）
    final quotient = _random.nextInt(9) + 1; // 1 - 9（商）
    final dividend = divisor * quotient; // 割られる数

    return MathProblem(
      firstNumber: dividend,
      secondNumber: divisor,
      operation: MathOperationType.division,
      correctAnswer: quotient,
    );
  }

  /// 足し算問題を生成
  /// 小学三年生レベル（1〜99の範囲、答えが100以下）
  MathProblem generateAdditionProblem() {
    // 答えが100以下になるように調整
    final firstNumber = _random.nextInt(50) + 1; // 1 - 50
    final maxSecond = min(99 - firstNumber, 99); // 答えが100以下になるように
    final secondNumber = _random.nextInt(maxSecond) + 1;
    final answer = firstNumber + secondNumber;

    return MathProblem(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: MathOperationType.addition,
      correctAnswer: answer,
    );
  }

  /// 引き算問題を生成
  /// 小学三年生レベル（答えが正の数になるように調整）
  MathProblem generateSubtractionProblem() {
    // 引く数より引かれる数が大きくなるように調整
    final secondNumber = _random.nextInt(50) + 1; // 1 - 50（引く数）
    final firstNumber = secondNumber + _random.nextInt(50) + 1; // 51 - 100の範囲
    final answer = firstNumber - secondNumber;

    return MathProblem(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: MathOperationType.subtraction,
      correctAnswer: answer,
    );
  }

  /// 指定された操作タイプの問題を生成
  MathProblem generateProblem(MathOperationType operation) {
    switch (operation) {
      case MathOperationType.multiplication:
        return generateMultiplicationProblem();
      case MathOperationType.division:
        return generateDivisionProblem();
      case MathOperationType.addition:
        return generateAdditionProblem();
      case MathOperationType.subtraction:
        return generateSubtractionProblem();
    }
  }

  /// 複数の問題を生成
  List<MathProblem> generateProblems(
    MathOperationType operation,
    int count,
  ) {
    final problems = <MathProblem>[];
    final usedProblems = <String>{};

    // 同じ問題が重複しないようにする
    while (problems.length < count &&
        usedProblems.length < _getMaxUniqueProblems(operation)) {
      final problem = generateProblem(operation);
      final problemKey = '${problem.firstNumber}_${problem.secondNumber}'
          '_${problem.operation.name}';

      if (!usedProblems.contains(problemKey)) {
        problems.add(problem);
        usedProblems.add(problemKey);
      }
    }

    return problems;
  }

  /// 操作タイプごとの最大ユニーク問題数を取得
  int _getMaxUniqueProblems(MathOperationType operation) {
    switch (operation) {
      case MathOperationType.multiplication:
        return 81; // 9 × 9 = 81通り
      case MathOperationType.division:
        return 81; // 理論上は掛け算と同じ数だけ作れる
      case MathOperationType.addition:
        return 2450; // 概算: 50 × 49（重複を除く組み合わせ）
      case MathOperationType.subtraction:
        return 2450; // 概算: 50 × 49（重複を除く組み合わせ）
    }
  }

  /// 問題の難易度を調整（将来の拡張用）
  /// [level] 1: 簡単（1 - 5の範囲）, 2: 普通（1 - 9の範囲）, 3: 難しい（1 - 12の範囲）
  MathProblem generateProblemWithDifficulty(
    MathOperationType operation,
    int level,
  ) {
    final maxNumber = switch (level) {
      1 => 5, // 簡単
      2 => 9, // 普通（デフォルト）
      3 => 12, // 難しい
      _ => 9, // デフォルト
    };

    switch (operation) {
      case MathOperationType.multiplication:
        final firstNumber = _random.nextInt(maxNumber) + 1;
        final secondNumber = _random.nextInt(maxNumber) + 1;
        return MathProblem(
          firstNumber: firstNumber,
          secondNumber: secondNumber,
          operation: MathOperationType.multiplication,
          correctAnswer: firstNumber * secondNumber,
        );

      case MathOperationType.division:
        final divisor = _random.nextInt(maxNumber) + 1;
        final quotient = _random.nextInt(maxNumber) + 1;
        final dividend = divisor * quotient;
        return MathProblem(
          firstNumber: dividend,
          secondNumber: divisor,
          operation: MathOperationType.division,
          correctAnswer: quotient,
        );

      case MathOperationType.addition:
        final maxRange = maxNumber * 10; // 難易度に応じて範囲を調整
        final firstNumber = _random.nextInt(maxRange) + 1;
        final maxSecond = min(99, maxRange - firstNumber);
        final secondNumber = _random.nextInt(maxSecond) + 1;
        return MathProblem(
          firstNumber: firstNumber,
          secondNumber: secondNumber,
          operation: MathOperationType.addition,
          correctAnswer: firstNumber + secondNumber,
        );

      case MathOperationType.subtraction:
        final maxRange = maxNumber * 10; // 難易度に応じて範囲を調整
        final secondNumber = _random.nextInt(maxRange) + 1;
        final firstNumber = secondNumber + _random.nextInt(maxRange) + 1;
        return MathProblem(
          firstNumber: firstNumber,
          secondNumber: secondNumber,
          operation: MathOperationType.subtraction,
          correctAnswer: firstNumber - secondNumber,
        );
    }
  }

  /// 桁数を指定して問題を生成
  /// [digitCount] 1: 1桁, 2: 2桁, 3: 3桁
  MathProblem generateProblemWithDigits(
    MathOperationType operation,
    int digitCount,
  ) {
    final minNumber = switch (digitCount) {
      1 => 1,
      2 => 10,
      3 => 100,
      _ => 1,
    };
    
    final maxNumber = switch (digitCount) {
      1 => 9,
      2 => 99,
      3 => 999,
      _ => 9,
    };

    switch (operation) {
      case MathOperationType.multiplication:
        final firstNumber = _random.nextInt(maxNumber - minNumber + 1) + minNumber;
        final secondNumber = _random.nextInt(9) + 1; // 掛ける数は1桁に制限
        return MathProblem(
          firstNumber: firstNumber,
          secondNumber: secondNumber,
          operation: MathOperationType.multiplication,
          correctAnswer: firstNumber * secondNumber,
        );

      case MathOperationType.division:
        final divisor = _random.nextInt(9) + 1; // 割る数は1桁に制限
        final quotient = _random.nextInt(maxNumber - minNumber + 1) + minNumber;
        final dividend = divisor * quotient;
        return MathProblem(
          firstNumber: dividend,
          secondNumber: divisor,
          operation: MathOperationType.division,
          correctAnswer: quotient,
        );

      case MathOperationType.addition:
        final firstNumber = _random.nextInt(maxNumber - minNumber + 1) + minNumber;
        final maxSecond = maxNumber - firstNumber;
        final minSecond = max(1, minNumber - firstNumber);
        final secondNumber = maxSecond > minSecond 
            ? _random.nextInt(maxSecond - minSecond + 1) + minSecond
            : minSecond;
        return MathProblem(
          firstNumber: firstNumber,
          secondNumber: secondNumber,
          operation: MathOperationType.addition,
          correctAnswer: firstNumber + secondNumber,
        );

      case MathOperationType.subtraction:
        final firstNumber = _random.nextInt(maxNumber - minNumber + 1) + minNumber;
        final maxSecond = firstNumber - 1; // 答えが正の数になるように
        final minSecond = max(1, minNumber);
        final secondNumber = maxSecond >= minSecond
            ? _random.nextInt(maxSecond - minSecond + 1) + minSecond
            : minSecond;
        return MathProblem(
          firstNumber: firstNumber,
          secondNumber: secondNumber,
          operation: MathOperationType.subtraction,
          correctAnswer: firstNumber - secondNumber,
        );
    }
  }

  /// 複合的な難易度設定で問題を生成
  /// [difficultyLevel] 1-5の難易度レベル
  /// [operationConstraints] 演算種別による制約
  MathProblem generateAdvancedProblem(
    MathOperationType operation,
    int difficultyLevel,
  ) {
    switch (difficultyLevel) {
      case 1: // 超簡単：1桁の基本問題
        return generateProblemWithDigits(operation, 1);
      case 2: // 簡単：1桁の発展問題
        return generateProblemWithDifficulty(operation, 1);
      case 3: // 普通：2桁を含む基本問題
        return _random.nextBool() 
            ? generateProblemWithDigits(operation, 2)
            : generateProblemWithDifficulty(operation, 2);
      case 4: // 難しい：2桁の発展問題
        return generateProblemWithDifficulty(operation, 3);
      case 5: // 超難しい：3桁を含む問題
        return generateProblemWithDigits(operation, 3);
      default:
        return generateProblemWithDifficulty(operation, 2);
    }
  }
}
