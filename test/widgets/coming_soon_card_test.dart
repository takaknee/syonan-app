import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/coming_soon_feature.dart';
import 'package:syonan_app/widgets/coming_soon_card.dart';

void main() {
  group('ComingSoonCard Widget Tests', () {
    const testFeature = ComingSoonFeature(
      id: 'test_feature',
      name: 'テスト機能',
      description: 'テスト用の機能です',
      emoji: '🧪',
      color: 0xFF4A90E2,
      expectedRelease: '2024年夏',
    );

    testWidgets('should display feature information correctly', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComingSoonCard(
              feature: testFeature,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Check if the feature name is displayed
      expect(find.text('テスト機能'), findsOneWidget);

      // Check if the description is displayed
      expect(find.text('テスト用の機能です'), findsOneWidget);

      // Test tap functionality
      await tester.tap(find.byType(ComingSoonCard));
      await tester.pump();

      expect(wasTapped, isTrue);

      // Check if the emoji is displayed
      expect(find.text('🧪'), findsOneWidget);

      // Check if "近日公開" text is displayed
      expect(find.text('近日公開'), findsOneWidget);

      // Check if expected release is displayed
      expect(find.text('予定: 2024年夏'), findsOneWidget);

      // Check if schedule icon is displayed
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should handle tap events', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComingSoonCard(
              feature: testFeature,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(ComingSoonCard));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('should not display expected release when null', (tester) async {
      const featureWithoutRelease = ComingSoonFeature(
        id: 'test_feature',
        name: 'テスト機能',
        description: 'テスト用の機能です',
        emoji: '🧪',
        color: 0xFF4A90E2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComingSoonCard(
              feature: featureWithoutRelease,
              onTap: () {},
            ),
          ),
        ),
      );

      // Check that expected release is not displayed
      expect(find.textContaining('予定:'), findsNothing);
    });

    testWidgets('should have proper styling and layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComingSoonCard(
              feature: testFeature,
              onTap: () {},
            ),
          ),
        ),
      );

      // Check if Card widget is present
      expect(find.byType(Card), findsOneWidget);

      // Check if InkWell is present for tap effects
      expect(find.byType(InkWell), findsOneWidget);

      // Check if proper containers are present for styling
      expect(find.byType(Container), findsAtLeastNWidgets(2));
    });
  });
}
