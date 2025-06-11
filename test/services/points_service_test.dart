import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syonan_app/models/achievement.dart';
import 'package:syonan_app/models/math_problem.dart';
import 'package:syonan_app/models/score_record.dart';
import 'package:syonan_app/services/points_service.dart';

void main() {
  group('PointsService', () {
    late PointsService pointsService;

    setUp(() async {
      // Shared Preferencesのモックを設定
      SharedPreferences.setMockInitialValues({});
      pointsService = PointsService();
      await pointsService.initialize();
    });

    group('Points calculation', () {
      test('should calculate correct points for excellent score', () async {
        final scoreRecord = ScoreRecord(
          id: 'test_1',
          date: DateTime.now(),
          operation: MathOperationType.multiplication,
          correctAnswers: 10,
          totalQuestions: 10,
          timeSpent: const Duration(minutes: 5),
        );

        final earnedPoints = await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(10) + excellentボーナス(15) + パーフェクトボーナス(20) = 55
        expect(earnedPoints, 55);
        expect(pointsService.totalPoints, 55);
      });

      test('should calculate correct points for good score', () async {
        final scoreRecord = ScoreRecord(
          id: 'test_2',
          date: DateTime.now(),
          operation: MathOperationType.division,
          correctAnswers: 8,
          totalQuestions: 10,
          timeSpent: const Duration(minutes: 5),
        );

        final earnedPoints = await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(8) + goodボーナス(10) = 28
        expect(earnedPoints, 28);
        expect(pointsService.totalPoints, 28);
      });

      test('should calculate correct points for fair score', () async {
        final scoreRecord = ScoreRecord(
          id: 'test_3',
          date: DateTime.now(),
          operation: MathOperationType.addition,
          correctAnswers: 7,
          totalQuestions: 10,
          timeSpent: const Duration(minutes: 5),
        );

        final earnedPoints = await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(7) + fairボーナス(5) = 22
        expect(earnedPoints, 22);
        expect(pointsService.totalPoints, 22);
      });

      test('should calculate correct points for needs practice score', () async {
        final scoreRecord = ScoreRecord(
          id: 'test_4',
          date: DateTime.now(),
          operation: MathOperationType.subtraction,
          correctAnswers: 5,
          totalQuestions: 10,
          timeSpent: const Duration(minutes: 5),
        );

        final earnedPoints = await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(5) + needsPracticeボーナス(0) = 15
        expect(earnedPoints, 15);
        expect(pointsService.totalPoints, 15);
      });
    });

    group('Points management', () {
      test('should add points correctly', () async {
        await pointsService.addPoints(100);
        expect(pointsService.totalPoints, 100);

        await pointsService.addPoints(50);
        expect(pointsService.totalPoints, 150);
      });

      test('should spend points correctly when sufficient', () async {
        await pointsService.addPoints(100);

        final success = await pointsService.spendPoints(30);
        expect(success, true);
        expect(pointsService.totalPoints, 70);
      });

      test('should fail to spend points when insufficient', () async {
        await pointsService.addPoints(20);

        final success = await pointsService.spendPoints(30);
        expect(success, false);
        expect(pointsService.totalPoints, 20);
      });
    });

    group('Achievement management', () {
      test('should unlock achievement when sufficient points', () async {
        await pointsService.addPoints(100);

        final success = await pointsService.unlockAchievement('fun_badge_rainbow');
        expect(success, true);
        expect(pointsService.totalPoints, 75); // 100 - 25 = 75
        expect(pointsService.hasAchievement('fun_badge_rainbow'), true);
      });

      test('should fail to unlock achievement when insufficient points', () async {
        await pointsService.addPoints(10);

        final success = await pointsService.unlockAchievement('fun_badge_rainbow');
        expect(success, false);
        expect(pointsService.totalPoints, 10);
        expect(pointsService.hasAchievement('fun_badge_rainbow'), false);
      });

      test('should not unlock same achievement twice', () async {
        await pointsService.addPoints(100);

        // First unlock
        final success1 = await pointsService.unlockAchievement('fun_badge_rainbow');
        expect(success1, true);
        expect(pointsService.totalPoints, 75);

        // Second attempt
        final success2 = await pointsService.unlockAchievement('fun_badge_rainbow');
        expect(success2, false);
        expect(pointsService.totalPoints, 75); // Points not spent again
      });

      test('should return available achievements correctly', () async {
        final availableAchievements = pointsService.getAvailableAchievements();
        expect(availableAchievements.length, AvailableAchievements.all.length);

        // Unlock one achievement
        await pointsService.addPoints(100);
        await pointsService.unlockAchievement('fun_badge_rainbow');

        final updatedAvailable = pointsService.getAvailableAchievements();
        expect(updatedAvailable.length, AvailableAchievements.all.length - 1);
        expect(
          updatedAvailable.any((a) => a.id == 'fun_badge_rainbow'),
          false,
        );
      });

      test('should return user achievement details correctly', () async {
        await pointsService.addPoints(100);
        await pointsService.unlockAchievement('fun_badge_rainbow');

        final userAchievements = pointsService.getUserAchievementDetails();
        expect(userAchievements.length, 1);
        expect(userAchievements.first.id, 'fun_badge_rainbow');
        expect(userAchievements.first.title, 'にじいろバッジ');
      });
    });

    group('Data persistence', () {
      test('should persist points across service restarts', () async {
        await pointsService.addPoints(200);
        expect(pointsService.totalPoints, 200);

        // Create new service instance
        final newPointsService = PointsService();
        await newPointsService.initialize();

        expect(newPointsService.totalPoints, 200);
      });

      test('should persist achievements across service restarts', () async {
        await pointsService.addPoints(100);
        await pointsService.unlockAchievement('fun_badge_rainbow');

        // Create new service instance
        final newPointsService = PointsService();
        await newPointsService.initialize();

        expect(newPointsService.hasAchievement('fun_badge_rainbow'), true);
        expect(newPointsService.getUserAchievementDetails().length, 1);
      });
    });

    group('Clear data', () {
      test('should clear all data correctly', () async {
        await pointsService.addPoints(100);
        await pointsService.unlockAchievement('fun_badge_rainbow');

        await pointsService.clearAllData();

        expect(pointsService.totalPoints, 0);
        expect(pointsService.userAchievements.isEmpty, true);
        expect(pointsService.hasAchievement('fun_badge_rainbow'), false);
      });
    });
  });
}