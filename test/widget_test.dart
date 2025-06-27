import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:syonan_app/main.dart';
import 'package:syonan_app/services/math_service.dart';
import 'package:syonan_app/services/score_service.dart';

void main() {
  group('SyonanApp Widget Tests', () {
    testWidgets('App should build and display home screen', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const SyonanApp());

      // Verify that the home screen loads
      expect(find.text('算数れんしゅう'), findsOneWidget);
      expect(find.text('今日も楽しく勉強しましょう！'), findsOneWidget);

      // Verify practice buttons are present
      expect(find.text('掛け算'), findsOneWidget);
      expect(find.text('割り算'), findsOneWidget);

      // Verify features section is present
      expect(find.text('新機能'), findsOneWidget);
    });

    testWidgets('Practice buttons should be tappable', (
      WidgetTester tester,
    ) async {
      // Set up a larger test viewport
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(const SyonanApp());

      // Find and tap the multiplication practice button
      final multiplicationButton = find.text('掛け算');
      expect(multiplicationButton, findsOneWidget);

      await tester.tap(multiplicationButton);
      await tester.pumpAndSettle();

      // Should navigate to practice screen
      expect(find.text('掛け算の練習'), findsOneWidget);
    });

    testWidgets('Score history button should work', (
      WidgetTester tester,
    ) async {
      // Set up a larger test viewport
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(const SyonanApp());

      // Find and tap the score history button using scrolling to reach it
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          find.text('スコア履歴を見る'),
          300.0,
          scrollable: scrollable.first,
        );
      }

      final historyButton = find.text('スコア履歴を見る');
      expect(historyButton, findsOneWidget);

      await tester.tap(historyButton);
      await tester.pump(); // Initial pump
      await tester.pump(const Duration(milliseconds: 300)); // Animation pump

      // Should navigate to score history screen - look for the AppBar title
      expect(find.text('スコア履歴'), findsOneWidget);
    });

    testWidgets('Feature cards should be tappable and navigate to screens', (
      WidgetTester tester,
    ) async {
      // Set up a larger test viewport
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(const SyonanApp());

      // Find the features section by scrolling
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          find.text('新機能'),
          300.0,
          scrollable: scrollable.first,
        );
      }

      // Verify features section is visible
      expect(find.text('新機能'), findsOneWidget);

      // Find one of the feature cards (AI先生)
      final aiTutorCard = find.text('AI先生');
      if (aiTutorCard.evaluate().isNotEmpty) {
        await tester.tap(aiTutorCard);
        await tester.pumpAndSettle();

        // Should navigate to AI Tutor screen - look for the AppBar title
        expect(find.text('🤖 AI先生'), findsOneWidget);

        // Go back to home screen
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('App should provide required services', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SyonanApp());

      // Build the app to create the widget tree
      await tester.pump();

      // Get the providers from the widget tree
      final element = tester.element(find.byType(MaterialApp));
      final mathService = Provider.of<MathService>(element, listen: false);
      final scoreService = Provider.of<ScoreService>(element, listen: false);

      // Verify services are provided
      expect(mathService, isA<MathService>());
      expect(scoreService, isA<ScoreService>());
    });
  });
}
