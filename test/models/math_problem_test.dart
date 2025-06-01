import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/math_problem.dart';

void main() {
  group('MathProblem', () {
    test('should create multiplication problem correctly', () {
      const problem = MathProblem(
        firstNumber: 3,
        secondNumber: 4,
        operation: MathOperationType.multiplication,
        correctAnswer: 12,
      );

      expect(problem.firstNumber, 3);
      expect(problem.secondNumber, 4);
      expect(problem.operation, MathOperationType.multiplication);
      expect(problem.correctAnswer, 12);
      expect(problem.questionText, '3 × 4 = ?');
    });

    test('should create division problem correctly', () {
      const problem = MathProblem(
        firstNumber: 12,
        secondNumber: 3,
        operation: MathOperationType.division,
        correctAnswer: 4,
      );

      expect(problem.firstNumber, 12);
      expect(problem.secondNumber, 3);
      expect(problem.operation, MathOperationType.division);
      expect(problem.correctAnswer, 4);
      expect(problem.questionText, '12 ÷ 3 = ?');
    });

    test('should validate correct answer', () {
      const problem = MathProblem(
        firstNumber: 5,
        secondNumber: 6,
        operation: MathOperationType.multiplication,
        correctAnswer: 30,
      );

      expect(problem.isCorrectAnswer(30), true);
      expect(problem.isCorrectAnswer(25), false);
      expect(problem.isCorrectAnswer(0), false);
    });

    test('should convert to and from JSON', () {
      const originalProblem = MathProblem(
        firstNumber: 7,
        secondNumber: 8,
        operation: MathOperationType.multiplication,
        correctAnswer: 56,
      );

      final json = originalProblem.toJson();
      final recreatedProblem = MathProblem.fromJson(json);

      expect(recreatedProblem.firstNumber, originalProblem.firstNumber);
      expect(recreatedProblem.secondNumber, originalProblem.secondNumber);
      expect(recreatedProblem.operation, originalProblem.operation);
      expect(recreatedProblem.correctAnswer, originalProblem.correctAnswer);
    });

    test('should implement equality correctly', () {
      const problem1 = MathProblem(
        firstNumber: 2,
        secondNumber: 3,
        operation: MathOperationType.multiplication,
        correctAnswer: 6,
      );

      const problem2 = MathProblem(
        firstNumber: 2,
        secondNumber: 3,
        operation: MathOperationType.multiplication,
        correctAnswer: 6,
      );

      const problem3 = MathProblem(
        firstNumber: 2,
        secondNumber: 4,
        operation: MathOperationType.multiplication,
        correctAnswer: 8,
      );

      expect(problem1, problem2);
      expect(problem1, isNot(problem3));
    });
  });

  group('MathOperationType', () {
    test('should have correct symbols and display names', () {
      expect(MathOperationType.multiplication.symbol, '×');
      expect(MathOperationType.multiplication.displayName, '掛け算');

      expect(MathOperationType.division.symbol, '÷');
      expect(MathOperationType.division.displayName, '割り算');
    });
  });
}