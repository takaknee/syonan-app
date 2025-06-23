/// 街づくりゲームのモデル
library;

/// 資源の種類
enum ResourceType {
  population, // 人口
  food, // 食料
  materials, // 材料
  energy, // エネルギー
  money, // お金
}

/// 建物の種類
enum BuildingType {
  // 住宅系
  house, // 家
  apartment, // アパート
  mansion, // マンション

  // 生産系
  farm, // 農場
  factory, // 工場
  powerPlant, // 発電所
  mine, // 鉱山

  // サービス系
  shop, // 商店
  hospital, // 病院
  school, // 学校
  park, // 公園
}

/// ユニットの種類
enum UnitType {
  worker, // 労働者
  farmer, // 農民
  engineer, // エンジニア
  merchant, // 商人
  student, // 学生
}

/// 建物のクラス
class Building {
  const Building({
    required this.type,
    required this.name,
    required this.emoji,
    required this.level,
    required this.maxLevel,
    required this.buildCost,
    required this.production,
    required this.upkeep,
    required this.populationProvided,
    required this.unlockRequirements,
  });

  final BuildingType type;
  final String name;
  final String emoji;
  final int level;
  final int maxLevel;
  final Map<ResourceType, int> buildCost;
  final Map<ResourceType, int> production; // 毎ターンの生産量
  final Map<ResourceType, int> upkeep; // 毎ターンの維持費
  final int populationProvided; // 提供する人口
  final Map<ResourceType, int> unlockRequirements; // 建設に必要な条件

  Building copyWith({
    BuildingType? type,
    String? name,
    String? emoji,
    int? level,
    int? maxLevel,
    Map<ResourceType, int>? buildCost,
    Map<ResourceType, int>? production,
    Map<ResourceType, int>? upkeep,
    int? populationProvided,
    Map<ResourceType, int>? unlockRequirements,
  }) {
    return Building(
      type: type ?? this.type,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      buildCost: buildCost ?? this.buildCost,
      production: production ?? this.production,
      upkeep: upkeep ?? this.upkeep,
      populationProvided: populationProvided ?? this.populationProvided,
      unlockRequirements: unlockRequirements ?? this.unlockRequirements,
    );
  }

  /// レベルアップ可能かチェック
  bool canUpgrade() => level < maxLevel;

  /// レベルアップ後の建物を取得
  Building upgraded() {
    if (!canUpgrade()) return this;

    final newLevel = level + 1;
    final multiplier = 1.0 + (newLevel * 0.3); // レベルが上がるごとに30%増加

    return copyWith(
      level: newLevel,
      buildCost:
          buildCost.map((k, v) => MapEntry(k, (v * multiplier * 0.8).round())),
      production:
          production.map((k, v) => MapEntry(k, (v * multiplier).round())),
      upkeep: upkeep.map((k, v) => MapEntry(k, (v * multiplier * 0.6).round())),
    );
  }
}

/// ランダムイベント
class RandomEvent {
  const RandomEvent({
    required this.name,
    required this.description,
    required this.emoji,
    required this.effects,
    required this.isPositive,
    required this.probability,
  });

  final String name;
  final String description;
  final String emoji;
  final Map<ResourceType, int> effects; // 資源への影響
  final bool isPositive;
  final double probability; // 発生確率（0.0-1.0）
}

/// ゲームの状態
enum GameStatus {
  playing,
  victory,
  defeat,
  timeUp,
}

/// 街づくりゲームの状態
class CityGameState {
  const CityGameState({
    required this.resources,
    required this.buildings,
    required this.units,
    required this.currentTurn,
    required this.gameStatus,
    required this.citySize,
    required this.selectedBuildingType,
    required this.availableEvents,
    required this.gameStartTime,
  });

  final Map<ResourceType, int> resources;
  final Map<BuildingType, Building> buildings; // 建設済みの建物
  final Map<UnitType, int> units; // 保有するユニット数
  final int currentTurn;
  final GameStatus gameStatus;
  final int citySize; // 街のサイズ（建設可能な建物数に影響）
  final BuildingType? selectedBuildingType;
  final List<RandomEvent> availableEvents;
  final DateTime gameStartTime;

  CityGameState copyWith({
    Map<ResourceType, int>? resources,
    Map<BuildingType, Building>? buildings,
    Map<UnitType, int>? units,
    int? currentTurn,
    GameStatus? gameStatus,
    int? citySize,
    BuildingType? selectedBuildingType,
    List<RandomEvent>? availableEvents,
    DateTime? gameStartTime,
  }) {
    return CityGameState(
      resources: resources ?? this.resources,
      buildings: buildings ?? this.buildings,
      units: units ?? this.units,
      currentTurn: currentTurn ?? this.currentTurn,
      gameStatus: gameStatus ?? this.gameStatus,
      citySize: citySize ?? this.citySize,
      selectedBuildingType: selectedBuildingType ?? this.selectedBuildingType,
      availableEvents: availableEvents ?? this.availableEvents,
      gameStartTime: gameStartTime ?? this.gameStartTime,
    );
  }

  /// 総人口を取得
  int get totalPopulation {
    int population = resources[ResourceType.population] ?? 0;
    for (final building in buildings.values) {
      population += building.populationProvided;
    }
    return population;
  }

  /// 建物数を取得
  int get totalBuildings => buildings.length;

  /// ゲーム経過時間を取得
  Duration get elapsedTime => DateTime.now().difference(gameStartTime);

  /// 残り時間を取得（10分制限）
  Duration get remainingTime {
    const gameMaxDuration = Duration(minutes: 10);
    final remaining = gameMaxDuration - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 時間切れかチェック
  bool get isTimeUp => remainingTime == Duration.zero;

  /// 特定の建物を持っているかチェック
  bool hasBuilding(BuildingType type) => buildings.containsKey(type);

  /// 特定のリソースが十分にあるかチェック
  bool hasEnoughResources(Map<ResourceType, int> required) {
    for (final entry in required.entries) {
      if ((resources[entry.key] ?? 0) < entry.value) {
        return false;
      }
    }
    return true;
  }
}
