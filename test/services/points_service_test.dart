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

        final earnedPoints =
            await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(10) + excellentボーナス(15) +
        // パーフェクトボーナス(20) + 演算ボーナス(5) + 問題数ボーナス(0) +
        // 時間ボーナス(0) = 60
        expect(earnedPoints, 60);
        expect(pointsService.totalPoints, 60);
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

        final earnedPoints =
            await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(8) + goodボーナス(10) + 演算ボーナス(5) = 33
        expect(earnedPoints, 33);
        expect(pointsService.totalPoints, 33);
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

        final earnedPoints =
            await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(7) + fairボーナス(5) + 演算ボーナス(2) = 24
        expect(earnedPoints, 24);
        expect(pointsService.totalPoints, 24);
      });

      test('should calculate correct points for needs practice score',
          () async {
        final scoreRecord = ScoreRecord(
          id: 'test_4',
          date: DateTime.now(),
          operation: MathOperationType.subtraction,
          correctAnswers: 5,
          totalQuestions: 10,
          timeSpent: const Duration(minutes: 5),
        );

        final earnedPoints =
            await pointsService.addPointsFromScore(scoreRecord);

        // 基本ポイント(10) + 正答率ボーナス(5) + needsPracticeボーナス(0) + 演算ボーナス(3) = 18
        expect(earnedPoints, 18);
        expect(pointsService.totalPoints, 18);
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

      test('should calculate enhanced points with time bonus', () async {
        final scoreRecord = ScoreRecord(
          id: 'test_time_bonus',
          date: DateTime.now(),
          operation: MathOperationType.multiplication,
          correctAnswers: 10,
          totalQuestions: 10,
          timeSpent: const Duration(seconds: 80), // 8秒/問 = 時間ボーナス獲得
        );

        final earnedPoints =
            await pointsService.addPointsFromScore(scoreRecord);

        // 基本(10) + 正答率(10) + excellent(15) + パーフェクト(20) + 演算(5) + 時間(10) = 70
        expect(earnedPoints, 70);
      });

      test('should calculate enhanced points with volume bonus', () async {
        final scoreRecord = ScoreRecord(
          id: 'test_volume_bonus',
          date: DateTime.now(),
          operation: MathOperationType.addition,
          correctAnswers: 18,
          totalQuestions: 20, // 20問以上で問題数ボーナス獲得
          timeSpent: const Duration(minutes: 10),
        );

        final earnedPoints =
            await pointsService.addPointsFromScore(scoreRecord);

        // 基本(10) + 正答率(9) + good(10) + 演算(2) + 問題数(10) = 41
        expect(earnedPoints, 41);
      });

      test('should give different operation bonuses', () async {
        // たし算のテスト
        final additionScore = ScoreRecord(
          id: 'test_addition',
          date: DateTime.now(),
          operation: MathOperationType.addition,
          correctAnswers: 7,
          totalQuestions: 10,
          timeSpent: const Duration(minutes: 5),
        );

        final additionPoints =
            await pointsService.addPointsFromScore(additionScore);
        await pointsService.addPoints(-additionPoints); // リセット

        // ひき算のテスト
        final subtractionScore = ScoreRecord(
          id: 'test_subtraction',
          date: DateTime.now(),
          operation: MathOperationType.subtraction,
          correctAnswers: 7,
          totalQuestions: 10,
          timeSpent: const Duration(minutes: 5),
        );

        final subtractionPoints =
            await pointsService.addPointsFromScore(subtractionScore);

        // ひき算の方がたし算より1ポイント多い（3 vs 2）
        expect(subtractionPoints, additionPoints + 1);
      });
    });

    group('Achievement management', () {
      test('should unlock achievement when sufficient points', () async {
        await pointsService.addPoints(100);

        final success =
            await pointsService.unlockAchievement('fun_badge_rainbow');
        expect(success, true);
        expect(pointsService.totalPoints, 75); // 100 - 25 = 75
        expect(pointsService.hasAchievement('fun_badge_rainbow'), true);
      });

      test('should fail to unlock achievement when insufficient points',
          () async {
        await pointsService.addPoints(10);

        final success =
            await pointsService.unlockAchievement('fun_badge_rainbow');
        expect(success, false);
        expect(pointsService.totalPoints, 10);
        expect(pointsService.hasAchievement('fun_badge_rainbow'), false);
      });

      test('should not unlock same achievement twice', () async {
        await pointsService.addPoints(100);

        // First unlock
        final success1 =
            await pointsService.unlockAchievement('fun_badge_rainbow');
        expect(success1, true);
        expect(pointsService.totalPoints, 75);

        // Second attempt
        final success2 =
            await pointsService.unlockAchievement('fun_badge_rainbow');
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
