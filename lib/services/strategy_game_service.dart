import 'dart:math';

import '../models/strategy_game.dart';

/// 水滸伝戦略ゲームのゲームロジックサービス
class StrategyGameService {
  static const int mapWidth = 5;
  static const int mapHeight = 4;
  static const int maxTurns = 15; // 約8-10分でゲーム終了を目指す
  static const int startingGold = 80;
  static const int startingTroops = 40;
  static const int troopCost = 8; // 兵士1人あたりのコスト（少し安く）

  final Random _random = Random();

  /// 新しいゲームを初期化
  StrategyGameState initializeGame() {
    final territories = _generateTerritories();

    return StrategyGameState(
      territories: territories,
      playerGold: startingGold,
      playerTroops: startingTroops,
      currentTurn: 1,
      gameStatus: GameStatus.playing,
      selectedTerritoryId: null,
    );
  }

  /// 領土を生成
  List<Territory> _generateTerritories() {
    final territories = <Territory>[];
    var nameIndex = 0;

    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        final position = Position(x, y);
        final isPlayerStart = x == 0 && y == 1; // 左端の中央がプレイヤー開始位置
        final isEnemyCapital = x == 4 && y == 2; // 右端がボス敵

        Owner owner;
        int troops;
        int resources;
        bool isCapital = false;
        TerrainType terrainType;
        int defenseBonus = 0;
        int incomePerTurn = 1;

        // 地形タイプを決定
        if (isEnemyCapital) {
          terrainType = TerrainType.city;
          defenseBonus = 5; // 首都は強力な防御
          incomePerTurn = 4;
        } else if (y == 0 || y == mapHeight - 1) {
          terrainType = TerrainType.mountain;
          defenseBonus = 3;
          incomePerTurn = 1;
        } else if (x == 2) {
          terrainType = TerrainType.river;
          defenseBonus = 1;
          incomePerTurn = 3;
        } else if (_random.nextBool()) {
          terrainType = TerrainType.forest;
          defenseBonus = 1;
          incomePerTurn = 2;
        } else {
          terrainType = TerrainType.plains;
          defenseBonus = 0;
          incomePerTurn = 2;
        }

        if (isPlayerStart) {
          owner = Owner.player;
          troops = 25; // 開始時の兵力を増やす
          resources = 40;
        } else if (isEnemyCapital) {
          owner = Owner.enemy;
          troops = 30; // ボス領土の兵力を調整
          resources = 60;
          isCapital = true;
        } else {
          // その他の領土は中立またはランダムに敵
          final random = _random.nextDouble();
          if (random < 0.25) {
            // 敵の確率を下げる
            owner = Owner.enemy;
            troops = _random.nextInt(10) + 3; // 敵の兵力を少し弱く
          } else {
            owner = Owner.neutral;
            troops = _random.nextInt(6) + 1; // 中立の兵力を少し弱く
          }
          resources = _random.nextInt(25) + 10;
        }

        // 隣接する領土IDsを計算
        final adjacentIds = <String>[];
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue; // 自分自身は除外
            final adjX = x + dx;
            final adjY = y + dy;
            if (adjX >= 0 && adjX < mapWidth && adjY >= 0 && adjY < mapHeight) {
              adjacentIds.add('territory_${adjX}_$adjY');
            }
          }
        }

        final territory = Territory(
          id: 'territory_${x}_$y',
          name: _getUniqueTerritoryName(nameIndex, territories),
          position: position,
          owner: owner,
          troops: troops,
          maxTroops: troops + _random.nextInt(20) + 10,
          resources: resources,
          isCapital: isCapital,
          terrainType: terrainType,
          adjacentTerritoryIds: adjacentIds,
          defenseBonus: defenseBonus,
          incomePerTurn: incomePerTurn,
        );

        territories.add(territory);
        nameIndex++;
      }
    }

    return territories;
  }

  /// ユニークな領土名を取得（重複を避ける）
  String _getUniqueTerritoryName(int index, List<Territory> existingTerritories) {
    final names = List<String>.from(WaterMarginTerritories.names);
    final usedNames = existingTerritories.map((t) => t.name).toSet();

    for (final name in names) {
      if (!usedNames.contains(name)) {
        return name;
      }
    }

    // すべての名前が使用されている場合は番号を付ける
    return '${names[index % names.length]} ${(index ~/ names.length) + 1}';
  }

  /// 領土を攻撃
  StrategyGameState attackTerritory(
    StrategyGameState gameState,
    String attackerTerritoryId,
    String defenderTerritoryId,
  ) {
    final attacker = gameState.getTerritoryById(attackerTerritoryId);
    final defender = gameState.getTerritoryById(defenderTerritoryId);

    if (attacker == null || defender == null) return gameState;
    if (attacker.owner != Owner.player) return gameState;
    if (defender.owner == Owner.player) return gameState;
    if (attacker.troops <= 1) return gameState; // 最低1部隊は残す

    // 攻撃可能な距離かチェック（隣接している必要がある）
    if (!_areAdjacent(attacker.position, defender.position)) {
      return gameState;
    }

    final battleResult = _resolveBattle(attacker.troops - 1, defender.troops, defender);

    final updatedTerritories = gameState.territories.map((territory) {
      if (territory.id == attackerTerritoryId) {
        return territory.copyWith(
          troops: territory.troops - battleResult.attackerLosses - (territory.troops - 1),
        );
      } else if (territory.id == defenderTerritoryId) {
        if (battleResult.territoryConquered) {
          return territory.copyWith(
            owner: Owner.player,
            troops: (attacker.troops - 1) - battleResult.attackerLosses,
          );
        } else {
          return territory.copyWith(
            troops: territory.troops - battleResult.defenderLosses,
          );
        }
      }
      return territory;
    }).toList();

    final newGameState = gameState.copyWith(
      territories: updatedTerritories,
      currentTurn: gameState.currentTurn + 1,
    );

    return _checkGameStatus(newGameState);
  }

  /// 兵士を募集
  StrategyGameState recruitTroops(
    StrategyGameState gameState,
    String territoryId,
    int amount,
  ) {
    final territory = gameState.getTerritoryById(territoryId);
    if (territory == null || territory.owner != Owner.player) return gameState;

    final cost = amount * troopCost;
    if (gameState.playerGold < cost) return gameState;
    if (territory.troops + amount > territory.maxTroops) return gameState;

    final updatedTerritories = gameState.territories.map((t) {
      if (t.id == territoryId) {
        return t.copyWith(troops: t.troops + amount);
      }
      return t;
    }).toList();

    return gameState.copyWith(
      territories: updatedTerritories,
      playerGold: gameState.playerGold - cost,
      playerTroops: gameState.playerTroops + amount,
    );
  }

  /// ターン終了（資源収集、敵AI行動）
  StrategyGameState endTurn(StrategyGameState gameState) {
    if (gameState.gameStatus != GameStatus.playing) return gameState;

    // プレイヤー領土からの資源収集
    int goldIncome = 0;
    for (final territory in gameState.territories) {
      if (territory.owner == Owner.player) {
        // 基本収入 + 地形による追加収入
        goldIncome += territory.incomePerTurn;
        goldIncome += territory.resources ~/ 3; // 領土の資源値による追加収入
      }
    }

    // 敵のAI行動をシミュレート
    var updatedTerritories = List<Territory>.from(gameState.territories);

    // 敵領土の兵士を少し増やす（簡単なAI）
    updatedTerritories = updatedTerritories.map((territory) {
      if (territory.owner == Owner.enemy && _random.nextDouble() < 0.3) {
        final increase = _random.nextInt(2) + 1;
        return territory.copyWith(
          troops: (territory.troops + increase).clamp(0, territory.maxTroops),
        );
      }
      return territory;
    }).toList();

    final newGameState = gameState.copyWith(
      territories: updatedTerritories,
      playerGold: gameState.playerGold + goldIncome,
      currentTurn: gameState.currentTurn + 1,
    );

    return _checkGameStatus(newGameState);
  }

  /// 戦闘を解決（地形ボーナスと戦術要素を含む）
  BattleResult _resolveBattle(int attackerTroops, int defenderTroops, Territory defenderTerritory) {
    // 基本戦力計算
    final attackerBasePower = attackerTroops * (0.8 + _random.nextDouble() * 0.4);
    final defenderBasePower = defenderTroops * (0.9 + _random.nextDouble() * 0.4);

    // 防御側の地形ボーナスを適用
    final defenseBonus = defenderTerritory.defenseBonus;
    final defenderTotalPower = defenderBasePower + defenseBonus;

    // 首都は追加の防御ボーナス
    final capitalBonus = defenderTerritory.isCapital ? 5 : 0;
    final finalDefenderPower = defenderTotalPower + capitalBonus;

    final attackerWins = attackerBasePower > finalDefenderPower;

    // 損失計算（より現実的に）
    int attackerLosses;
    int defenderLosses;

    if (attackerWins) {
      // 攻撃側勝利時の損失
      defenderLosses = defenderTroops; // 全滅
      attackerLosses = (attackerTroops * 0.3 * _random.nextDouble()).round().clamp(1, attackerTroops - 1);
    } else {
      // 防御側勝利時の損失
      attackerLosses = (attackerTroops * 0.6).round().clamp(1, attackerTroops);
      defenderLosses = (defenderTroops * 0.2 * _random.nextDouble()).round().clamp(0, defenderTroops - 1);
    }

    return BattleResult(
      attackerWins: attackerWins,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      territoryConquered: attackerWins,
    );
  }

  /// 隣接しているかチェック
  bool _areAdjacent(Position pos1, Position pos2) {
    final dx = (pos1.x - pos2.x).abs();
    final dy = (pos1.y - pos2.y).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// ゲーム状態をチェック（勝利/敗北条件）
  StrategyGameState _checkGameStatus(StrategyGameState gameState) {
    // 勝利条件：敵の首都を占領
    final enemyCapital = gameState.territories.firstWhere(
      (t) => t.isCapital,
      orElse: () => const Territory(
        id: '',
        name: '',
        position: Position(0, 0),
        owner: Owner.neutral,
        troops: 0,
        maxTroops: 0,
        resources: 0,
        isCapital: false,
        terrainType: TerrainType.plains,
        adjacentTerritoryIds: [],
      ),
    );

    if (enemyCapital.owner == Owner.player) {
      return gameState.copyWith(gameStatus: GameStatus.victory);
    }

    // 敗北条件：プレイヤーの領土がすべて失われた、またはターン数上限
    final playerTerritories = gameState.territories.where((t) => t.owner == Owner.player).toList();

    if (playerTerritories.isEmpty || gameState.currentTurn >= maxTurns) {
      return gameState.copyWith(gameStatus: GameStatus.defeat);
    }

    return gameState;
  }

  /// 選択可能な攻撃対象を取得（隣接性を正確にチェック）
  List<Territory> getAttackableTargets(
    StrategyGameState gameState,
    String territoryId,
  ) {
    final territory = gameState.getTerritoryById(territoryId);
    if (territory == null || territory.owner != Owner.player || territory.troops <= 1) {
      return [];
    }

    final attackableTargets = <Territory>[];

    // 隣接する領土IDから実際に攻撃可能な領土を取得
    for (final adjacentId in territory.adjacentTerritoryIds) {
      final adjacent = gameState.getTerritoryById(adjacentId);
      if (adjacent != null && adjacent.owner != Owner.player) {
        attackableTargets.add(adjacent);
      }
    }

    return attackableTargets;
  }

  /// 最終スコアを計算
  int calculateFinalScore(StrategyGameState gameState, Duration gameDuration) {
    int score = 0;

    // 基本スコア
    score += gameState.playerTerritoryCount * 100;
    score += gameState.playerGold;
    score += gameState.playerTroops * 2;

    // 勝利ボーナス
    if (gameState.gameStatus == GameStatus.victory) {
      score += 1000;
      // 早期クリアボーナス
      final remainingTurns = maxTurns - gameState.currentTurn;
      score += remainingTurns * 50;
    }

    // 時間ボーナス（10分以内）
    if (gameDuration.inMinutes < 10) {
      score += (600 - gameDuration.inSeconds) * 2;
    }

    return score.clamp(0, 10000);
  }
}
