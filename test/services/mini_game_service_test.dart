import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/mini_game.dart';
import 'package:syonan_app/services/mini_game_service.dart';

void main() {
  group('MiniGameService', () {
    late MiniGameService miniGameService;

    setUp(() {
      miniGameService = MiniGameService();
    });

    test('should initialize with empty data', () {
      expect(miniGameService.scores, isEmpty);
      expect(miniGameService.playCount, isEmpty);
      expect(miniGameService.isLoading, false);
    });

    test('should record score correctly', () async {
      await miniGameService.recordScore('number_memory', 100, MiniGameDifficulty.easy);

      expect(miniGameService.scores.length, 1);
      expect(miniGameService.scores.first.gameId, 'number_memory');
      expect(miniGameService.scores.first.score, 100);
      expect(miniGameService.scores.first.difficulty, MiniGameDifficulty.easy);
      expect(miniGameService.getPlayCount('number_memory'), 1);
    });

    test('should get best score correctly', () async {
      await miniGameService.recordScore('number_memory', 50, MiniGameDifficulty.easy);
      await miniGameService.recordScore('number_memory', 100, MiniGameDifficulty.easy);
      await miniGameService.recordScore('number_memory', 75, MiniGameDifficulty.easy);

      expect(miniGameService.getBestScore('number_memory'), 100);
      expect(miniGameService.getPlayCount('number_memory'), 3);
    });

    test('should get average score correctly', () async {
      await miniGameService.recordScore('speed_math', 60, MiniGameDifficulty.normal);
      await miniGameService.recordScore('speed_math', 80, MiniGameDifficulty.normal);
      await miniGameService.recordScore('speed_math', 100, MiniGameDifficulty.normal);

      expect(miniGameService.getAverageScore('speed_math'), 80.0);
    });

    test('should return 0 for games with no scores', () {
      expect(miniGameService.getBestScore('nonexistent_game'), 0);
      expect(miniGameService.getAverageScore('nonexistent_game'), 0.0);
      expect(miniGameService.getPlayCount('nonexistent_game'), 0);
    });

    test('should get recent scores correctly', () async {
      // Record multiple scores
      for (int i = 0; i < 10; i++) {
        await miniGameService.recordScore('number_memory', i * 10, MiniGameDifficulty.easy);
        await Future.delayed(const Duration(milliseconds: 1)); // Ensure different timestamps
      }

      final recentScores = miniGameService.getRecentScores('number_memory');
      expect(recentScores.length, 5);
      // Most recent score should be first (90 points)
      expect(recentScores.first.score, 90);
      expect(recentScores.last.score, 50);
    });

    test('should calculate overall stats correctly', () async {
      await miniGameService.recordScore('number_memory', 100, MiniGameDifficulty.easy);
      await miniGameService.recordScore('speed_math', 200, MiniGameDifficulty.normal);

      final stats = miniGameService.getOverallStats();
      expect(stats['totalGamesPlayed'], 2);
      expect(stats['totalScore'], 300);
      expect(stats['averageScore'], 150.0);
      expect(stats['gamesUnlocked'], AvailableMiniGames.all.length);
    });

    test('should clear all data correctly', () async {
      await miniGameService.recordScore('number_memory', 100, MiniGameDifficulty.easy);
      expect(miniGameService.scores.length, 1);
      expect(miniGameService.getPlayCount('number_memory'), 1);

      await miniGameService.clearAllData();
      expect(miniGameService.scores, isEmpty);
      expect(miniGameService.playCount, isEmpty);
    });
  });

  group('MiniGame Model', () {
    test('should serialize and deserialize correctly', () {
      const miniGame = MiniGame(
        id: 'test_game',
        type: MiniGameType.numberMemory,
        name: 'Test Game',
        description: 'A test game',
        emoji: '🎮',
        pointsCost: 10,
        difficulty: MiniGameDifficulty.easy,
        color: 0xFF4CAF50,
      );

      final json = miniGame.toJson();
      final restored = MiniGame.fromJson(json);

      expect(restored.id, miniGame.id);
      expect(restored.type, miniGame.type);
      expect(restored.name, miniGame.name);
      expect(restored.description, miniGame.description);
      expect(restored.emoji, miniGame.emoji);
      expect(restored.pointsCost, miniGame.pointsCost);
      expect(restored.difficulty, miniGame.difficulty);
      expect(restored.color, miniGame.color);
    });

    test('should find games by ID correctly', () {
      final numberMemoryGame = AvailableMiniGames.findById('number_memory');
      expect(numberMemoryGame, isNotNull);
      expect(numberMemoryGame!.name, '数字おぼえゲーム');

      final speedMathGame = AvailableMiniGames.findById('speed_math');
      expect(speedMathGame, isNotNull);
      expect(speedMathGame!.name, 'スピード計算');

      final nonexistentGame = AvailableMiniGames.findById('nonexistent');
      expect(nonexistentGame, isNull);
    });
  });

  group('MiniGameScore Model', () {
    test('should serialize and deserialize correctly', () {
      final now = DateTime.now();
      final score = MiniGameScore(
        id: 'test_score',
        gameId: 'number_memory',
        score: 150,
        completedAt: now,
        difficulty: MiniGameDifficulty.normal,
      );

      final json = score.toJson();
      final restored = MiniGameScore.fromJson(json);

      expect(restored.id, score.id);
      expect(restored.gameId, score.gameId);
      expect(restored.score, score.score);
      expect(restored.completedAt, score.completedAt);
      expect(restored.difficulty, score.difficulty);
    });
  });
}
