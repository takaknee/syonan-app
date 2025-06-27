import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/math_problem.dart';
import 'package:syonan_app/services/math_service.dart';

void main() {
  group('MathService Difficulty Tests', () {
    late MathService mathService;

    setUp(() {
      mathService = MathService();
    });

    test('should generate problems with difficulty levels', () {
      for (int difficulty = 1; difficulty <= 5; difficulty++) {
        final problems = mathService.generateProblemsWithDifficulty(
          MathOperationType.multiplication,
          5,
          difficulty,
        );

        expect(problems.length, 5);

        for (final problem in problems) {
          expect(problem.operation, MathOperationType.multiplication);
          expect(problem.correctAnswer, greaterThan(0));
          expect(problem.correctAnswer, problem.firstNumber * problem.secondNumber);
        }
      }
    });

    test('should generate expert level problems (difficulty 5)', () {
      final problems = mathService.generateProblemsWithDifficulty(
        MathOperationType.multiplication,
        3,
        5, // Expert level
      );

      expect(problems.length, 3);

      for (final problem in problems) {
        expect(problem.operation, MathOperationType.multiplication);
        expect(problem.correctAnswer, greaterThan(0));
        // Expert level should have larger numbers
        expect(problem.firstNumber >= 10 || problem.secondNumber >= 10, true,
            reason: 'Expert level should include larger numbers');
      }
    });

    test('should generate different difficulty levels', () {
      final easyProblems = mathService.generateProblemsWithDifficulty(
        MathOperationType.addition,
        5,
        1, // Easy level
      );

      final expertProblems = mathService.generateProblemsWithDifficulty(
        MathOperationType.addition,
        5,
        5, // Expert level
      );

      expect(easyProblems.length, 5);
      expect(expertProblems.length, 5);

      // Easy problems should generally have smaller numbers
      final easyMaxNumber = easyProblems
          .map((p) => [p.firstNumber, p.secondNumber].reduce((a, b) => a > b ? a : b))
          .reduce((a, b) => a > b ? a : b);

      // Expert problems should generally have larger numbers
      final expertMaxNumber = expertProblems
          .map((p) => [p.firstNumber, p.secondNumber].reduce((a, b) => a > b ? a : b))
          .reduce((a, b) => a > b ? a : b);

      expect(expertMaxNumber >= easyMaxNumber, true,
          reason: 'Expert problems should have larger numbers than easy problems');
    });
  });
}
