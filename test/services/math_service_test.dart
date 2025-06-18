import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/math_problem.dart';
import 'package:syonan_app/services/math_service.dart';

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
          expect(
            problem.correctAnswer,
            problem.firstNumber * problem.secondNumber,
          );
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
          expect(
            problem.firstNumber ~/ problem.secondNumber,
            problem.correctAnswer,
          );
        }
      });
    });

    group('generateAdditionProblem', () {
      test('should generate valid addition problems', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateAdditionProblem();

          expect(problem.operation, MathOperationType.addition);
          expect(problem.firstNumber, greaterThanOrEqualTo(1));
          expect(problem.firstNumber, lessThanOrEqualTo(50));
          expect(problem.secondNumber, greaterThanOrEqualTo(1));
          expect(problem.correctAnswer, lessThanOrEqualTo(100));
          expect(
            problem.correctAnswer,
            problem.firstNumber + problem.secondNumber,
          );
        }
      });
    });

    group('generateSubtractionProblem', () {
      test('should generate valid subtraction problems', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateSubtractionProblem();

          expect(problem.operation, MathOperationType.subtraction);
          expect(problem.secondNumber, greaterThanOrEqualTo(1));
          expect(problem.secondNumber, lessThanOrEqualTo(50));
          expect(problem.firstNumber, greaterThan(problem.secondNumber));
          expect(problem.correctAnswer, greaterThan(0));
          expect(
            problem.correctAnswer,
            problem.firstNumber - problem.secondNumber,
          );
        }
      });
    });

    group('generateProblem', () {
      test('should generate multiplication problem when specified', () {
        final problem = mathService.generateProblem(
          MathOperationType.multiplication,
        );
        expect(problem.operation, MathOperationType.multiplication);
      });

      test('should generate division problem when specified', () {
        final problem = mathService.generateProblem(MathOperationType.division);
        expect(problem.operation, MathOperationType.division);
      });

      test('should generate addition problem when specified', () {
        final problem = mathService.generateProblem(MathOperationType.addition);
        expect(problem.operation, MathOperationType.addition);
      });

      test('should generate subtraction problem when specified', () {
        final problem =
            mathService.generateProblem(MathOperationType.subtraction);
        expect(problem.operation, MathOperationType.subtraction);
      });
    });

    group('generateProblems', () {
      test('should generate requested number of problems', () {
        final problems = mathService.generateProblems(
          MathOperationType.multiplication,
          5,
        );

        expect(problems.length, 5);
        for (final problem in problems) {
          expect(problem.operation, MathOperationType.multiplication);
        }
      });

      test('should not generate duplicate problems', () {
        final problems = mathService.generateProblems(
          MathOperationType.multiplication,
          10,
        );

        final problemStrings = problems
            .map(
                (p) => '${p.firstNumber}_${p.secondNumber}_${p.operation.name}')
            .toSet();

        expect(problemStrings.length, problems.length);
      });

      test(
        'should handle requests for more problems than possible unique '
        'combinations',
        () {
          // 81通りの九九があるので、100個要求しても81個以下になる
          final problems = mathService.generateProblems(
            MathOperationType.multiplication,
            100,
          );

          expect(problems.length, lessThanOrEqualTo(81));

          final problemStrings = problems
              .map((p) =>
                  '${p.firstNumber}_${p.secondNumber}_${p.operation.name}')
              .toSet();

          expect(problemStrings.length, problems.length);
        },
      );
    });

    group('generateProblemWithDifficulty', () {
      test('should generate easier problems for level 1', () {
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateProblemWithDifficulty(
            MathOperationType.multiplication,
            1,
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
            2,
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
            3,
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
          999, // Invalid level
        );

        // Should default to level 2(1 - 9 range)
        expect(problem.firstNumber, greaterThanOrEqualTo(1));
        expect(problem.firstNumber, lessThanOrEqualTo(9));
        expect(problem.secondNumber, greaterThanOrEqualTo(1));
        expect(problem.secondNumber, lessThanOrEqualTo(9));
      });

      test('should generate addition problems with difficulty levels', () {
        for (int level = 1; level <= 3; level++) {
          final problem = mathService.generateProblemWithDifficulty(
            MathOperationType.addition,
            level,
          );

          expect(problem.operation, MathOperationType.addition);
          expect(problem.correctAnswer, greaterThan(0));
          expect(
            problem.correctAnswer,
            problem.firstNumber + problem.secondNumber,
          );
        }
      });

      test('should generate subtraction problems with difficulty levels', () {
        for (int level = 1; level <= 3; level++) {
          final problem = mathService.generateProblemWithDifficulty(
            MathOperationType.subtraction,
            level,
          );

          expect(problem.operation, MathOperationType.subtraction);
          expect(problem.correctAnswer, greaterThan(0));
          expect(
            problem.correctAnswer,
            problem.firstNumber - problem.secondNumber,
          );
        }
      });
    });

    group('Enhanced difficulty generation', () {
      test('should generate problems with digit-based difficulty', () {
        // 1桁問題のテスト
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateProblemWithDigits(
            MathOperationType.addition,
            1,
          );
          expect(problem.firstNumber, greaterThanOrEqualTo(1));
          expect(problem.firstNumber, lessThanOrEqualTo(9));
          expect(problem.operation, MathOperationType.addition);
          expect(problem.correctAnswer, greaterThan(0));
        }

        // 2桁問題のテスト
        for (int i = 0; i < 10; i++) {
          final problem = mathService.generateProblemWithDigits(
            MathOperationType.addition,
            2,
          );
          expect(problem.firstNumber, greaterThanOrEqualTo(10));
          expect(problem.firstNumber, lessThanOrEqualTo(99));
          expect(problem.operation, MathOperationType.addition);
          expect(problem.correctAnswer, greaterThan(0));
        }
      });

      test('should generate advanced problems with different difficulty levels',
          () {
        for (int level = 1; level <= 5; level++) {
          final problem = mathService.generateAdvancedProblem(
            MathOperationType.multiplication,
            level,
          );
          expect(problem.operation, MathOperationType.multiplication);
          expect(problem.correctAnswer, greaterThan(0));
          expect(
            problem.correctAnswer,
            problem.firstNumber * problem.secondNumber,
          );
        }
      });

      test('should handle edge cases in digit generation', () {
        // 0桁（無効）は1桁として扱われる
        final problem = mathService.generateProblemWithDigits(
          MathOperationType.addition,
          0,
        );
        expect(problem.firstNumber, greaterThanOrEqualTo(1));
        expect(problem.firstNumber, lessThanOrEqualTo(9));
      });

      test('should generate valid division problems with digits', () {
        for (int digits = 1; digits <= 2; digits++) {
          final problem = mathService.generateProblemWithDigits(
            MathOperationType.division,
            digits,
          );
          expect(problem.operation, MathOperationType.division);
          expect(problem.correctAnswer, greaterThan(0));
          expect(
            problem.firstNumber,
            problem.secondNumber * problem.correctAnswer,
          );
        }
      });
    });
  });
}
