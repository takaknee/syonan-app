import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/city_building_game.dart';

void main() {
  group('CityBuildingGame Models', () {
    group('ResourceType', () {
      test('has all expected resource types', () {
        expect(ResourceType.values.length, 5);
        expect(ResourceType.values, contains(ResourceType.population));
        expect(ResourceType.values, contains(ResourceType.food));
        expect(ResourceType.values, contains(ResourceType.materials));
        expect(ResourceType.values, contains(ResourceType.energy));
        expect(ResourceType.values, contains(ResourceType.money));
      });
    });

    group('BuildingType', () {
      test('has all expected building types', () {
        expect(BuildingType.values.length, 12);
        expect(BuildingType.values, contains(BuildingType.house));
        expect(BuildingType.values, contains(BuildingType.apartment));
        expect(BuildingType.values, contains(BuildingType.farm));
        expect(BuildingType.values, contains(BuildingType.factory));
        expect(BuildingType.values, contains(BuildingType.powerPlant));
        expect(BuildingType.values, contains(BuildingType.shop));
      });
    });

    group('Building', () {
      test('can be created with required properties', () {
        const building = Building(
          type: BuildingType.house,
          name: 'House',
          emoji: '🏠',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 10, ResourceType.money: 20},
          production: {},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 4,
          unlockRequirements: {},
        );

        expect(building.type, BuildingType.house);
        expect(building.name, 'House');
        expect(building.emoji, '🏠');
        expect(building.level, 1);
        expect(building.maxLevel, 3);
        expect(building.populationProvided, 4);
      });

      test('can check if upgrade is possible', () {
        const building = Building(
          type: BuildingType.house,
          name: 'House',
          emoji: '🏠',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 10},
          production: {},
          upkeep: {},
          populationProvided: 4,
          unlockRequirements: {},
        );

        expect(building.canUpgrade(), true);

        final maxLevelBuilding = building.copyWith(level: 3);
        expect(maxLevelBuilding.canUpgrade(), false);
      });

      test('can be upgraded', () {
        const building = Building(
          type: BuildingType.house,
          name: 'House',
          emoji: '🏠',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 10},
          production: {ResourceType.money: 5},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 4,
          unlockRequirements: {},
        );

        final upgraded = building.upgraded();

        expect(upgraded.level, 2);
        expect(upgraded.production[ResourceType.money], greaterThan(5));
      });
    });

    group('RandomEvent', () {
      test('can be created with required properties', () {
        const event = RandomEvent(
          name: 'Test Event',
          description: 'A test event',
          emoji: '🎉',
          effects: {ResourceType.money: 10},
          isPositive: true,
          probability: 0.1,
        );

        expect(event.name, 'Test Event');
        expect(event.isPositive, true);
        expect(event.probability, 0.1);
        expect(event.effects[ResourceType.money], 10);
      });
    });

    group('CityGameState', () {
      late CityGameState gameState;

      setUp(() {
        gameState = CityGameState(
          resources: {
            ResourceType.population: 10,
            ResourceType.food: 20,
            ResourceType.materials: 15,
            ResourceType.energy: 10,
            ResourceType.money: 50,
          },
          buildings: {},
          units: {},
          currentTurn: 1,
          gameStatus: GameStatus.playing,
          citySize: 3,
          selectedBuildingType: null,
          availableEvents: [],
          gameStartTime: DateTime.now(),
        );
      });

      test('can be created with initial values', () {
        expect(gameState.resources[ResourceType.population], 10);
        expect(gameState.totalBuildings, 0);
        expect(gameState.gameStatus, GameStatus.playing);
        expect(gameState.citySize, 3);
      });

      test('calculates total population correctly', () {
        expect(gameState.totalPopulation, 10);

        const house = Building(
          type: BuildingType.house,
          name: 'House',
          emoji: '🏠',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 10},
          production: {},
          upkeep: {},
          populationProvided: 4,
          unlockRequirements: {},
        );

        final newGameState = gameState.copyWith(
          buildings: {BuildingType.house: house},
        );

        expect(newGameState.totalPopulation, 14); // 10 + 4
      });

      test('can check if has enough resources', () {
        expect(gameState.hasEnoughResources({ResourceType.money: 30}), true);
        expect(gameState.hasEnoughResources({ResourceType.money: 60}), false);
        expect(
            gameState.hasEnoughResources({
              ResourceType.money: 30,
              ResourceType.materials: 10,
            }),
            true);
      });

      test('can check if has building', () {
        expect(gameState.hasBuilding(BuildingType.house), false);

        const house = Building(
          type: BuildingType.house,
          name: 'House',
          emoji: '🏠',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 10},
          production: {},
          upkeep: {},
          populationProvided: 4,
          unlockRequirements: {},
        );

        final newGameState = gameState.copyWith(
          buildings: {BuildingType.house: house},
        );

        expect(newGameState.hasBuilding(BuildingType.house), true);
      });

      test('calculates remaining time correctly', () {
        final startTime = DateTime.now().subtract(const Duration(minutes: 2));
        final gameStateWithTime = gameState.copyWith(gameStartTime: startTime);

        final remaining = gameStateWithTime.remainingTime;
        expect(remaining.inMinutes, lessThan(9));
        expect(remaining.inMinutes, greaterThan(7));
      });

      test('detects time up correctly', () {
        final startTime = DateTime.now().subtract(const Duration(minutes: 11));
        final gameStateWithTime = gameState.copyWith(gameStartTime: startTime);

        expect(gameStateWithTime.isTimeUp, true);
      });
    });

    group('GameStatus', () {
      test('has all expected statuses', () {
        expect(GameStatus.values.length, 4);
        expect(GameStatus.values, contains(GameStatus.playing));
        expect(GameStatus.values, contains(GameStatus.victory));
        expect(GameStatus.values, contains(GameStatus.defeat));
        expect(GameStatus.values, contains(GameStatus.timeUp));
      });
    });
  });
}
