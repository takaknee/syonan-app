import 'dart:math';
import '../models/city_building_game.dart';

/// 街づくりゲームのゲームロジックサービス
class CityBuildingGameService {
  static const int maxTurns = 30; // 約10分でゲーム終了を目指す
  static const int startingPopulation = 10;
  static const int startingFood = 20;
  static const int startingMaterials = 15;
  static const int startingEnergy = 10;
  static const int startingMoney = 50;
  static const int baseCitySize = 3; // 初期建設可能数
  
  final Random _random = Random();

  /// 新しいゲームを初期化
  CityGameState initializeGame() {
    return CityGameState(
      resources: {
        ResourceType.population: startingPopulation,
        ResourceType.food: startingFood,
        ResourceType.materials: startingMaterials,
        ResourceType.energy: startingEnergy,
        ResourceType.money: startingMoney,
      },
      buildings: {},
      units: {},
      currentTurn: 1,
      gameStatus: GameStatus.playing,
      citySize: baseCitySize,
      selectedBuildingType: null,
      availableEvents: _generateRandomEvents(),
      gameStartTime: DateTime.now(),
    );
  }

  /// 建物を建設
  CityGameState buildBuilding(CityGameState gameState, BuildingType buildingType) {
    if (gameState.gameStatus != GameStatus.playing) return gameState;
    
    final buildingTemplate = _getBuildingTemplate(buildingType);
    if (buildingTemplate == null) return gameState;

    // 建設条件をチェック
    if (!gameState.hasEnoughResources(buildingTemplate.buildCost)) return gameState;
    if (gameState.totalBuildings >= gameState.citySize) return gameState;
    if (!gameState.hasEnoughResources(buildingTemplate.unlockRequirements)) return gameState;

    // 既に同じ建物があればレベルアップ
    final existingBuilding = gameState.buildings[buildingType];
    Building newBuilding;
    if (existingBuilding != null) {
      if (!existingBuilding.canUpgrade()) return gameState;
      newBuilding = existingBuilding.upgraded();
    } else {
      newBuilding = buildingTemplate;
    }

    // リソースを消費
    final newResources = Map<ResourceType, int>.from(gameState.resources);
    for (final entry in buildingTemplate.buildCost.entries) {
      newResources[entry.key] = (newResources[entry.key] ?? 0) - entry.value;
    }

    // 建物を追加/更新
    final newBuildings = Map<BuildingType, Building>.from(gameState.buildings);
    newBuildings[buildingType] = newBuilding;

    return gameState.copyWith(
      resources: newResources,
      buildings: newBuildings,
    );
  }

  /// ターン終了処理
  CityGameState endTurn(CityGameState gameState) {
    if (gameState.gameStatus != GameStatus.playing) return gameState;

    // 生産と消費を計算
    final newResources = Map<ResourceType, int>.from(gameState.resources);
    
    // 建物からの生産
    for (final building in gameState.buildings.values) {
      for (final entry in building.production.entries) {
        newResources[entry.key] = (newResources[entry.key] ?? 0) + entry.value;
      }
      // 維持費を消費
      for (final entry in building.upkeep.entries) {
        newResources[entry.key] = (newResources[entry.key] ?? 0) - entry.value;
      }
    }

    // 基本消費（人口による食料消費など）
    final population = gameState.totalPopulation;
    newResources[ResourceType.food] = (newResources[ResourceType.food] ?? 0) - (population ~/ 2);

    // リソースの最低値を0に設定
    for (final key in newResources.keys) {
      newResources[key] = newResources[key]!.clamp(0, 9999);
    }

    // ランダムイベント発生
    var updatedGameState = gameState.copyWith(
      resources: newResources,
      currentTurn: gameState.currentTurn + 1,
    );

    if (_random.nextDouble() < 0.2) { // 20%の確率でイベント発生
      updatedGameState = _triggerRandomEvent(updatedGameState);
    }

    // 街の拡張判定
    if (gameState.totalBuildings >= gameState.citySize && _random.nextDouble() < 0.3) {
      updatedGameState = updatedGameState.copyWith(
        citySize: gameState.citySize + 1,
      );
    }

    // ゲーム終了条件をチェック
    return _checkGameStatus(updatedGameState);
  }

  /// 利用可能な建設選択肢を取得
  List<BuildingType> getAvailableBuildingOptions(CityGameState gameState) {
    final available = <BuildingType>[];
    
    for (final buildingType in BuildingType.values) {
      final template = _getBuildingTemplate(buildingType);
      if (template != null) {
        // 建設可能な条件をチェック
        if (gameState.hasEnoughResources(template.unlockRequirements)) {
          // 既に建設済みの場合はレベルアップ可能かチェック
          final existing = gameState.buildings[buildingType];
          if (existing == null || existing.canUpgrade()) {
            available.add(buildingType);
          }
        }
      }
    }
    
    return available;
  }

  /// 最終スコアを計算
  int calculateFinalScore(CityGameState gameState) {
    int score = 0;
    
    // 基本スコア
    score += gameState.totalPopulation * 10;
    score += gameState.totalBuildings * 50;
    score += (gameState.resources[ResourceType.money] ?? 0);
    score += gameState.citySize * 20;
    
    // 建物レベルボーナス
    for (final building in gameState.buildings.values) {
      score += building.level * 30;
    }
    
    // 時間ボーナス（早期達成）
    final elapsedMinutes = gameState.elapsedTime.inMinutes;
    if (elapsedMinutes < 10) {
      score += (10 - elapsedMinutes) * 100;
    }
    
    // 勝利ボーナス
    if (gameState.gameStatus == GameStatus.victory) {
      score += 1000;
    }
    
    return score.clamp(0, 10000);
  }

  /// 建物テンプレートを取得
  Building? _getBuildingTemplate(BuildingType type) {
    switch (type) {
      case BuildingType.house:
        return const Building(
          type: BuildingType.house,
          name: '家',
          emoji: '🏠',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 10, ResourceType.money: 20},
          production: {},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 4,
          unlockRequirements: {},
        );
      case BuildingType.apartment:
        return const Building(
          type: BuildingType.apartment,
          name: 'アパート',
          emoji: '🏢',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 25, ResourceType.money: 50},
          production: {},
          upkeep: {ResourceType.energy: 2},
          populationProvided: 12,
          unlockRequirements: {ResourceType.population: 20},
        );
      case BuildingType.mansion:
        return const Building(
          type: BuildingType.mansion,
          name: 'マンション',
          emoji: '🏬',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.materials: 50, ResourceType.money: 100},
          production: {},
          upkeep: {ResourceType.energy: 4},
          populationProvided: 30,
          unlockRequirements: {ResourceType.population: 50},
        );
      case BuildingType.farm:
        return const Building(
          type: BuildingType.farm,
          name: '農場',
          emoji: '🚜',
          level: 1,
          maxLevel: 4,
          buildCost: {ResourceType.materials: 15, ResourceType.money: 30},
          production: {ResourceType.food: 8},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 0,
          unlockRequirements: {},
        );
      case BuildingType.factory:
        return const Building(
          type: BuildingType.factory,
          name: '工場',
          emoji: '🏭',
          level: 1,
          maxLevel: 4,
          buildCost: {ResourceType.materials: 30, ResourceType.money: 60},
          production: {ResourceType.materials: 6, ResourceType.money: 10},
          upkeep: {ResourceType.energy: 3, ResourceType.food: 2},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 15},
        );
      case BuildingType.powerPlant:
        return const Building(
          type: BuildingType.powerPlant,
          name: '発電所',
          emoji: '⚡',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 40, ResourceType.money: 80},
          production: {ResourceType.energy: 12},
          upkeep: {ResourceType.materials: 2},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 25},
        );
      case BuildingType.mine:
        return const Building(
          type: BuildingType.mine,
          name: '鉱山',
          emoji: '⛏️',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.money: 70},
          production: {ResourceType.materials: 10},
          upkeep: {ResourceType.energy: 2, ResourceType.food: 1},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 20},
        );
      case BuildingType.shop:
        return const Building(
          type: BuildingType.shop,
          name: '商店',
          emoji: '🏪',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 20, ResourceType.money: 40},
          production: {ResourceType.money: 15},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 30},
        );
      case BuildingType.hospital:
        return const Building(
          type: BuildingType.hospital,
          name: '病院',
          emoji: '🏥',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.materials: 35, ResourceType.money: 100},
          production: {},
          upkeep: {ResourceType.energy: 3, ResourceType.money: 10},
          populationProvided: 5,
          unlockRequirements: {ResourceType.population: 40},
        );
      case BuildingType.school:
        return const Building(
          type: BuildingType.school,
          name: '学校',
          emoji: '🏫',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.materials: 30, ResourceType.money: 80},
          production: {},
          upkeep: {ResourceType.energy: 2, ResourceType.money: 5},
          populationProvided: 8,
          unlockRequirements: {ResourceType.population: 35},
        );
      case BuildingType.park:
        return const Building(
          type: BuildingType.park,
          name: '公園',
          emoji: '🌳',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.money: 25},
          production: {},
          upkeep: {ResourceType.money: 2},
          populationProvided: 3,
          unlockRequirements: {ResourceType.population: 25},
        );
    }
  }

  /// ランダムイベントを生成
  List<RandomEvent> _generateRandomEvents() {
    return [
      const RandomEvent(
        name: '豊作',
        description: '農作物が豊作でした！',
        emoji: '🌾',
        effects: {ResourceType.food: 15},
        isPositive: true,
        probability: 0.15,
      ),
      const RandomEvent(
        name: '新住民',
        description: '新しい住民が移住してきました！',
        emoji: '👨‍👩‍👧‍👦',
        effects: {ResourceType.population: 5, ResourceType.money: 10},
        isPositive: true,
        probability: 0.1,
      ),
      const RandomEvent(
        name: '資源発見',
        description: '新しい鉱脈が発見されました！',
        emoji: '💎',
        effects: {ResourceType.materials: 20},
        isPositive: true,
        probability: 0.08,
      ),
      const RandomEvent(
        name: '停電',
        description: '街で停電が発生しました...',
        emoji: '⚫',
        effects: {ResourceType.energy: -8},
        isPositive: false,
        probability: 0.12,
      ),
      const RandomEvent(
        name: '火災',
        description: '火災が発生し、建材が失われました...',
        emoji: '🔥',
        effects: {ResourceType.materials: -12},
        isPositive: false,
        probability: 0.1,
      ),
      const RandomEvent(
        name: '祭り',
        description: '街で祭りが開催され、賑わっています！',
        emoji: '🎪',
        effects: {ResourceType.money: 25, ResourceType.population: 3},
        isPositive: true,
        probability: 0.08,
      ),
    ];
  }

  /// ランダムイベントを発生させる
  CityGameState _triggerRandomEvent(CityGameState gameState) {
    final availableEvents = gameState.availableEvents.where((event) {
      return _random.nextDouble() < event.probability;
    }).toList();

    if (availableEvents.isEmpty) return gameState;

    final event = availableEvents[_random.nextInt(availableEvents.length)];
    final newResources = Map<ResourceType, int>.from(gameState.resources);

    for (final entry in event.effects.entries) {
      newResources[entry.key] = ((newResources[entry.key] ?? 0) + entry.value).clamp(0, 9999);
    }

    return gameState.copyWith(resources: newResources);
  }

  /// ゲーム状態をチェック
  CityGameState _checkGameStatus(CityGameState gameState) {
    // 時間切れチェック
    if (gameState.isTimeUp) {
      return gameState.copyWith(gameStatus: GameStatus.timeUp);
    }

    // 敗北条件：食料が尽きて人口が0になった
    if (gameState.totalPopulation <= 0) {
      return gameState.copyWith(gameStatus: GameStatus.defeat);
    }

    // 勝利条件：人口100人以上、建物10個以上、またはお金500以上
    final population = gameState.totalPopulation;
    final buildings = gameState.totalBuildings;
    final money = gameState.resources[ResourceType.money] ?? 0;

    if (population >= 100 || buildings >= 10 || money >= 500) {
      return gameState.copyWith(gameStatus: GameStatus.victory);
    }

    return gameState;
  }
}