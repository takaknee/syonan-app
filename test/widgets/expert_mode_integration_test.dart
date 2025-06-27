import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:syonan_app/models/math_problem.dart';
import 'package:syonan_app/screens/practice_screen.dart';
import 'package:syonan_app/services/math_service.dart';
import 'package:syonan_app/services/points_service.dart';
import 'package:syonan_app/services/score_service.dart';

void main() {
  group('Expert Mode Integration Tests', () {
    testWidgets('PracticeScreen should show expert mode indicator when difficulty level is 5', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MathService>(create: (_) => MathService()),
            ChangeNotifierProvider<ScoreService>(create: (_) => ScoreService()),
            ChangeNotifierProvider<PointsService>(create: (_) => PointsService()),
          ],
          child: const MaterialApp(
            home: PracticeScreen(
              operation: MathOperationType.multiplication,
              difficultyLevel: 5, // Expert mode
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check if expert mode indicator is shown
      expect(find.text('エキスパートモード'), findsOneWidget);
      expect(find.text('高難易度チャレンジ中'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);

      // Check if the title includes level information
      expect(find.textContaining('レベル5'), findsOneWidget);
    });

    testWidgets('PracticeScreen should not show expert mode indicator for normal difficu lty', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MathService>(create: (_) => MathService()),
            ChangeNotifierProvider<ScoreService>(create: (_) => ScoreService()),
            ChangeNotifierProvider<PointsService>(create: (_) => PointsService()),
          ],
          child: const MaterialApp(
            home: PracticeScreen(
              operation: MathOperationType.multiplication,
              // No difficulty level specified (normal mode)
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check that expert mode indicator is NOT shown
      expect(find.text('エキスパートモード'), findsNothing);
      expect(find.text('高難易度チャレンジ中'), findsNothing);

      // Check that level information is NOT in title
      expect(find.textContaining('レベル'), findsNothing);
    });

    testWidgets('PracticeScreen should show level indicator for medium difficulty', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MathService>(create: (_) => MathService()),
            ChangeNotifierProvider<ScoreService>(create: (_) => ScoreService()),
            ChangeNotifierProvider<PointsService>(create: (_) => PointsService()),
          ],
          child: const MaterialApp(
            home: PracticeScreen(
              operation: MathOperationType.addition,
              difficultyLevel: 3, // Medium level
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check if the title includes level information
      expect(find.textContaining('レベル3'), findsOneWidget);

      // Check that expert mode indicator is NOT shown (only for level 5)
      expect(find.text('エキスパートモード'), findsNothing);
    });
  });
}
