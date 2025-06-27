import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/math_problem.dart';
import 'package:syonan_app/widgets/problem_card.dart';

void main() {
  group('ProblemCard', () {
    testWidgets('should display multiplication problem correctly', (tester) async {
      const problem = MathProblem(
        firstNumber: 3,
        secondNumber: 4,
        operation: MathOperationType.multiplication,
        correctAnswer: 12,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProblemCard(problem: problem),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should display addition problem correctly', (tester) async {
      const problem = MathProblem(
        firstNumber: 5,
        secondNumber: 7,
        operation: MathOperationType.addition,
        correctAnswer: 12,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProblemCard(problem: problem),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('+'), findsAtLeastNWidgets(1)); // + symbol appears multiple times (icon + visual aid)
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should display subtraction problem correctly', (tester) async {
      const problem = MathProblem(
        firstNumber: 15,
        secondNumber: 8,
        operation: MathOperationType.subtraction,
        correctAnswer: 7,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProblemCard(problem: problem),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should show visual aid for small addition problems', (tester) async {
      const problem = MathProblem(
        firstNumber: 3,
        secondNumber: 2,
        operation: MathOperationType.addition,
        correctAnswer: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProblemCard(problem: problem),
          ),
        ),
      );

      // Should show visual aid for small numbers
      expect(find.text('🟦🟦🟦'), findsOneWidget);
      expect(find.text('🟦🟦'), findsOneWidget);
    });

    testWidgets('should not show visual aid for large numbers', (tester) async {
      const problem = MathProblem(
        firstNumber: 25,
        secondNumber: 15,
        operation: MathOperationType.addition,
        correctAnswer: 40,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProblemCard(problem: problem),
          ),
        ),
      );

      // Should not show visual aid for large numbers
      expect(find.text('🟦'), findsNothing);
    });
  });
}
