import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/services/math_service.dart';
import 'package:syonan_app/models/math_problem.dart';

void main() {
  group('MathService', () {
    late MathService mathService;

    setUp(() {
      mathService = MathService();
    });

    group('generateMultiplicationProblem', () {
      test('should generate valid multiplication problems', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateMultiplicationProblem();

          expect(problem.operation, MathOperationType.multiplication);
          expect(problem.firstNumber, greaterThanOrEqualTo(1));
          expect(problem.firstNumber, lessThanOrEqualTo(9));
          expect(problem.secondNumber, greaterThanOrEqualTo(1));
          expect(problem.secondNumber, lessThanOrEqualTo(9));
          expect(problem.correctAnswer, problem.firstNumber * problem.secondNumber);
        }
      });
    });

    group('generateDivisionProblem', () {
      test('should generate valid division problems', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateDivisionProblem();

          expect(problem.operation, MathOperationType.division);
          expect(problem.secondNumber, greaterThanOrEqualTo(1));
          expect(problem.secondNumber, lessThanOrEqualTo(9));
          expect(problem.correctAnswer, greaterThanOrEqualTo(1));
          expect(problem.correctAnswer, lessThanOrEqualTo(9));

          // 割り切れることを確認
          expect(problem.firstNumber % problem.secondNumber, 0);
          expect(problem.firstNumber ~/ problem.secondNumber, problem.correctAnswer);
        }
      });
    });

    group('generateProblem', () {
      test('should generate multiplication problem when specified', () {
        final problem = mathService.generateProblem(MathOperationType.multiplication);
        expect(problem.operation, MathOperationType.multiplication);
      });

      test('should generate division problem when specified', () {
        final problem = mathService.generateProblem(MathOperationType.division);
        expect(problem.operation, MathOperationType.division);
      });
    });

    group('generateProblems', () {
      test('should generate requested number of problems', () {
        final problems = mathService.generateProblems(MathOperationType.multiplication, 5);

        expect(problems.length, 5);
        for (final problem in problems) {
          expect(problem.operation, MathOperationType.multiplication);
        }
      });

      test('should not generate duplicate problems', () {
        final problems = mathService.generateProblems(MathOperationType.multiplication, 10);

        final problemStrings = problems.map((p) =>
          '${p.firstNumber}_${p.secondNumber}_${p.operation.name}'
        ).toSet();

        expect(problemStrings.length, problems.length);
      });

      test('should handle requests for more problems than possible unique combinations', () {
        // 81通りの九九があるので、100個要求しても81個以下になる
        final problems = mathService.generateProblems(MathOperationType.multiplication, 100);

        expect(problems.length, lessThanOrEqualTo(81));

        final problemStrings = problems.map((p) =>
          '${p.firstNumber}_${p.secondNumber}_${p.operation.name}'
        ).toSet();

        expect(problemStrings.length, problems.length);
      });
    });

    group('generateProblemWithDifficulty', () {
      test('should generate easier problems for level 1', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateProblemWithDifficulty(
            MathOperationType.multiplication,
            1
          );

          expect(problem.firstNumber, greaterThanOrEqualTo(1));
          expect(problem.firstNumber, lessThanOrEqualTo(5));
          expect(problem.secondNumber, greaterThanOrEqualTo(1));
          expect(problem.secondNumber, lessThanOrEqualTo(5));
        }
      });

      test('should generate normal problems for level 2', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateProblemWithDifficulty(
            MathOperationType.multiplication,
            2
          );

          expect(problem.firstNumber, greaterThanOrEqualTo(1));
          expect(problem.firstNumber, lessThanOrEqualTo(9));
          expect(problem.secondNumber, greaterThanOrEqualTo(1));
          expect(problem.secondNumber, lessThanOrEqualTo(9));
        }
      });

      test('should generate harder problems for level 3', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateProblemWithDifficulty(
            MathOperationType.multiplication,
            3
          );

          expect(problem.firstNumber, greaterThanOrEqualTo(1));
          expect(problem.firstNumber, lessThanOrEqualTo(12));
          expect(problem.secondNumber, greaterThanOrEqualTo(1));
          expect(problem.secondNumber, lessThanOrEqualTo(12));
        }
      });

      test('should handle invalid difficulty levels gracefully', () {
        final problem = mathService.generateProblemWithDifficulty(
          MathOperationType.multiplication,
          999 // Invalid level
        );

        // Should default to level 2 (1-9 range)
        expect(problem.firstNumber, greaterThanOrEqualTo(1));
        expect(problem.firstNumber, lessThanOrEqualTo(9));
        expect(problem.secondNumber, greaterThanOrEqualTo(1));
        expect(problem.secondNumber, lessThanOrEqualTo(9));
      });
    });
  });
}
