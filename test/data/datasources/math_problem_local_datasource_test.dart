import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syonan_app/core/constants/app_constants.dart';
import 'package:syonan_app/data/datasources/math_problem_local_datasource.dart';
import 'package:syonan_app/domain/entities/math_problem_entity.dart';

void main() {
  group('MathProblemLocalDataSource Tests', () {
    late MathProblemLocalDataSource dataSource;
    late SharedPreferences mockPrefs;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      dataSource = MathProblemLocalDataSource(mockPrefs);
    });

    group('generateProblem', () {
      test('should generate multiplication problem', () {
        // Act
        final problem = dataSource.generateProblem(
          operation: MathOperationType.multiplication,
          difficultyLevel: 1,
        );

        // Assert
        expect(problem.operation, MathOperationType.multiplication);
        expect(problem.firstNumber, inInclusiveRange(1, 5));
        expect(problem.secondNumber, inInclusiveRange(1, 5));
        expect(problem.correctAnswer, problem.firstNumber * problem.secondNumber);
        expect(problem.difficultyLevel, 1);
      });

      test('should generate division problem', () {
        // Act
        final problem = dataSource.generateProblem(
          operation: MathOperationType.division,
          difficultyLevel: 1,
        );

        // Assert
        expect(problem.operation, MathOperationType.division);
        expect(problem.correctAnswer, problem.firstNumber ~/ problem.secondNumber);
        expect(problem.difficultyLevel, 1);
      });

      test('should generate addition problem', () {
        // Act
        final problem = dataSource.generateProblem(
          operation: MathOperationType.addition,
          difficultyLevel: 1,
        );

        // Assert
        expect(problem.operation, MathOperationType.addition);
        expect(problem.correctAnswer, problem.firstNumber + problem.secondNumber);
        expect(problem.difficultyLevel, 1);
      });

      test('should generate subtraction problem', () {
        // Act
        final problem = dataSource.generateProblem(
          operation: MathOperationType.subtraction,
          difficultyLevel: 1,
        );

        // Assert
        expect(problem.operation, MathOperationType.subtraction);
        expect(problem.correctAnswer, problem.firstNumber - problem.secondNumber);
        expect(problem.correctAnswer, greaterThanOrEqualTo(0));
        expect(problem.difficultyLevel, 1);
      });
    });

    group('generateProblems', () {
      test('should generate multiple unique problems', () {
        // Act
        final problems = dataSource.generateProblems(
          operation: MathOperationType.multiplication,
          count: 5,
          difficultyLevel: 1,
        );

        // Assert
        expect(problems, hasLength(5));

        // Check uniqueness
        final problemKeys = problems.map((p) => '${p.firstNumber}_${p.secondNumber}_${p.operation.value}').toSet();
        expect(problemKeys, hasLength(5));
      });

      test('should handle large count requests gracefully', () {
        // Act - レベル1の掛け算は最大25個のユニークな問題しか生成できない
        final problems = dataSource.generateProblems(
          operation: MathOperationType.multiplication,
          count: 100, // 可能数より多くリクエスト
          difficultyLevel: 1,
        );

        // Assert - 最大25個まで生成される（5×5の組み合わせ）
        expect(problems.length, lessThanOrEqualTo(25));
        expect(problems.length, greaterThan(0));

        // すべてレベル1の問題であることを確認
        for (final problem in problems) {
          expect(problem.difficultyLevel, 1);
          expect(problem.firstNumber, inInclusiveRange(1, 5));
          expect(problem.secondNumber, inInclusiveRange(1, 5));
        }
      });

      test('should generate more problems for higher difficulty levels', () {
        // Act - レベル3の掛け算はより多くのユニークな問題を生成できる
        final problems = dataSource.generateProblems(
          operation: MathOperationType.multiplication,
          count: 50,
          difficultyLevel: 3,
        );

        // Assert - レベル3では最大81個（9×9）まで可能
        expect(problems.length, 50);

        // すべてレベル3の問題であることを確認
        for (final problem in problems) {
          expect(problem.difficultyLevel, 3);
          expect(problem.firstNumber, inInclusiveRange(1, 9));
          expect(problem.secondNumber, inInclusiveRange(1, 9));
        }
      });
    });

    group('difficulty levels', () {
      test('should respect difficulty levels for multiplication', () {
        for (int level = 1; level <= 5; level++) {
          // Act
          final problem = dataSource.generateProblem(
            operation: MathOperationType.multiplication,
            difficultyLevel: level,
          );

          // Assert
          expect(problem.difficultyLevel, level);

          // Check number ranges based on difficulty
          switch (level) {
            case 1:
              expect(problem.firstNumber, inInclusiveRange(1, 5));
              expect(problem.secondNumber, inInclusiveRange(1, 5));
              break;
            case 2:
              expect(problem.firstNumber, inInclusiveRange(1, 7));
              expect(problem.secondNumber, inInclusiveRange(1, 7));
              break;
            case 3:
              expect(problem.firstNumber, inInclusiveRange(1, 9));
              expect(problem.secondNumber, inInclusiveRange(1, 9));
              break;
            case 4:
              expect(problem.firstNumber, inInclusiveRange(1, 12));
              expect(problem.secondNumber, inInclusiveRange(1, 12));
              break;
            case 5:
              expect(problem.firstNumber, inInclusiveRange(1, 15));
              expect(problem.secondNumber, inInclusiveRange(1, 15));
              break;
          }
        }
      });
    });

    group('getProblemSettings', () {
      test('should return correct settings', () {
        // Act
        final settings = dataSource.getProblemSettings();

        // Assert
        expect(settings['defaultProblemCount'], AppConstants.defaultProblemCount);
        expect(settings['maxProblemCount'], AppConstants.maxProblemCount);
        expect(settings['minDifficultyLevel'], AppConstants.minDifficultyLevel);
        expect(settings['maxDifficultyLevel'], AppConstants.maxDifficultyLevel);
      });
    });

    group('getProblemStatistics', () {
      test('should return statistics', () {
        // Act
        final statistics = dataSource.getProblemStatistics();

        // Assert
        expect(statistics, containsPair('totalProblemsGenerated', isA<int>()));
        expect(statistics, containsPair('problemsByOperation', isA<Map<String, int>>()));
      });
    });
  });
}
