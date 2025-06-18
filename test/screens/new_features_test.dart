import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:syonan_app/screens/ai_tutor_screen.dart';
import 'package:syonan_app/screens/multiplayer_battle_screen.dart';
import 'package:syonan_app/screens/parent_dashboard_screen.dart';
import 'package:syonan_app/screens/story_mode_screen.dart';
import 'package:syonan_app/services/math_service.dart';
import 'package:syonan_app/services/score_service.dart';
import 'package:syonan_app/services/points_service.dart';

void main() {
  group('New Feature Screens Tests', () {
    Widget createTestApp(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScoreService()),
          ChangeNotifierProvider(create: (_) => PointsService()),
          Provider(create: (_) => MathService()),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('AI Tutor screen should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const AiTutorScreen()));
      
      // Verify the screen builds and shows the main elements
      expect(find.text('🤖 AI先生'), findsOneWidget);
      expect(find.text('こんにちは！AI先生です'), findsOneWidget);
      expect(find.text('学習状況分析'), findsOneWidget);
      expect(find.text('AI先生からのアドバイス'), findsOneWidget);
    });

    testWidgets('Multiplayer Battle screen should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const MultiplayerBattleScreen()));
      
      // Verify the screen builds and shows the main elements
      expect(find.text('⚔️ みんなでバトル'), findsOneWidget);
      expect(find.text('あなた'), findsOneWidget);
      expect(find.text('VS'), findsOneWidget);
    });

    testWidgets('Story Mode screen should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const StoryModeScreen()));
      
      // Verify the screen builds and shows the main elements
      expect(find.text('📚 ストーリーモード'), findsOneWidget);
      expect(find.text('算数王国の冒険'), findsOneWidget);
      expect(find.text('すべてのチャプター'), findsOneWidget);
    });

    testWidgets('Parent Dashboard screen should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ParentDashboardScreen()));
      
      // Verify the screen builds and shows the main elements
      expect(find.text('📊 保護者ダッシュボード'), findsOneWidget);
      expect(find.text('概要'), findsOneWidget);
      expect(find.text('成績'), findsOneWidget);
      expect(find.text('進捗'), findsOneWidget);
      expect(find.text('設定'), findsOneWidget);
    });

    testWidgets('AI Tutor practice recommendation should work', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const AiTutorScreen()));
      
      // Find and tap the practice button
      final practiceButton = find.textContaining('の練習を始める');
      if (practiceButton.evaluate().isNotEmpty) {
        await tester.tap(practiceButton);
        await tester.pumpAndSettle();
        
        // Should navigate to practice screen
        expect(find.byType(AiTutorScreen), findsNothing);
      }
    });

    testWidgets('Story Mode chapter should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const StoryModeScreen()));
      
      // Find and tap a stage start button
      final stageButton = find.textContaining('を開始');
      if (stageButton.evaluate().isNotEmpty) {
        await tester.tap(stageButton);
        await tester.pumpAndSettle();
        
        // Should show battle screen elements
        expect(find.textContaining('問題'), findsOneWidget);
      }
    });

    testWidgets('Parent Dashboard tabs should be functional', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ParentDashboardScreen()));
      
      // Test tab navigation
      final performanceTab = find.text('成績');
      await tester.tap(performanceTab);
      await tester.pumpAndSettle();
      
      expect(find.text('成績概要'), findsOneWidget);
      
      // Test progress tab
      final progressTab = find.text('進捗');
      await tester.tap(progressTab);
      await tester.pumpAndSettle();
      
      expect(find.text('学習目標'), findsOneWidget);
    });
  });
}