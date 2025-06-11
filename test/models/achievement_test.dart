import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/achievement.dart';

void main() {
  group('Achievement', () {
    test('should create achievement from JSON correctly', () {
      final json = {
        'id': 'test_badge',
        'title': 'テストバッジ',
        'description': 'テスト用のバッジです',
        'emoji': '🧪',
        'pointsCost': 50,
        'category': 'practice',
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.id, 'test_badge');
      expect(achievement.title, 'テストバッジ');
      expect(achievement.description, 'テスト用のバッジです');
      expect(achievement.emoji, '🧪');
      expect(achievement.pointsCost, 50);
      expect(achievement.category, AchievementCategory.practice);
    });

    test('should convert achievement to JSON correctly', () {
      const achievement = Achievement(
        id: 'test_badge',
        title: 'テストバッジ',
        description: 'テスト用のバッジです',
        emoji: '🧪',
        pointsCost: 50,
        category: AchievementCategory.practice,
      );

      final json = achievement.toJson();

      expect(json['id'], 'test_badge');
      expect(json['title'], 'テストバッジ');
      expect(json['description'], 'テスト用のバッジです');
      expect(json['emoji'], '🧪');
      expect(json['pointsCost'], 50);
      expect(json['category'], 'practice');
    });

    test('should implement equality correctly', () {
      const achievement1 = Achievement(
        id: 'test_1',
        title: 'Test',
        description: 'Test',
        emoji: '🧪',
        pointsCost: 50,
        category: AchievementCategory.practice,
      );

      const achievement2 = Achievement(
        id: 'test_1',
        title: 'Test',
        description: 'Test',
        emoji: '🧪',
        pointsCost: 50,
        category: AchievementCategory.practice,
      );

      const achievement3 = Achievement(
        id: 'test_2',
        title: 'Test',
        description: 'Test',
        emoji: '🧪',
        pointsCost: 50,
        category: AchievementCategory.practice,
      );

      expect(achievement1, achievement2);
      expect(achievement1, isNot(achievement3));
    });
  });

  group('UserAchievement', () {
    test('should create user achievement from JSON correctly', () {
      final json = {
        'achievementId': 'test_badge',
        'unlockedAt': '2024-01-15T10:30:00.000Z',
      };

      final userAchievement = UserAchievement.fromJson(json);

      expect(userAchievement.achievementId, 'test_badge');
      expect(userAchievement.unlockedAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should convert user achievement to JSON correctly', () {
      final userAchievement = UserAchievement(
        achievementId: 'test_badge',
        unlockedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
      );

      final json = userAchievement.toJson();

      expect(json['achievementId'], 'test_badge');
      expect(json['unlockedAt'], '2024-01-15T10:30:00.000Z');
    });

    test('should implement equality correctly', () {
      final userAchievement1 = UserAchievement(
        achievementId: 'test_1',
        unlockedAt: DateTime(2024),
      );

      final userAchievement2 = UserAchievement(
        achievementId: 'test_1',
        unlockedAt: DateTime(2024),
      );

      final userAchievement3 = UserAchievement(
        achievementId: 'test_2',
        unlockedAt: DateTime(2024),
      );

      expect(userAchievement1, userAchievement2);
      expect(userAchievement1, isNot(userAchievement3));
    });
  });

  group('AchievementCategory', () {
    test('should have correct display names', () {
      expect(AchievementCategory.practice.displayName, '練習');
      expect(AchievementCategory.streak.displayName, '連続');
      expect(AchievementCategory.accuracy.displayName, '正確性');
      expect(AchievementCategory.fun.displayName, '楽しさ');
    });
  });

  group('AvailableAchievements', () {
    test('should have all predefined achievements', () {
      expect(AvailableAchievements.all.isNotEmpty, true);
      expect(AvailableAchievements.all.length, greaterThan(5));
    });

    test('should find achievement by ID correctly', () {
      final achievement = AvailableAchievements.findById('fun_badge_rainbow');
      expect(achievement, isNotNull);
      expect(achievement!.title, 'にじいろバッジ');
      expect(achievement.category, AchievementCategory.fun);
      expect(achievement.pointsCost, 25);
    });

    test('should return null for non-existent ID', () {
      final achievement = AvailableAchievements.findById('non_existent');
      expect(achievement, isNull);
    });

    test('should filter achievements by category correctly', () {
      final practiceAchievements = AvailableAchievements.getByCategory(
        AchievementCategory.practice,
      );
      expect(practiceAchievements.isNotEmpty, true);
      expect(
        practiceAchievements.every(
          (a) => a.category == AchievementCategory.practice,
        ),
        true,
      );

      final funAchievements = AvailableAchievements.getByCategory(
        AchievementCategory.fun,
      );
      expect(funAchievements.isNotEmpty, true);
      expect(
        funAchievements.every(
          (a) => a.category == AchievementCategory.fun,
        ),
        true,
      );
    });

    test('should have achievements with valid data', () {
      for (final achievement in AvailableAchievements.all) {
        expect(achievement.id.isNotEmpty, true);
        expect(achievement.title.isNotEmpty, true);
        expect(achievement.description.isNotEmpty, true);
        expect(achievement.emoji.isNotEmpty, true);
        expect(achievement.pointsCost, greaterThan(0));
      }
    });

    test('should have unique achievement IDs', () {
      final ids = AvailableAchievements.all.map((a) => a.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });
  });
}