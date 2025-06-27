import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/city_building_game.dart';
import 'package:syonan_app/services/city_building_game_service.dart';

void main() {
  group('CityBuildingGameService', () {
    late CityBuildingGameService service;

    setUp(() {
      service = CityBuildingGameService();
    });

    group('Game Initialization', () {
      test('initializes game with correct starting values', () {
        final gameState = service.initializeGame();

        expect(gameState.gameStatus, GameStatus.playing);
        expect(gameState.currentTurn, 1);
        expect(gameState.citySize, 3);
        expect(gameState.totalBuildings, 0);
        expect(gameState.resources[ResourceType.population], 10);
        expect(gameState.resources[ResourceType.food], 20);
        expect(gameState.resources[ResourceType.materials], 15);
        expect(gameState.resources[ResourceType.energy], 10);
        expect(gameState.resources[ResourceType.money], 50);
        expect(gameState.availableEvents.length, greaterThan(0));
      });
    });

    group('Building Construction', () {
      late CityGameState gameState;

      setUp(() {
        gameState = service.initializeGame();
      });

      test('can build a house when resources are sufficient', () {
        final newGameState = service.buildBuilding(gameState, BuildingType.house);

        expect(newGameState.hasBuilding(BuildingType.house), true);
        expect(newGameState.totalBuildings, 1);
        expect(newGameState.resources[ResourceType.materials], lessThan(15));
        expect(newGameState.resources[ResourceType.money], lessThan(50));
      });

      test('cannot build when resources are insufficient', () {
        // Try to build an expensive building with insufficient resources
        final newGameState = service.buildBuilding(gameState, BuildingType.mansion);

        expect(newGameState.hasBuilding(BuildingType.mansion), false);
        expect(newGameState.totalBuildings, 0);
        expect(newGameState.resources[ResourceType.materials], 15); // unchanged
        expect(newGameState.resources[ResourceType.money], 50); // unchanged
      });

      test('cannot build more buildings than city size allows', () {
        var currentState = gameState;

        // Build buildings up to city size limit
        for (int i = 0; i < gameState.citySize; i++) {
          currentState = service.buildBuilding(currentState, BuildingType.house);
        }

        expect(currentState.totalBuildings, gameState.citySize);

        // Try to build one more - should fail
        final overLimitState = service.buildBuilding(currentState, BuildingType.farm);
        expect(overLimitState.totalBuildings, gameState.citySize); // unchanged
      });

      test('can upgrade existing buildings', () {
        // First build a house
        var newGameState = service.buildBuilding(gameState, BuildingType.house);
        expect(newGameState.hasBuilding(BuildingType.house), true);

        final originalHouse = newGameState.buildings[BuildingType.house]!;
        expect(originalHouse.level, 1);

        // Then upgrade it
        newGameState = service.buildBuilding(newGameState, BuildingType.house);
        final upgradedHouse = newGameState.buildings[BuildingType.house]!;
        expect(upgradedHouse.level, 2);
      });
    });

    group('Available Building Options', () {
      test('returns building options based on unlock requirements', () {
        final gameState = service.initializeGame();
        final options = service.getAvailableBuildingOptions(gameState);

        // Should include basic buildings that don't require population
        expect(options, contains(BuildingType.house));
        expect(options, contains(BuildingType.farm));

        // Should not include buildings that require more population
        expect(options, isNot(contains(BuildingType.mansion))); // requires 50 population
      });

      test('includes more options as population grows', () {
        var gameState = service.initializeGame();

        // Artificially increase population
        gameState = gameState.copyWith(
          resources: {
            ...gameState.resources,
            ResourceType.population: 25,
          },
        );

        final options = service.getAvailableBuildingOptions(gameState);
        expect(options, contains(BuildingType.powerPlant)); // requires 25 population
      });
    });

    group('Score Calculation', () {
      test('calculates score based on game state', () {
        var gameState = service.initializeGame();

        // Build some buildings to increase score
        gameState = service.buildBuilding(gameState, BuildingType.house);
        gameState = service.buildBuilding(gameState, BuildingType.farm);

        final score = service.calculateFinalScore(gameState);
        expect(score, greaterThan(0));
      });

      test('gives victory bonus for winning', () {
        var gameState = service.initializeGame();
        gameState = gameState.copyWith(gameStatus: GameStatus.victory);

        final score = service.calculateFinalScore(gameState);
        expect(score, greaterThanOrEqualTo(1000)); // Victory bonus
      });
    });

    group('Turn Processing', () {
      test('advances turn and processes resources', () {
        var gameState = service.initializeGame();

        // Build a farm to generate food
        gameState = service.buildBuilding(gameState, BuildingType.farm);
        final initialFood = gameState.resources[ResourceType.food]!;

        final turnResult = service.endTurn(gameState);
        final newGameState = turnResult.gameState;

        expect(newGameState.currentTurn, gameState.currentTurn + 1);
        // Food should increase due to farm production minus consumption
        expect(newGameState.resources[ResourceType.food], isNot(equals(initialFood)));
      });

      test('may trigger random events', () {
        final gameState = service.initializeGame();

        // Run multiple turns to potentially trigger an event
        var currentState = gameState;
        bool eventTriggered = false;

        for (int i = 0; i < 10; i++) {
          final turnResult = service.endTurn(currentState);
          currentState = turnResult.gameState;

          if (turnResult.triggeredEvent != null) {
            eventTriggered = true;
            break;
          }
        }

        // Note: This test might occasionally fail due to randomness
        // but it's useful to verify the event system works
        expect(eventTriggered, isTrue);
      });
    });

    group('Victory Conditions', () {
      test('detects victory when population reaches 100', () {
        var gameState = service.initializeGame();
        gameState = gameState.copyWith(
          resources: {
            ...gameState.resources,
            ResourceType.population: 100,
          },
        );

        final turnResult = service.endTurn(gameState);
        expect(turnResult.gameState.gameStatus, GameStatus.victory);
      });

      test('detects victory when building count reaches 10', () {
        var gameState = service.initializeGame();

        // Artificially set high building count
        final buildings = <BuildingType, Building>{};
        for (int i = 0; i < 10; i++) {
          final buildingType = BuildingType.values[i % BuildingType.values.length];
          buildings[buildingType] = const Building(
            type: BuildingType.house,
            name: 'Test Building',
            emoji: '🏠',
            level: 1,
            maxLevel: 3,
            buildCost: {},
            production: {},
            upkeep: {},
            populationProvided: 0,
            unlockRequirements: {},
          );
        }

        gameState = gameState.copyWith(buildings: buildings);

        final turnResult = service.endTurn(gameState);
        expect(turnResult.gameState.gameStatus, GameStatus.victory);
      });

      test('detects victory when money reaches 500', () {
        var gameState = service.initializeGame();
        gameState = gameState.copyWith(
          resources: {
            ...gameState.resources,
            ResourceType.money: 500,
          },
        );

        final turnResult = service.endTurn(gameState);
        expect(turnResult.gameState.gameStatus, GameStatus.victory);
      });
    });

    group('Game Status Checks', () {
      test('detects defeat when population reaches 0', () {
        var gameState = service.initializeGame();
        gameState = gameState.copyWith(
          resources: {
            ...gameState.resources,
            ResourceType.population: 0,
          },
        );

        final turnResult = service.endTurn(gameState);
        expect(turnResult.gameState.gameStatus, GameStatus.defeat);
      });

      test('detects time up when game time exceeds 10 minutes', () {
        var gameState = service.initializeGame();
        final pastTime = DateTime.now().subtract(const Duration(minutes: 11));
        gameState = gameState.copyWith(gameStartTime: pastTime);

        final turnResult = service.endTurn(gameState);
        expect(turnResult.gameState.gameStatus, GameStatus.timeUp);
      });
    });
  });
}
