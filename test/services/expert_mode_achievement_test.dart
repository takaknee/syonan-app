import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syonan_app/models/achievement.dart';
import 'package:syonan_app/models/math_problem.dart';
import 'package:syonan_app/models/score_record.dart';
import 'package:syonan_app/services/points_service.dart';

void main() {
  group('Expert Mode Achievement Tests', () {
    late PointsService pointsService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      pointsService = PointsService();
      return pointsService.initialize();
    });

    test('should be able to unlock expert mode achievement', () async {
      // Add enough points to unlock expert achievement
      await pointsService.addPoints(250);
      expect(pointsService.totalPoints, 250);

      // Try to unlock expert achievement
      final success = await pointsService.unlockAchievement('difficulty_badge_expert');

      expect(success, true);
      expect(pointsService.hasAchievement('difficulty_badge_expert'), true);
      expect(pointsService.totalPoints, 50); // 250 - 200 = 50
    });

    test('expert achievement should exist in available achievements', () {
      final expertAchievement = AvailableAchievements.findById('difficulty_badge_expert');

      expect(expertAchievement, isNotNull);
      expect(expertAchievement!.title, 'エキスパートマスター');
      expect(expertAchievement.description, 'エキスパートレベルをクリア！');
      expect(expertAchievement.emoji, '🌲');
      expect(expertAchievement.pointsCost, 200);
      expect(expertAchievement.category, AchievementCategory.difficulty);
    });

    test('should be able to earn points from expert level score', () async {
      // Create a high-scoring expert level score record
      final expertScore = ScoreRecord(
        id: 'expert_test',
        date: DateTime.now(),
        operation: MathOperationType.multiplication,
        correctAnswers: 10,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 2),
      );

      final pointsEarned = await pointsService.addPointsFromScore(expertScore);

      // Should earn significant points for perfect expert score
      expect(pointsEarned, greaterThan(50));
      expect(pointsService.totalPoints, pointsEarned);
    });

    test('should show expert achievement in available achievements when unlocked', () async {
      final availableBefore = pointsService.getAvailableAchievements();
      expect(availableBefore.any((a) => a.id == 'difficulty_badge_expert'), true);

      // Unlock the achievement
      await pointsService.addPoints(250);
      await pointsService.unlockAchievement('difficulty_badge_expert');

      final availableAfter = pointsService.getAvailableAchievements();
      expect(availableAfter.any((a) => a.id == 'difficulty_badge_expert'), false);

      final userAchievements = pointsService.getUserAchievementDetails();
      expect(userAchievements.any((a) => a.id == 'difficulty_badge_expert'), true);
    });
  });
}
