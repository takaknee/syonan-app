import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/mini_game.dart';

void main() {
  group('MiniGame', () {
    test('can be created with required parameters', () {
      const game = MiniGame(
        id: 'test_game',
        type: MiniGameType.puzzle,
        name: 'Test Game',
        description: 'A test game',
        emoji: '🎮',
        pointsCost: 10,
        difficulty: MiniGameDifficulty.easy,
        color: 0xFF4CAF50,
      );

      expect(game.id, 'test_game');
      expect(game.type, MiniGameType.puzzle);
      expect(game.name, 'Test Game');
      expect(game.description, 'A test game');
      expect(game.emoji, '🎮');
      expect(game.pointsCost, 10);
      expect(game.difficulty, MiniGameDifficulty.easy);
      expect(game.color, 0xFF4CAF50);
    });

    test('can be serialized to JSON', () {
      const game = MiniGame(
        id: 'test_game',
        type: MiniGameType.puzzle,
        name: 'Test Game',
        description: 'A test game',
        emoji: '🎮',
        pointsCost: 10,
        difficulty: MiniGameDifficulty.easy,
        color: 0xFF4CAF50,
      );

      final json = game.toJson();

      expect(json['id'], 'test_game');
      expect(json['type'], MiniGameType.puzzle.index);
      expect(json['name'], 'Test Game');
      expect(json['description'], 'A test game');
      expect(json['emoji'], '🎮');
      expect(json['pointsCost'], 10);
      expect(json['difficulty'], MiniGameDifficulty.easy.index);
      expect(json['color'], 0xFF4CAF50);
    });

    test('can be deserialized from JSON', () {
      final json = {
        'id': 'test_game',
        'type': MiniGameType.puzzle.index,
        'name': 'Test Game',
        'description': 'A test game',
        'emoji': '🎮',
        'pointsCost': 10,
        'difficulty': MiniGameDifficulty.easy.index,
        'color': 0xFF4CAF50,
      };

      final game = MiniGame.fromJson(json);

      expect(game.id, 'test_game');
      expect(game.type, MiniGameType.puzzle);
      expect(game.name, 'Test Game');
      expect(game.description, 'A test game');
      expect(game.emoji, '🎮');
      expect(game.pointsCost, 10);
      expect(game.difficulty, MiniGameDifficulty.easy);
      expect(game.color, 0xFF4CAF50);
    });
  });

  group('MiniGameScore', () {
    test('can be created with required parameters', () {
      final completedAt = DateTime.now();
      final score = MiniGameScore(
        id: 'score_1',
        gameId: 'test_game',
        score: 100,
        completedAt: completedAt,
        difficulty: MiniGameDifficulty.easy,
      );

      expect(score.id, 'score_1');
      expect(score.gameId, 'test_game');
      expect(score.score, 100);
      expect(score.completedAt, completedAt);
      expect(score.difficulty, MiniGameDifficulty.easy);
    });

    test('can be serialized to JSON', () {
      final completedAt = DateTime.now();
      final score = MiniGameScore(
        id: 'score_1',
        gameId: 'test_game',
        score: 100,
        completedAt: completedAt,
        difficulty: MiniGameDifficulty.easy,
      );

      final json = score.toJson();

      expect(json['id'], 'score_1');
      expect(json['gameId'], 'test_game');
      expect(json['score'], 100);
      expect(json['completedAt'], completedAt.toIso8601String());
      expect(json['difficulty'], MiniGameDifficulty.easy.index);
    });

    test('can be deserialized from JSON', () {
      final completedAt = DateTime.now();
      final json = {
        'id': 'score_1',
        'gameId': 'test_game',
        'score': 100,
        'completedAt': completedAt.toIso8601String(),
        'difficulty': MiniGameDifficulty.easy.index,
      };

      final score = MiniGameScore.fromJson(json);

      expect(score.id, 'score_1');
      expect(score.gameId, 'test_game');
      expect(score.score, 100);
      expect(score.completedAt, completedAt);
      expect(score.difficulty, MiniGameDifficulty.easy);
    });
  });

  group('AvailableMiniGames', () {
    test('contains all expected games', () {
      expect(AvailableMiniGames.all.length, 8);

      final gameIds = AvailableMiniGames.all.map((g) => g.id).toList();
      expect(gameIds, contains('number_memory'));
      expect(gameIds, contains('speed_math'));
      expect(gameIds, contains('sliding_puzzle'));
      expect(gameIds, contains('rhythm_tap'));
      expect(gameIds, contains('dodge_game'));
      expect(gameIds, contains('number_puzzle'));
      expect(gameIds, contains('strategy_battle'));
      expect(gameIds, contains('city_builder'));
    });

    test('can find games by ID', () {
      final game = AvailableMiniGames.findById('sliding_puzzle');
      expect(game, isNotNull);
      expect(game!.id, 'sliding_puzzle');
      expect(game.name, 'スライドパズル');
      expect(game.emoji, '🧩');
    });

    test('returns null for non-existent game ID', () {
      final game = AvailableMiniGames.findById('non_existent');
      expect(game, isNull);
    });

    test('all games have required properties', () {
      for (final game in AvailableMiniGames.all) {
        expect(game.id, isNotEmpty);
        expect(game.name, isNotEmpty);
        expect(game.description, isNotEmpty);
        expect(game.emoji, isNotEmpty);
        expect(game.pointsCost, greaterThan(0));
      }
    });

    test('new entertainment games have correct properties', () {
      final slidingPuzzle = AvailableMiniGames.findById('sliding_puzzle');
      expect(slidingPuzzle!.type, MiniGameType.puzzle);
      expect(slidingPuzzle.pointsCost, 8);
      expect(slidingPuzzle.color, 0xFF9C27B0);

      final rhythmTap = AvailableMiniGames.findById('rhythm_tap');
      expect(rhythmTap!.type, MiniGameType.rhythm);
      expect(rhythmTap.pointsCost, 12);
      expect(rhythmTap.color, 0xFFE91E63);

      final dodgeGame = AvailableMiniGames.findById('dodge_game');
      expect(dodgeGame!.type, MiniGameType.action);
      expect(dodgeGame.pointsCost, 10);
      expect(dodgeGame.color, 0xFF2196F3);
    });

    test('new puzzle, strategy and simulation games have correct properties',
        () {
      final numberPuzzle = AvailableMiniGames.findById('number_puzzle');
      expect(numberPuzzle!.type, MiniGameType.puzzle);
      expect(numberPuzzle.pointsCost, 12);
      expect(numberPuzzle.color, 0xFF795548);

      final strategyBattle = AvailableMiniGames.findById('strategy_battle');
      expect(strategyBattle!.type, MiniGameType.strategy);
      expect(strategyBattle.pointsCost, 18);
      expect(strategyBattle.color, 0xFF8BC34A);

      final cityBuilder = AvailableMiniGames.findById('city_builder');
      expect(cityBuilder!.type, MiniGameType.simulation);
      expect(cityBuilder.pointsCost, 20);
      expect(cityBuilder.color, 0xFF607D8B);
    });
  });
}
