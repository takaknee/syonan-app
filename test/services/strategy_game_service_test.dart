import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/strategy_game.dart';
import 'package:syonan_app/services/strategy_game_service.dart';

void main() {
  group('StrategyGameService Tests', () {
    late StrategyGameService gameService;

    setUp(() {
      gameService = StrategyGameService();
    });

    test('should initialize game with correct starting state', () {
      final gameState = gameService.initializeGame();

      expect(gameState.playerGold, equals(StrategyGameService.startingGold));
      expect(gameState.playerTroops, equals(StrategyGameService.startingTroops));
      expect(gameState.currentTurn, equals(1));
      expect(gameState.gameStatus, equals(GameStatus.playing));
      expect(gameState.territories.length, equals(StrategyGameService.mapWidth * StrategyGameService.mapHeight));
      
      // プレイヤーは最低1つの領土を持つ
      expect(gameState.playerTerritoryCount, greaterThan(0));
      
      // 敵の首都が存在する
      final enemyCapital = gameState.territories.where((t) => t.isCapital).first;
      expect(enemyCapital.owner, equals(Owner.enemy));
    });

    test('should calculate final score correctly', () {
      const gameState = StrategyGameState(
        territories: [
          Territory(
            id: 'test1',
            name: 'Test Territory',
            position: Position(0, 0),
            owner: Owner.player,
            troops: 10,
            maxTroops: 20,
            resources: 15,
            isCapital: false,
          ),
        ],
        playerGold: 50,
        playerTroops: 30,
        currentTurn: 5,
        gameStatus: GameStatus.victory,
        selectedTerritoryId: null,
      );

      const duration = Duration(minutes: 8);
      final score = gameService.calculateFinalScore(gameState, duration);

      expect(score, greaterThan(0));
      // 勝利ボーナスが含まれていることを確認
      expect(score, greaterThan(1000));
    });

    test('should handle territory selection', () {
      final gameState = gameService.initializeGame();
      final territoryId = gameState.territories.first.id;
      
      final updatedState = gameState.copyWith(selectedTerritoryId: territoryId);
      
      expect(updatedState.selectedTerritoryId, equals(territoryId));
      expect(updatedState.selectedTerritory?.id, equals(territoryId));
    });

    test('should get attackable targets correctly', () {
      const gameState = StrategyGameState(
        territories: [
          Territory(
            id: 'player1',
            name: 'Player Territory',
            position: Position(0, 0),
            owner: Owner.player,
            troops: 10,
            maxTroops: 20,
            resources: 15,
            isCapital: false,
          ),
          Territory(
            id: 'enemy1',
            name: 'Enemy Territory',
            position: Position(1, 0), // Adjacent to player territory
            owner: Owner.enemy,
            troops: 5,
            maxTroops: 15,
            resources: 10,
            isCapital: false,
          ),
          Territory(
            id: 'enemy2',
            name: 'Far Enemy Territory',
            position: Position(3, 3), // Not adjacent
            owner: Owner.enemy,
            troops: 8,
            maxTroops: 15,
            resources: 12,
            isCapital: false,
          ),
        ],
        playerGold: 100,
        playerTroops: 50,
        currentTurn: 1,
        gameStatus: GameStatus.playing,
        selectedTerritoryId: null,
      );

      final attackableTargets = gameService.getAttackableTargets(gameState, 'player1');
      
      expect(attackableTargets.length, equals(1));
      expect(attackableTargets.first.id, equals('enemy1'));
    });

    test('should handle troop recruitment', () {
      final initialState = gameService.initializeGame();
      final playerTerritory = initialState.territories
          .firstWhere((t) => t.owner == Owner.player);
      
      final updatedState = gameService.recruitTroops(
        initialState,
        playerTerritory.id,
        2,
      );

      expect(updatedState.playerGold, 
          equals(initialState.playerGold - (2 * StrategyGameService.troopCost)));
      
      final updatedTerritory = updatedState.getTerritoryById(playerTerritory.id);
      expect(updatedTerritory?.troops, equals(playerTerritory.troops + 2));
    });
  });
}