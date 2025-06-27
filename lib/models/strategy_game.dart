/// 水滸伝戦略ゲームのモデル
library;

/// 地形の種類
enum TerrainType {
  mountain, // 山岳（高い防御力）
  river, // 河川（中程度の防御力、高い収入）
  forest, // 森林（隠密性、中程度の防御力）
  plains, // 平野（移動しやすい、低い防御力）
  city, // 都市（高い収入、中程度の防御力）
}

/// 地域/領土を表すクラス
class Territory {
  const Territory({
    required this.id,
    required this.name,
    required this.position,
    required this.owner,
    required this.troops,
    required this.maxTroops,
    required this.resources,
    required this.isCapital,
    required this.terrainType,
    required this.adjacentTerritoryIds,
    this.defenseBonus = 0,
    this.incomePerTurn = 1,
  });

  final String id;
  final String name;
  final Position position;
  final Owner owner;
  final int troops;
  final int maxTroops;
  final int resources;
  final bool isCapital;
  final TerrainType terrainType;
  final List<String> adjacentTerritoryIds; // 隣接する領土のID
  final int defenseBonus; // 防御ボーナス
  final int incomePerTurn; // ターンごとの収入

  Territory copyWith({
    String? id,
    String? name,
    Position? position,
    Owner? owner,
    int? troops,
    int? maxTroops,
    int? resources,
    bool? isCapital,
    TerrainType? terrainType,
    List<String>? adjacentTerritoryIds,
    int? defenseBonus,
    int? incomePerTurn,
  }) {
    return Territory(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      owner: owner ?? this.owner,
      troops: troops ?? this.troops,
      maxTroops: maxTroops ?? this.maxTroops,
      resources: resources ?? this.resources,
      isCapital: isCapital ?? this.isCapital,
      terrainType: terrainType ?? this.terrainType,
      adjacentTerritoryIds: adjacentTerritoryIds ?? this.adjacentTerritoryIds,
      defenseBonus: defenseBonus ?? this.defenseBonus,
      incomePerTurn: incomePerTurn ?? this.incomePerTurn,
    );
  }

  /// この領土の実際の防御力を計算
  int get effectiveDefense => troops + defenseBonus;

  /// 地形による戦術的優位性
  String get terrainIcon {
    switch (terrainType) {
      case TerrainType.mountain:
        return '⛰️';
      case TerrainType.river:
        return '🏞️';
      case TerrainType.forest:
        return '🌲';
      case TerrainType.plains:
        return '🌾';
      case TerrainType.city:
        return '🏰';
    }
  }

  /// 地形による説明
  String get terrainDescription {
    switch (terrainType) {
      case TerrainType.mountain:
        return '山岳地帯(防御+3)';
      case TerrainType.river:
        return '河川地帯(収入+2)';
      case TerrainType.forest:
        return '森林地帯(防御+1)';
      case TerrainType.plains:
        return '平野(移動容易)';
      case TerrainType.city:
        return '都市(収入+3)';
    }
  }
}

/// マップ上の位置
class Position {
  const Position(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Position && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'Position($x, $y)';
}

/// 領土の所有者
enum Owner {
  player,
  enemy,
  neutral,
}

/// ゲーム状態を管理するクラス
class StrategyGameState {
  const StrategyGameState({
    required this.territories,
    required this.playerGold,
    required this.playerTroops,
    required this.currentTurn,
    required this.gameStatus,
    required this.selectedTerritoryId,
  });

  final List<Territory> territories;
  final int playerGold;
  final int playerTroops;
  final int currentTurn;
  final GameStatus gameStatus;
  final String? selectedTerritoryId;

  StrategyGameState copyWith({
    List<Territory>? territories,
    int? playerGold,
    int? playerTroops,
    int? currentTurn,
    GameStatus? gameStatus,
    String? selectedTerritoryId,
  }) {
    return StrategyGameState(
      territories: territories ?? this.territories,
      playerGold: playerGold ?? this.playerGold,
      playerTroops: playerTroops ?? this.playerTroops,
      currentTurn: currentTurn ?? this.currentTurn,
      gameStatus: gameStatus ?? this.gameStatus,
      selectedTerritoryId: selectedTerritoryId ?? this.selectedTerritoryId,
    );
  }

  /// プレイヤーが所有する領土数
  int get playerTerritoryCount => territories.where((t) => t.owner == Owner.player).length;

  /// 敵が所有する領土数
  int get enemyTerritoryCount => territories.where((t) => t.owner == Owner.enemy).length;

  /// 中立の領土数
  int get neutralTerritoryCount => territories.where((t) => t.owner == Owner.neutral).length;

  /// 選択された領土を取得
  Territory? get selectedTerritory {
    if (selectedTerritoryId == null) return null;
    try {
      return territories.firstWhere((t) => t.id == selectedTerritoryId);
    } catch (e) {
      return null;
    }
  }

  /// 指定された領土を取得
  Territory? getTerritoryById(String id) {
    try {
      return territories.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// ゲームの状態
enum GameStatus {
  playing,
  victory,
  defeat,
  paused,
}

/// 戦闘結果
class BattleResult {
  const BattleResult({
    required this.attackerWins,
    required this.attackerLosses,
    required this.defenderLosses,
    required this.territoryConquered,
  });

  final bool attackerWins;
  final int attackerLosses;
  final int defenderLosses;
  final bool territoryConquered;
}

/// 水滸伝のキャラクター名（領土名として使用）
class WaterMarginTerritories {
  static const List<String> names = [
    '梁山泊', // Liangshan Marsh - the main base
    '東京城', // Tokyo (Kaifeng) - capital
    '大名府', // Daming Prefecture
    '青州府', // Qingzhou Prefecture
    '登州府', // Dengzhou Prefecture
    '済州府', // Jizhou Prefecture
    '応天府', // Yingtian Prefecture
    '太原府', // Taiyuan Prefecture
    '大同府', // Datong Prefecture
    '延安府', // Yan'an Prefecture
    '開封府', // Kaifeng Prefecture
    '洛陽城', // Luoyang City
    '長安城', // Chang'an City
    '成都府', // Chengdu Prefecture
    '杭州府', // Hangzhou Prefecture
  ];

  static String getRandomName() {
    return names[(DateTime.now().millisecondsSinceEpoch ~/ 1000) % names.length];
  }
}
