/// 水滸伝戦略ゲームのコントローラー
/// フェーズ1: 基本的なゲーム状態管理とUI操作
library;

import 'package:flutter/material.dart' hide Hero;

import '../data/water_margin_heroes.dart';
import '../data/water_margin_map.dart';
import '../models/advanced_battle_system.dart';
import '../models/ai_system.dart';
import '../models/game_events.dart';
import '../models/hero_advancement.dart';
import '../models/water_margin_strategy_game.dart';

/// 水滸伝戦略ゲームのメインコントローラー
class WaterMarginGameController extends ChangeNotifier {
  /// コンストラクタ
  WaterMarginGameController();

  /// ゲーム状態
  WaterMarginGameState _gameState = WaterMarginGameState(
    provinces: WaterMarginMap.initialProvinces,
    heroes: WaterMarginHeroes.initialHeroes,
    currentTurn: 1,
    playerGold: 1000, // 初期資金
    gameStatus: GameStatus.playing,
  );

  /// イベントログ
  List<String> _eventLog = [];

  /// 拡張英雄システム管理
  final Map<String, AdvancedHero> _advancedHeroes = {};

  /// 現在のゲーム状態を取得
  WaterMarginGameState get gameState => _gameState;

  /// イベントログを取得
  List<String> get eventLog => List.unmodifiable(_eventLog);

  /// 拡張英雄を取得
  AdvancedHero? getAdvancedHero(String heroId) {
    return _advancedHeroes[heroId];
  }

  /// 全ての拡張英雄を取得
  Map<String, AdvancedHero> get advancedHeroes => Map.unmodifiable(_advancedHeroes);

  /// ゲームを初期化
  void initializeGame() {
    _gameState = WaterMarginGameState(
      provinces: WaterMarginMap.initialProvinces,
      heroes: WaterMarginHeroes.initialHeroes,
      currentTurn: 1,
      playerGold: 1000,
      gameStatus: GameStatus.playing,
    );

    // 既存英雄を拡張英雄に変換
    _initializeAdvancedHeroes();

    notifyListeners();
  }

  /// 拡張英雄システム初期化
  void _initializeAdvancedHeroes() {
    _advancedHeroes.clear();

    for (final hero in _gameState.heroes) {
      _initializeAdvancedHero(hero.id);
    }
  }

  /// 単一英雄の拡張データ初期化
  void _initializeAdvancedHero(String heroId) {
    final hero = _gameState.heroes.firstWhere(
      (h) => h.id == heroId,
      orElse: () => throw ArgumentError('Hero not found: $heroId'),
    );

    // 基本経験値を設定（既存英雄はレベル1からスタート）
    final initialExp = <ExperienceType, int>{
      ExperienceType.combat: 0,
      ExperienceType.administration: 0,
      ExperienceType.diplomacy: 0,
      ExperienceType.leadership: 0,
    };

    final advancedStats = HeroAdvancedStats(
      baseStats: hero.stats,
      level: 1,
      experience: initialExp,
      skills: <HeroLevelSkill>{},
    );

    final advancedHero = AdvancedHero(
      baseHero: hero,
      advancedStats: advancedStats,
    );

    _advancedHeroes[hero.id] = advancedHero;
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
    _processAdvancedAI();

    // 4. イベント処理
    _processRandomEvents();

    // 5. 勝利条件チェック
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

      // 参加英雄に戦闘経験値を付与
      _awardCombatExperience(sourceProvinceId, 50); // 勝利時経験値

      _gameState = _gameState.copyWith(provinces: updatedProvinces);
      _addEventLog('${source.name}が${target.name}を制圧しました！');
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
    // 改良戦闘システムを使用
    final attackerParticipant = BattleParticipant(
      faction: attacker.controller,
      troops: attacker.currentTroops,
      heroes: _getProvinceBattleHeroes(attacker.id),
      province: attacker,
    );

    final defenderParticipant = BattleParticipant(
      faction: defender.controller,
      troops: defender.currentTroops,
      heroes: _getProvinceBattleHeroes(defender.id),
      province: defender,
    );

    // 地形判定（簡易実装）
    final terrain = _getProvinceTerrain(defender);

    final advancedResult = AdvancedBattleSystem.calculateBattle(
      attacker: attackerParticipant,
      defender: defenderParticipant,
      battleType: BattleType.fieldBattle,
      terrain: terrain,
    );

    // 従来のBattleResultに変換
    return BattleResult(
      attackerWins: advancedResult.winner == attacker.controller,
      attackerLosses: advancedResult.attackerLosses,
      defenderLosses: advancedResult.defenderLosses,
      territoryConquered: advancedResult.winner == attacker.controller,
    );
  }

  /// 州の戦闘に参加する英雄リストを取得
  List<Hero> _getProvinceBattleHeroes(String provinceId) {
    return _gameState.heroes.where((hero) => hero.isRecruited && hero.currentProvinceId == provinceId).toList();
  }

  /// 州の地形を取得
  BattleTerrain _getProvinceTerrain(Province province) {
    // 特殊地形の簡易判定
    if (province.specialFeature?.contains('山') == true) return BattleTerrain.mountains;
    if (province.specialFeature?.contains('河') == true) return BattleTerrain.river;
    if (province.specialFeature?.contains('要塞') == true) return BattleTerrain.fortress;
    if (province.specialFeature?.contains('森') == true) return BattleTerrain.forest;
    return BattleTerrain.plains; // デフォルトは平野
  }

  // === フェーズ3: 英雄レベルアップシステム ===

  /// 戦闘経験値を付与
  void _awardCombatExperience(String provinceId, int baseExperience) {
    final participatingHeroes = _getProvinceBattleHeroes(provinceId);

    for (final hero in participatingHeroes) {
      final advancedHero = _advancedHeroes[hero.id];
      if (advancedHero != null) {
        // 英雄の戦闘力に応じて経験値調整
        final experienceGained = (baseExperience * (hero.stats.combatPower / 100)).round();
        final updatedAdvancedHero = advancedHero.gainExperience(
          ExperienceType.combat,
          experienceGained,
        );

        _advancedHeroes[hero.id] = updatedAdvancedHero;

        // レベルアップ通知
        if (updatedAdvancedHero.advancedStats.level > advancedHero.advancedStats.level) {
          _addEventLog('${hero.name}がレベル${updatedAdvancedHero.advancedStats.level}になりました！');
        }
      }
    }
  }

  /// 内政経験値を付与
  void _awardAdministrationExperience(String heroId, int baseExperience) {
    final advancedHero = _advancedHeroes[heroId];
    if (advancedHero != null) {
      final experienceGained = (baseExperience * (advancedHero.baseHero.stats.administrativePower / 100)).round();
      final updatedAdvancedHero = advancedHero.gainExperience(
        ExperienceType.administration,
        experienceGained,
      );

      _advancedHeroes[heroId] = updatedAdvancedHero;

      // レベルアップ通知
      if (updatedAdvancedHero.advancedStats.level > advancedHero.advancedStats.level) {
        _addEventLog('${advancedHero.baseHero.name}がレベル${updatedAdvancedHero.advancedStats.level}になりました！');
      }
    }
  }

  // === フェーズ2: 高度化機能統合 ===

  /// ランダムイベント処理
  void _processRandomEvents() {
    // イベント発生確率チェック（20%程度）
    if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
      final allEvents = WaterMarginEvents.allEvents;
      if (allEvents.isNotEmpty) {
        // 最初のイベントを実行（実際はランダム選択）
        final event = allEvents.first;
        _triggerEvent(event);
      }
    }
  }

  /// イベントを発動
  void _triggerEvent(GameEvent event) {
    // イベントログに記録
    _addEventLog('${event.title}: ${event.description}');

    // 最初の選択肢の効果を適用（実際はプレイヤーが選択）
    if (event.choices.isNotEmpty) {
      final choice = event.choices.first;

      for (final effect in choice.effects) {
        switch (effect.type) {
          case EventEffectType.goldChange:
            _gameState = _gameState.copyWith(
              playerGold: (_gameState.playerGold + effect.value).clamp(0, 999999),
            );
            _addEventLog('資金が${effect.value > 0 ? '+' : ''}${effect.value}両変動');
            break;
          case EventEffectType.troopsChange:
            if (effect.targetId != null) {
              final updatedProvinces = _gameState.provinces.map((province) {
                if (province.id == effect.targetId || effect.targetId == 'all') {
                  return province.copyWith(
                    currentTroops: (province.currentTroops + effect.value).clamp(0, 99999),
                  );
                }
                return province;
              }).toList();

              _gameState = _gameState.copyWith(provinces: updatedProvinces);
              _addEventLog('兵力が${effect.value > 0 ? '+' : ''}${effect.value}増減');
            }
            break;
          case EventEffectType.heroRecruitment:
            _addEventLog('英雄登用の機会');
            break;
          case EventEffectType.provinceControl:
            _addEventLog('州の支配権に変化');
            break;
          case EventEffectType.loyaltyChange:
            _addEventLog('民心が変動');
            break;
          case EventEffectType.relationshipChange:
            _addEventLog('関係値が変動');
            break;
        }
      }
    }
  }

  /// イベントログに追加
  void _addEventLog(String message) {
    _eventLog.insert(0, 'ターン${_gameState.currentTurn}: $message');
    // 最大20件まで保持
    if (_eventLog.length > 20) {
      _eventLog = _eventLog.take(20).toList();
    }
  }

  /// AI行動の高度化処理
  void _processAdvancedAI() {
    for (final faction in [Faction.imperial, Faction.warlord]) {
      final result = AdvancedAISystem.decideAction(_gameState, faction);

      // AI行動を実行
      switch (result.chosenAction.type) {
        case AIActionType.attack:
          _executeAIAttack(result.chosenAction);
          break;
        case AIActionType.develop:
          _executeAIDevelopment(result.chosenAction);
          break;
        case AIActionType.recruit:
          _executeAIRecruitment(result.chosenAction);
          break;
        case AIActionType.diplomacy:
          // 外交行動（簡易実装）
          break;
        case AIActionType.fortify:
          // 要塞化行動（簡易実装）
          break;
        case AIActionType.wait:
          // 待機行動（何もしない）
          break;
      }
    }
  }

  /// AI攻撃を実行
  void _executeAIAttack(AIAction action) {
    final source = _gameState.getProvinceById(action.sourceProvinceId);
    final target = _gameState.getProvinceById(action.targetProvinceId ?? '');

    if (source != null &&
        target != null &&
        source.controller != target.controller &&
        source.adjacentProvinceIds.contains(target.id)) {
      // 簡易AI戦闘
      final battleResult = _calculateBattle(source, target);
      if (battleResult.attackerWins) {
        final updatedProvinces = _gameState.provinces.map((p) {
          if (p.id == target.id) {
            return p.copyWith(controller: source.controller);
          }
          return p;
        }).toList();

        _gameState = _gameState.copyWith(provinces: updatedProvinces);
        _addEventLog('${source.controller.name}が${target.name}を占領');
      }
    }
  }

  /// AI開発を実行
  void _executeAIDevelopment(AIAction action) {
    final province = _gameState.getProvinceById(action.sourceProvinceId);
    if (province != null && action.developmentType != null) {
      final updatedProvinces = _gameState.provinces.map((p) {
        if (p.id == province.id) {
          var newState = p.state;
          switch (action.developmentType!) {
            case DevelopmentType.agriculture:
              newState = newState.copyWith(
                agriculture: (newState.agriculture + 5).clamp(0, 100),
              );
              break;
            case DevelopmentType.commerce:
              newState = newState.copyWith(
                commerce: (newState.commerce + 5).clamp(0, 100),
              );
              break;
            case DevelopmentType.military:
              return p.copyWith(
                currentTroops: p.currentTroops + 500,
              );
            case DevelopmentType.security:
              newState = newState.copyWith(
                security: (newState.security + 5).clamp(0, 100),
              );
              break;
          }
          return p.copyWith(state: newState);
        }
        return p;
      }).toList();

      _gameState = _gameState.copyWith(provinces: updatedProvinces);
    }
  }

  /// AI英雄登用を実行
  void _executeAIRecruitment(AIAction action) {
    // 簡易AI英雄登用（未登用の英雄をランダムに登用）
    final availableHeroes = _gameState.heroes.where((h) => !h.isRecruited && h.faction != Faction.liangshan).toList();

    if (availableHeroes.isNotEmpty) {
      final hero = availableHeroes.first;
      final recruitedHero = hero.copyWith(isRecruited: true);

      final updatedHeroes = _gameState.heroes.map((h) => h.id == hero.id ? recruitedHero : h).toList();

      _gameState = _gameState.copyWith(heroes: updatedHeroes);
      _addEventLog('${hero.faction.name}が${hero.name}を登用');
    }
  }

  // === フェーズ3: プレイヤー内政・開発機能 ===

  /// プレイヤーが州を開発
  bool developProvince(String provinceId, DevelopmentType type, {String? assignedHeroId}) {
    final province = _gameState.getProvinceById(provinceId);
    if (province?.controller != Faction.liangshan) return false;

    // 開発コスト
    const developmentCost = 200;
    if (_gameState.playerGold < developmentCost) return false;

    final updatedProvinces = _gameState.provinces.map((p) {
      if (p.id == provinceId) {
        var newState = p.state;
        switch (type) {
          case DevelopmentType.agriculture:
            newState = newState.copyWith(
              agriculture: (newState.agriculture + 10).clamp(0, 100),
            );
            break;
          case DevelopmentType.commerce:
            newState = newState.copyWith(
              commerce: (newState.commerce + 10).clamp(0, 100),
            );
            break;
          case DevelopmentType.military:
            return p.copyWith(
              currentTroops: p.currentTroops + 1000,
            );
          case DevelopmentType.security:
            newState = newState.copyWith(
              security: (newState.security + 10).clamp(0, 100),
            );
            break;
        }
        return p.copyWith(state: newState);
      }
      return p;
    }).toList();

    _gameState = _gameState.copyWith(
      provinces: updatedProvinces,
      playerGold: _gameState.playerGold - developmentCost,
    );

    // 担当英雄に内政経験値付与
    if (assignedHeroId != null) {
      _awardAdministrationExperience(assignedHeroId, 30);
    }

    _addEventLog('${province!.name}の${_developmentTypeName(type)}を実施');
    notifyListeners();
    return true;
  }

  /// 開発タイプの日本語名
  String _developmentTypeName(DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return '農業開発';
      case DevelopmentType.commerce:
        return '商業開発';
      case DevelopmentType.military:
        return '軍備強化';
      case DevelopmentType.security:
        return '治安改善';
    }
  }

  /// 登用可能な英雄を取得
  List<Hero> getRecruitableHeroes() {
    return _gameState.heroes
        .where((hero) =>
                !hero.isRecruited &&
                hero.faction != Faction.imperial && // 朝廷軍は登用不可
                hero.faction != Faction.liangshan // 既に梁山泊所属は除外
            )
        .toList();
  }

  /// 英雄を登用
  bool recruitHero(String heroId) {
    final hero = _gameState.heroes.firstWhere(
      (h) => h.id == heroId,
      orElse: () => throw ArgumentError('Hero not found: $heroId'),
    );

    // 既に登用済みまたは登用不可チェック
    if (hero.isRecruited || hero.faction == Faction.imperial || hero.faction == Faction.liangshan) {
      return false;
    }

    // 登用費用計算
    final cost = _calculateRecruitmentCost(hero);
    if (_gameState.playerGold < cost) {
      return false;
    }

    // 英雄を更新
    final updatedHeroes = _gameState.heroes.map((h) {
      if (h.id == heroId) {
        return h.copyWith(
          isRecruited: true,
          faction: Faction.liangshan,
        );
      }
      return h;
    }).toList();

    // ゲーム状態更新
    _gameState = _gameState.copyWith(
      heroes: updatedHeroes,
      playerGold: _gameState.playerGold - cost,
    );

    // 拡張英雄データ初期化
    _initializeAdvancedHero(heroId);

    _addEventLog('${hero.nickname}（${hero.name}）が仲間になりました！');
    notifyListeners();
    return true;
  }

  /// 登用費用を計算
  int _calculateRecruitmentCost(Hero hero) {
    final totalStats = hero.stats.force + hero.stats.intelligence + hero.stats.charisma + hero.stats.leadership;
    return (totalStats * 3).round();
  }

  /// 攻撃可能な州を取得
  List<Province> getAttackableProvinces(String fromProvinceId) {
    final fromProvince = _gameState.provinces.firstWhere(
      (p) => p.id == fromProvinceId,
      orElse: () => throw ArgumentError('Province not found: $fromProvinceId'),
    );

    // 隣接する州で、プレイヤーが支配していない州を返す
    return _gameState.provinces
        .where((province) =>
            fromProvince.adjacentProvinceIds.contains(province.id) && province.controller != Faction.liangshan)
        .toList();
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
