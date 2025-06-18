import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/coming_soon_feature.dart';

void main() {
  group('ComingSoonFeature', () {
    test('should create ComingSoonFeature with required fields', () {
      const feature = ComingSoonFeature(
        id: 'test_feature',
        name: 'テスト機能',
        description: 'テスト用の機能です',
        emoji: '🧪',
        color: 0xFF4A90E2,
      );

      expect(feature.id, 'test_feature');
      expect(feature.name, 'テスト機能');
      expect(feature.description, 'テスト用の機能です');
      expect(feature.emoji, '🧪');
      expect(feature.color, 0xFF4A90E2);
      expect(feature.expectedRelease, null);
    });

    test('should create ComingSoonFeature with optional expectedRelease', () {
      const feature = ComingSoonFeature(
        id: 'test_feature',
        name: 'テスト機能',
        description: 'テスト用の機能です',
        emoji: '🧪',
        color: 0xFF4A90E2,
        expectedRelease: '2024年夏',
      );

      expect(feature.expectedRelease, '2024年夏');
    });
  });

  group('ComingSoonFeatures', () {
    test('should have predefined coming soon features', () {
      expect(ComingSoonFeatures.all.length, greaterThan(0));
      expect(ComingSoonFeatures.all.length, 4);

      // Check that all required features are present
      final featureIds = ComingSoonFeatures.all.map((f) => f.id).toList();
      expect(featureIds, contains('ai_tutor'));
      expect(featureIds, contains('multiplayer_battle'));
      expect(featureIds, contains('story_mode'));
      expect(featureIds, contains('parent_dashboard'));
    });

    test('should find feature by id', () {
      final aiTutor = ComingSoonFeatures.findById('ai_tutor');
      expect(aiTutor, isNotNull);
      expect(aiTutor!.name, 'AI先生');
      expect(aiTutor.description, '個別指導でより効率的な学習を！');
      expect(aiTutor.emoji, '🤖');
    });

    test('should return null for non-existent feature id', () {
      final nonExistent = ComingSoonFeatures.findById('non_existent');
      expect(nonExistent, isNull);
    });

    test('should have valid data for all features', () {
      for (final feature in ComingSoonFeatures.all) {
        expect(feature.id, isNotEmpty);
        expect(feature.name, isNotEmpty);
        expect(feature.description, isNotEmpty);
        expect(feature.emoji, isNotEmpty);
        expect(feature.color, isNonZero);
      }
    });

    test('should have unique ids for all features', () {
      final ids = ComingSoonFeatures.all.map((f) => f.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });
  });
}
