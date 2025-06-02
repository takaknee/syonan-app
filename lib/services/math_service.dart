import 'dart:math';
import '../models/math_problem.dart';

/// 算数問題生成サービス
/// 小学三年生向けの掛け算・割り算問題を生成する
class MathService {
  final Random _random = Random();

  /// 掛け算問題を生成
  /// 小学三年生レベル（1〜9の九九）
  MathProblem generateMultiplicationProblem() {
    // 九九の範囲内で問題を生成
    final firstNumber = _random.nextInt(9) + 1; // 1-9
    final secondNumber = _random.nextInt(9) + 1; // 1-9
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
    final divisor = _random.nextInt(9) + 1; // 1-9（割る数）
    final quotient = _random.nextInt(9) + 1; // 1-9（商）
    final dividend = divisor * quotient; // 割られる数

    return MathProblem(
      firstNumber: dividend,
      secondNumber: divisor,
      operation: MathOperationType.division,
      correctAnswer: quotient,
    );
  }

  /// 指定された操作タイプの問題を生成
  MathProblem generateProblem(MathOperationType operation) {
    switch (operation) {
      case MathOperationType.multiplication:
        return generateMultiplicationProblem();
      case MathOperationType.division:
        return generateDivisionProblem();
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
    }
  }

  /// 問題の難易度を調整（将来の拡張用）
  /// [level] 1: 簡単（1-5の範囲）, 2: 普通（1-9の範囲）, 3: 難しい（1-12の範囲）
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
    }
  }
}
