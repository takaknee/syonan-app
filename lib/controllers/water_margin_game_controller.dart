/// 水滸伝戦略ゲームのコントローラー
/// フェーズ1: 基本的なゲーム状態管理とUI操作
library;

import 'package:flutter/material.dart' hide Hero;

import '../data/water_margin_heroes.dart';
import '../data/water_margin_map.dart';
import '../models/water_margin_strategy_game.dart';

/// 水滸伝戦略ゲームのメインコントローラー
class WaterMarginGameController extends ChangeNotifier {
  /// ゲーム状態
  WaterMarginGameState _gameState = WaterMarginGameState(
    provinces: WaterMarginMap.initialProvinces,
    heroes: WaterMarginHeroes.initialHeroes,
    currentTurn: 1,
    playerGold: 1000, // 初期資金
    gameStatus: GameStatus.playing,
  );

  /// 現在のゲーム状態を取得
  WaterMarginGameState get gameState => _gameState;

  /// ゲームを初期化
  void initializeGame() {
    _gameState = WaterMarginGameState(
      provinces: WaterMarginMap.initialProvinces,
      heroes: WaterMarginHeroes.initialHeroes,
      currentTurn: 1,
      playerGold: 1000,
      gameStatus: GameStatus.playing,
    );
    notifyListeners();
  }

  // === UI操作系 ===

  /// 州を選択
  void selectProvince(String? provinceId) {
    _gameState = _gameState.copyWith(
      selectedProvinceId: provinceId,
    );
    notifyListeners();
  }

  /// 英雄を選択
  void selectHero(String? heroId) {
    _gameState = _gameState.copyWith(
      selectedHeroId: heroId,
    );
    notifyListeners();
  }

  /// 選択をクリア
  void clearSelection() {
    _gameState = _gameState.copyWith();
    notifyListeners();
  }

  // === ターン進行系 ===

  /// 次のターンに進む
  void nextTurn() {
    if (_gameState.gameStatus != GameStatus.playing) return;

    // 1. 収入計算
    final income = _calculateTurnIncome();

    // 2. 内政処理
    final updatedProvinces = _processProvincesDevelopment();

    // 3. AI行動
    _processAIActions();

    // 4. 勝利条件チェック
    final newGameStatus = _checkVictoryConditions();

    _gameState = _gameState.copyWith(
      currentTurn: _gameState.currentTurn + 1,
      playerGold: _gameState.playerGold + income,
      provinces: updatedProvinces,
      gameStatus: newGameStatus,
    );

    notifyListeners();
  }

  /// ターン収入を計算
  int _calculateTurnIncome() {
    int totalIncome = 0;

    for (final province in _gameState.provinces) {
      if (province.controller == Faction.liangshan) {
        // 基本収入
        totalIncome += province.state.taxIncome;

        // 特殊効果による収入ボーナス
        if (province.specialFeature?.contains('商業収入') == true) {
          totalIncome += (province.state.taxIncome * 0.3).round();
        }
        if (province.specialFeature?.contains('皇都') == true) {
          totalIncome += (province.state.taxIncome * 0.5).round();
        }
      }
    }

    return totalIncome;
  }

  /// 州の発展処理
  List<Province> _processProvincesDevelopment() {
    return _gameState.provinces.map((province) {
      if (province.controller == Faction.liangshan) {
        // プレイヤー領土の自然発展
        final newState = province.state.copyWith(
          loyalty: (province.state.loyalty + 1).clamp(0, 100),
          security: (province.state.security + 1).clamp(0, 100),
        );
        return province.copyWith(state: newState);
      }
      return province;
    }).toList();
  }

  /// AI行動処理（フェーズ1では簡易版）
  void _processAIActions() {
    // 将来の実装: AI勢力の行動決定
    // - 領土拡張
    // - 軍備増強
    // - 外交交渉
  }

  /// 勝利条件チェック
  GameStatus _checkVictoryConditions() {
    // 敗北条件: 梁山泊を失った
    final liangshan = _gameState.provinces.firstWhere((p) => p.id == 'liangshan');
    if (liangshan.controller != Faction.liangshan) {
      return GameStatus.defeat;
    }

    // 勝利条件1: 全州制圧
    final playerProvinces = _gameState.provinces.where((p) => p.controller == Faction.liangshan).length;
    if (playerProvinces >= _gameState.provinces.length) {
      return GameStatus.victory;
    }

    // 勝利条件2: 朝廷首都制圧
    final kaifeng = _gameState.provinces.firstWhere((p) => p.id == 'kaifeng');
    if (kaifeng.controller == Faction.liangshan) {
      return GameStatus.victory;
    }

    return GameStatus.playing;
  }

  // === 戦闘系 ===

  /// 州への攻撃を実行
  bool attackProvince(String targetProvinceId, String sourceProvinceId) {
    final target = _gameState.getProvinceById(targetProvinceId);
    final source = _gameState.getProvinceById(sourceProvinceId);

    if (target == null || source == null) return false;
    if (source.controller != Faction.liangshan) return false;
    if (target.controller == Faction.liangshan) return false;

    // 隣接チェック
    if (!source.adjacentProvinceIds.contains(targetProvinceId)) return false;

    // 兵力チェック
    if (source.currentTroops < 1000) return false; // 最低1000必要

    // 簡易戦闘計算
    final battleResult = _calculateBattle(source, target);

    if (battleResult.attackerWins) {
      // 勝利: 州を獲得
      final updatedProvinces = _gameState.provinces.map((p) {
        if (p.id == targetProvinceId) {
          return p.copyWith(
            controller: Faction.liangshan,
            currentTroops: (source.currentTroops - battleResult.attackerLosses) ~/ 2,
          );
        } else if (p.id == sourceProvinceId) {
          return p.copyWith(
            currentTroops: source.currentTroops - battleResult.attackerLosses,
          );
        }
        return p;
      }).toList();

      _gameState = _gameState.copyWith(provinces: updatedProvinces);
      notifyListeners();
      return true;
    } else {
      // 敗北: 兵力減少のみ
      final updatedProvinces = _gameState.provinces.map((p) {
        if (p.id == sourceProvinceId) {
          return p.copyWith(
            currentTroops: source.currentTroops - battleResult.attackerLosses,
          );
        } else if (p.id == targetProvinceId) {
          return p.copyWith(
            currentTroops: target.currentTroops - battleResult.defenderLosses,
          );
        }
        return p;
      }).toList();

      _gameState = _gameState.copyWith(provinces: updatedProvinces);
      notifyListeners();
      return false;
    }
  }

  /// 戦闘計算（簡易版）
  BattleResult _calculateBattle(Province attacker, Province defender) {
    // 攻撃力計算
    int attackPower = attacker.currentTroops;

    // 防御力計算（地形ボーナス込み）
    int defensePower = defender.currentTroops;
    if (defender.specialFeature?.contains('防御') == true) {
      defensePower = (defensePower * 1.2).round();
    }
    if (defender.specialFeature?.contains('要塞') == true) {
      defensePower = (defensePower * 1.15).round();
    }

    // 戦闘結果判定
    final bool attackerWins = attackPower > defensePower;

    // 損失計算
    final int attackerLosses = (attacker.currentTroops * 0.3).round();
    final int defenderLosses =
        attackerWins ? (defender.currentTroops * 0.7).round() : (defender.currentTroops * 0.2).round();

    return BattleResult(
      attackerWins: attackerWins,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      territoryConquered: attackerWins,
    );
  }

  // === 内政系 ===

  /// 州の開発
  bool developProvince(String provinceId, DevelopmentType type) {
    final province = _gameState.getProvinceById(provinceId);
    if (province == null || province.controller != Faction.liangshan) return false;

    final cost = _getDevelopmentCost(type);
    if (_gameState.playerGold < cost) return false;

    final newState = _applyDevelopment(province.state, type);
    final updatedProvinces = _gameState.provinces.map((p) {
      if (p.id == provinceId) {
        return p.copyWith(state: newState);
      }
      return p;
    }).toList();

    _gameState = _gameState.copyWith(
      provinces: updatedProvinces,
      playerGold: _gameState.playerGold - cost,
    );

    notifyListeners();
    return true;
  }

  /// 開発コスト
  int _getDevelopmentCost(DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return 200;
      case DevelopmentType.commerce:
        return 300;
      case DevelopmentType.military:
        return 400;
      case DevelopmentType.security:
        return 150;
    }
  }

  /// 開発効果適用
  ProvinceState _applyDevelopment(ProvinceState state, DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return state.copyWith(
          agriculture: (state.agriculture + 10).clamp(0, 100),
        );
      case DevelopmentType.commerce:
        return state.copyWith(
          commerce: (state.commerce + 10).clamp(0, 100),
        );
      case DevelopmentType.military:
        return state.copyWith(
          military: (state.military + 10).clamp(0, 100),
        );
      case DevelopmentType.security:
        return state.copyWith(
          security: (state.security + 10).clamp(0, 100),
        );
    }
  }

  // === 英雄系 ===

  /// 英雄を登用
  bool recruitHero(String heroId) {
    final hero = _gameState.getHeroById(heroId);
    if (hero == null || hero.isRecruited) return false;

    final cost = _getRecruitmentCost(hero);
    if (_gameState.playerGold < cost) return false;

    final updatedHeroes = _gameState.heroes.map((h) {
      if (h.id == heroId) {
        return h.copyWith(
          isRecruited: true,
          faction: Faction.liangshan,
        );
      }
      return h;
    }).toList();

    _gameState = _gameState.copyWith(
      heroes: updatedHeroes,
      playerGold: _gameState.playerGold - cost,
    );

    notifyListeners();
    return true;
  }

  /// 登用コスト計算
  int _getRecruitmentCost(Hero hero) {
    // 能力値に基づいてコスト計算
    final totalStats = hero.stats.force + hero.stats.intelligence + hero.stats.charisma + hero.stats.leadership;
    return (totalStats * 3).round();
  }

  // === ゲーム状態問い合わせ ===

  /// 攻撃可能な州を取得
  List<Province> getAttackableProvinces(String sourceProvinceId) {
    final source = _gameState.getProvinceById(sourceProvinceId);
    if (source == null || source.controller != Faction.liangshan) return [];

    return source.adjacentProvinceIds
        .map((id) => _gameState.getProvinceById(id))
        .where((p) => p != null && p.controller != Faction.liangshan)
        .cast<Province>()
        .toList();
  }

  /// 登用可能な英雄を取得
  List<Hero> getRecruitableHeroes() {
    return _gameState.heroes.where((h) => !h.isRecruited && h.faction != Faction.imperial).toList();
  }
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

/// 開発の種類
enum DevelopmentType {
  agriculture, // 農業開発
  commerce, // 商業開発
  military, // 軍事開発
  security, // 治安改善
}
