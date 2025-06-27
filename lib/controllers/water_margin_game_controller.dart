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
import '../models/province_facility.dart';
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

    // 1. 施設建設を1ターン進める
    // _advanceAllFacilityConstruction(); // 施設建設システムは一時的にコメントアウト

    // 2. 施設効果を適用
    // _applyFacilityEffectsToProvinces(); // 施設建設システムは一時的にコメントアウト

    // 3. 収入計算
    final income = _calculateTurnIncome();

    // 4. 内政処理
    final updatedProvinces = _processProvincesDevelopment();

    // 5. AI行動
    _processAdvancedAI();

    // 6. イベント処理
    _processRandomEvents();

    // 7. 勝利条件チェック
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
        var provinceIncome = province.state.taxIncome;

        // 特殊効果による収入ボーナス
        if (province.specialFeature?.contains('商業収入') == true) {
          provinceIncome += (province.state.taxIncome * 0.3).round();
        }
        if (province.specialFeature?.contains('皇都') == true) {
          provinceIncome += (province.state.taxIncome * 0.5).round();
        }

        // 英雄による収入ボーナス
        final heroEffects = calculateProvinceHeroEffects(province.id);
        final incomeBonus = heroEffects['incomeBonus'] as int;
        provinceIncome += incomeBonus;

        totalIncome += provinceIncome;
      }
    }

    return totalIncome;
  }

  /// 州の発展処理
  List<Province> _processProvincesDevelopment() {
    return _gameState.provinces.map((province) {
      if (province.controller == Faction.liangshan) {
        // プレイヤー領土の自然発展
        var newState = province.state.copyWith(
          loyalty: (province.state.loyalty + 1).clamp(0, 100),
          security: (province.state.security + 1).clamp(0, 100),
        );

        // 州に配置された英雄のスキル効果を適用
        newState = _applyHeroSkillEffects(province, newState);

        return province.copyWith(state: newState);
      }
      return province;
    }).toList();
  }

  /// 英雄スキル効果を州に適用
  ProvinceState _applyHeroSkillEffects(Province province, ProvinceState baseState) {
    // 州に配置された英雄を取得
    final provinceHeroes =
        _gameState.heroes.where((hero) => hero.isRecruited && hero.currentProvinceId == province.id).toList();

    var enhancedState = baseState;

    for (final hero in provinceHeroes) {
      final advancedHero = _advancedHeroes[hero.id];
      if (advancedHero == null) continue;

      // 基本スキル効果
      switch (hero.skill) {
        case HeroSkill.administrator:
          // 政治家は内政ボーナス
          enhancedState = enhancedState.copyWith(
            agriculture: (enhancedState.agriculture + 2).clamp(0, 100),
            commerce: (enhancedState.commerce + 2).clamp(0, 100),
          );
          break;
        case HeroSkill.warrior:
          // 武将は軍事・治安ボーナス
          enhancedState = enhancedState.copyWith(
            military: (enhancedState.military + 2).clamp(0, 100),
            security: (enhancedState.security + 1).clamp(0, 100),
          );
          break;
        case HeroSkill.strategist:
          // 軍師は軍事・民心ボーナス
          enhancedState = enhancedState.copyWith(
            military: (enhancedState.military + 1).clamp(0, 100),
            loyalty: (enhancedState.loyalty + 1).clamp(0, 100),
          );
          break;
        case HeroSkill.diplomat:
          // 外交官は民心・治安ボーナス
          enhancedState = enhancedState.copyWith(
            loyalty: (enhancedState.loyalty + 2).clamp(0, 100),
            security: (enhancedState.security + 1).clamp(0, 100),
          );
          break;
        case HeroSkill.scout:
          // 斥候は治安・軍事ボーナス
          enhancedState = enhancedState.copyWith(
            security: (enhancedState.security + 2).clamp(0, 100),
            military: (enhancedState.military + 1).clamp(0, 100),
          );
          break;
      }

      // レベルボーナス（レベルが高いほど効果アップ）
      final levelBonus = (advancedHero.advancedStats.level - 1) ~/ 2; // 2レベルごとに+1
      if (levelBonus > 0) {
        switch (hero.skill) {
          case HeroSkill.administrator:
            enhancedState = enhancedState.copyWith(
              agriculture: (enhancedState.agriculture + levelBonus).clamp(0, 100),
              commerce: (enhancedState.commerce + levelBonus).clamp(0, 100),
            );
            break;
          case HeroSkill.warrior:
            enhancedState = enhancedState.copyWith(
              military: (enhancedState.military + levelBonus).clamp(0, 100),
            );
            break;
          case HeroSkill.strategist:
            enhancedState = enhancedState.copyWith(
              military: (enhancedState.military + levelBonus).clamp(0, 100),
              loyalty: (enhancedState.loyalty + levelBonus).clamp(0, 100),
            );
            break;
          case HeroSkill.diplomat:
            enhancedState = enhancedState.copyWith(
              loyalty: (enhancedState.loyalty + levelBonus).clamp(0, 100),
            );
            break;
          case HeroSkill.scout:
            enhancedState = enhancedState.copyWith(
              security: (enhancedState.security + levelBonus).clamp(0, 100),
            );
            break;
        }
      }
    }

    return enhancedState;
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
            currentTroops: source.currentTroops - battleResult.attackerLosses.round(),
          );
        }
        return p;
      }).toList();

      // 参加英雄に戦闘経験値を付与（勝利ボーナス）
      _awardCombatExperienceToProvinceHeroes(sourceProvinceId, 50);

      _gameState = _gameState.copyWith(provinces: updatedProvinces);
      _addEventLog('${source.name}が${target.name}を制圧しました！');
      return true;
    } else {
      // 敗北: 兵力減少のみ
      final updatedProvinces = _gameState.provinces.map((p) {
        if (p.id == sourceProvinceId) {
          return p.copyWith(
            currentTroops: source.currentTroops - battleResult.attackerLosses.round(),
          );
        } else if (p.id == targetProvinceId) {
          return p.copyWith(
            currentTroops: target.currentTroops - battleResult.defenderLosses.round(),
          );
        }
        return p;
      }).toList();

      // 参加英雄に戦闘経験値を付与（敗北でも経験は得る）
      _awardCombatExperienceToProvinceHeroes(sourceProvinceId, 20);

      _gameState = _gameState.copyWith(provinces: updatedProvinces);
      _addEventLog('${source.name}の攻撃は失敗しました...');
      return false;
    }
  }

  /// 戦闘計算（簡易版）
  BattleResult _calculateBattle(Province attacker, Province defender) {
    // 改良戦闘システムを使用
    final attackerParticipant = BattleParticipant(
      faction: attacker.controller,
      troops: attacker.currentTroops,
      heroes: _getEnhancedBattleHeroes(attacker.id),
      province: attacker,
    );

    final defenderParticipant = BattleParticipant(
      faction: defender.controller,
      troops: defender.currentTroops,
      heroes: _getEnhancedBattleHeroes(defender.id),
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
      attackerLosses: advancedResult.attackerLosses.round(),
      defenderLosses: advancedResult.defenderLosses.round(),
      territoryConquered: advancedResult.winner == attacker.controller,
    );
  }

  /// 州の戦闘に参加する英雄リストを取得（レベル・装備強化版）
  List<Hero> _getEnhancedBattleHeroes(String provinceId) {
    final baseHeroes =
        _gameState.heroes.where((hero) => hero.isRecruited && hero.currentProvinceId == provinceId).toList();

    // 拡張英雄データを反映した強化英雄リストを作成
    return baseHeroes.map((hero) {
      final advancedHero = _advancedHeroes[hero.id];
      if (advancedHero != null) {
        // レベルと装備効果を反映した能力値で英雄を強化
        final enhancedStats = _calculateEnhancedStats(hero, advancedHero);
        return hero.copyWith(stats: enhancedStats);
      }
      return hero;
    }).toList();
  }

  /// 英雄の拡張能力値を計算（レベル・装備効果込み）
  HeroStats _calculateEnhancedStats(Hero baseHero, AdvancedHero advancedHero) {
    final baseStats = baseHero.stats;
    final level = advancedHero.advancedStats.level;

    // レベルによる基本ボーナス（レベル1から＋2ずつ）
    final levelBonus = (level - 1) * 2;

    // 装備効果を取得（装備システムの totalBonus を使用）
    final equipmentStats = advancedHero.advancedStats.equipment?.totalBonus ??
        const HeroStats(
          force: 0,
          intelligence: 0,
          charisma: 0,
          leadership: 0,
          loyalty: 0,
        );

    // 最終能力値を計算（上限100）
    return HeroStats(
      force: (baseStats.force + levelBonus + equipmentStats.force).clamp(1, 100),
      intelligence: (baseStats.intelligence + levelBonus + equipmentStats.intelligence).clamp(1, 100),
      charisma: (baseStats.charisma + levelBonus + equipmentStats.charisma).clamp(1, 100),
      leadership: (baseStats.leadership + levelBonus + equipmentStats.leadership).clamp(1, 100),
      loyalty: (baseStats.loyalty + levelBonus + equipmentStats.loyalty).clamp(1, 100),
    );
  }

  /// 州の戦闘に参加する英雄リストを取得（旧版・互換性用）
  List<Hero> _getProvinceBattleHeroes(String provinceId) {
    return _getEnhancedBattleHeroes(provinceId);
  }

  /// 州の地形を取得
  BattleTerrain _getProvinceTerrain(Province province) {
    // 特殊地形の簡易判定
    if (province.specialFeature?.contains('山') == true) {
      return BattleTerrain.mountains;
    }
    if (province.specialFeature?.contains('河') == true) {
      return BattleTerrain.river;
    }
    if (province.specialFeature?.contains('要塞') == true) {
      return BattleTerrain.fortress;
    }
    if (province.specialFeature?.contains('森') == true) {
      return BattleTerrain.forest;
    }
    return BattleTerrain.plains; // デフォルトは平野
  }

  // === フェーズ3: 英雄レベルアップシステム ===

  /// 州の英雄たちに戦闘経験値を付与
  void _awardCombatExperienceToProvinceHeroes(String provinceId, int baseExperience) {
    final participatingHeroes = _getProvinceBattleHeroes(provinceId);

    for (final hero in participatingHeroes) {
      final advancedHero = _advancedHeroes[hero.id];
      if (advancedHero != null) {
        // 英雄の戦闘力と技能に応じて経験値調整
        var experienceMultiplier = 1.0;

        // 武将は戦闘経験値ボーナス
        if (hero.skill == HeroSkill.warrior) {
          experienceMultiplier = 1.5;
        } else if (hero.skill == HeroSkill.strategist) {
          experienceMultiplier = 1.2; // 軍師も戦闘で少しボーナス
        }

        final experienceGained = (baseExperience * (hero.stats.combatPower / 100) * experienceMultiplier).round();

        final updatedAdvancedHero = advancedHero.gainExperience(
          ExperienceType.combat,
          experienceGained,
        );

        _advancedHeroes[hero.id] = updatedAdvancedHero;

        // レベルアップ通知
        if (updatedAdvancedHero.advancedStats.level > advancedHero.advancedStats.level) {
          _addEventLog('${hero.nickname}がレベル${updatedAdvancedHero.advancedStats.level}になりました！');
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

  // === 英雄配置・移動システム ===

  /// 英雄を州に配置
  bool assignHeroToProvince(String heroId, String provinceId) {
    final hero = _gameState.getHeroById(heroId);
    final province = _gameState.getProvinceById(provinceId);

    if (hero == null || province == null) return false;
    if (!hero.isRecruited) return false;
    if (province.controller != Faction.liangshan) return false;

    // 英雄を更新
    final updatedHeroes = _gameState.heroes.map((h) {
      if (h.id == heroId) {
        return h.copyWith(currentProvinceId: provinceId);
      }
      return h;
    }).toList();

    _gameState = _gameState.copyWith(heroes: updatedHeroes);
    _addEventLog('${hero.nickname}が${province.name}に配置されました');
    notifyListeners();
    return true;
  }

  /// 州に配置された英雄リストを取得
  List<Hero> getProvinceHeroes(String provinceId) {
    return _gameState.heroes.where((hero) => hero.isRecruited && hero.currentProvinceId == provinceId).toList();
  }

  /// 配置されていない英雄リストを取得
  List<Hero> getUnassignedHeroes() {
    return _gameState.heroes.where((hero) => hero.isRecruited && hero.currentProvinceId == null).toList();
  }

  /// 州の英雄による効果を計算
  Map<String, dynamic> calculateProvinceHeroEffects(String provinceId) {
    final heroes = getProvinceHeroes(provinceId);

    var combatBonus = 0;
    var administrationBonus = 0;
    var diplomacyBonus = 0;
    var incomeBonus = 0;
    var securityBonus = 0;

    for (final hero in heroes) {
      final advancedHero = _advancedHeroes[hero.id];
      if (advancedHero == null) continue;

      final level = advancedHero.advancedStats.level;
      final levelMultiplier = 1.0 + (level - 1) * 0.1; // レベル毎に10%増加

      switch (hero.skill) {
        case HeroSkill.warrior:
          combatBonus += (20 * levelMultiplier).round();
          securityBonus += (10 * levelMultiplier).round();
          break;
        case HeroSkill.strategist:
          combatBonus += (15 * levelMultiplier).round();
          administrationBonus += (15 * levelMultiplier).round();
          break;
        case HeroSkill.administrator:
          administrationBonus += (25 * levelMultiplier).round();
          incomeBonus += (15 * levelMultiplier).round();
          break;
        case HeroSkill.diplomat:
          diplomacyBonus += (20 * levelMultiplier).round();
          administrationBonus += (10 * levelMultiplier).round();
          break;
        case HeroSkill.scout:
          securityBonus += (20 * levelMultiplier).round();
          combatBonus += (10 * levelMultiplier).round();
          break;
      }
    }

    return {
      'combatBonus': combatBonus,
      'administrationBonus': administrationBonus,
      'diplomacyBonus': diplomacyBonus,
      'incomeBonus': incomeBonus,
      'securityBonus': securityBonus,
      'heroCount': heroes.length,
    };
  }

  // === 英雄訓練・成長システム ===

  /// 英雄を訓練して経験値を付与
  bool trainHero(String heroId, ExperienceType trainingType) {
    final hero = _gameState.getHeroById(heroId);
    if (hero == null || !hero.isRecruited) return false;

    // 訓練コスト
    const trainingCost = 100;
    if (_gameState.playerGold < trainingCost) return false;

    final advancedHero = _advancedHeroes[heroId];
    if (advancedHero == null) return false;

    // 訓練による経験値計算
    var baseExperience = 25;
    var experienceMultiplier = 1.0;

    // 英雄の適性による経験値ボーナス
    switch (trainingType) {
      case ExperienceType.combat:
        if (hero.skill == HeroSkill.warrior) experienceMultiplier = 1.5;
        if (hero.skill == HeroSkill.strategist) experienceMultiplier = 1.2;
        break;
      case ExperienceType.administration:
        if (hero.skill == HeroSkill.administrator) experienceMultiplier = 1.5;
        if (hero.skill == HeroSkill.strategist) experienceMultiplier = 1.2;
        break;
      case ExperienceType.diplomacy:
        if (hero.skill == HeroSkill.diplomat) experienceMultiplier = 1.5;
        if (hero.skill == HeroSkill.administrator) experienceMultiplier = 1.2;
        break;
      case ExperienceType.leadership:
        if (hero.skill == HeroSkill.strategist) experienceMultiplier = 1.5;
        if (hero.skill == HeroSkill.warrior) experienceMultiplier = 1.2;
        break;
    }

    final experienceGained = (baseExperience * experienceMultiplier).round();
    final updatedAdvancedHero = advancedHero.gainExperience(trainingType, experienceGained);
    _advancedHeroes[heroId] = updatedAdvancedHero;

    // 資金消費
    _gameState = _gameState.copyWith(
      playerGold: _gameState.playerGold - trainingCost,
    );

    // レベルアップ通知
    if (updatedAdvancedHero.advancedStats.level > advancedHero.advancedStats.level) {
      _addEventLog('${hero.nickname}がレベル${updatedAdvancedHero.advancedStats.level}になりました！');
    }

    _addEventLog('${hero.nickname}が${_getExperienceTypeName(trainingType)}訓練を行いました');
    notifyListeners();
    return true;
  }

  /// 英雄に装備を装着させる（古いバージョン）
  /// 英雄に経験値を付与（古いバージョン）
  void giveHeroExperience(String heroId, int amount, ExperienceType type) {
    final hero = _gameState.getHeroById(heroId);
    if (hero == null || !hero.isRecruited) return;

    final advancedHero = _advancedHeroes[heroId];
    if (advancedHero != null) {
      final newAdvancedHero = advancedHero.gainExperience(type, amount);
      _advancedHeroes[heroId] = newAdvancedHero;

      // レベルアップチェック
      if (newAdvancedHero.advancedStats.level > advancedHero.advancedStats.level) {
        _addEventLog('${hero.name}がレベル${newAdvancedHero.advancedStats.level}に成長しました！');
      }

      _addEventLog('${hero.name}が${_getExperienceTypeName(type)}経験値を$amount獲得しました');
      notifyListeners();
    }
  }

  /// 経験値タイプの日本語名を取得
  String _getExperienceTypeName(ExperienceType type) {
    switch (type) {
      case ExperienceType.combat:
        return '戦闘';
      case ExperienceType.administration:
        return '内政';
      case ExperienceType.diplomacy:
        return '外交';
      case ExperienceType.leadership:
        return '統率';
    }
  }

  /// スキルIDからHeroLevelSkillを取得
  HeroLevelSkill? _getSkillFromId(String skillId) {
    switch (skillId) {
      case 'advanced_tactics':
        return HeroLevelSkill.tactician;
      case 'leadership_enhancement':
        return HeroLevelSkill.inspiring;
      case 'berserker_rage':
        return HeroLevelSkill.berserker;
      case 'administration_expert':
        return HeroLevelSkill.administrator;
      default:
        return null;
    }
  }

  /// スキルIDからスキル名を取得
  String _getSkillName(String skillId) {
    switch (skillId) {
      case 'advanced_tactics':
        return '上級戦術';
      case 'leadership_enhancement':
        return '統率力強化';
      case 'berserker_rage':
        return '狂戦士の怒り';
      case 'administration_expert':
        return '内政エキスパート';
      default:
        return skillId;
    }
  }

  /// 装備アイテムデータを取得
  Map<String, dynamic>? _getEquipmentItem(String itemId) {
    switch (itemId) {
      case 'iron_sword':
        return {
          'id': 'iron_sword',
          'name': '鉄剣',
          'type': 'weapon',
          'effect': '武力+5',
        };
      case 'steel_sword':
        return {
          'id': 'steel_sword',
          'name': '鋼鉄剣',
          'type': 'weapon',
          'effect': '武力+10',
        };
      case 'leather_armor':
        return {
          'id': 'leather_armor',
          'name': '革鎧',
          'type': 'armor',
          'effect': '防御+3',
        };
      default:
        return null;
    }
  }

  /// 英雄に経験値を追加
  void addExperience(String heroId, int experience, ExperienceType type) {
    final hero = _gameState.getHeroById(heroId);
    if (hero == null || !hero.isRecruited) {
      _addEventLog('英雄が見つからないか、まだ仲間になっていません');
      return;
    }

    final currentAdvanced = _advancedHeroes[heroId] ??
        AdvancedHero(
          baseHero: hero,
          advancedStats: HeroAdvancedStats(
            baseStats: hero.stats,
            level: 1,
            experience: {
              ExperienceType.combat: 0,
              ExperienceType.administration: 0,
              ExperienceType.diplomacy: 0,
              ExperienceType.leadership: 0,
            },
            skills: {},
          ),
          specialMissions: [],
        );

    // 経験値を追加
    final newExperience = Map<ExperienceType, int>.from(currentAdvanced.advancedStats.experience);
    newExperience[type] = (newExperience[type] ?? 0) + experience;

    // 新しいレベルを計算
    final totalExp = newExperience.values.fold(0, (sum, exp) => sum + exp);
    final newLevel = HeroAdvancedStats.calculateLevel(totalExp);

    final newStats = HeroAdvancedStats(
      baseStats: currentAdvanced.advancedStats.baseStats,
      level: newLevel,
      experience: newExperience,
      skills: currentAdvanced.advancedStats.skills,
      equipment: currentAdvanced.advancedStats.equipment,
    );

    _advancedHeroes[heroId] = AdvancedHero(
      baseHero: currentAdvanced.baseHero,
      advancedStats: newStats,
      assignedProvince: currentAdvanced.assignedProvince,
      specialMissions: currentAdvanced.specialMissions,
    );

    _addEventLog('${hero.name}が${_getExperienceTypeName(type)}経験値 $experience を獲得しました');

    // レベルアップをチェック
    if (newLevel > currentAdvanced.advancedStats.level) {
      _addEventLog('${hero.name}がレベル $newLevel にレベルアップしました！');
    }

    notifyListeners();
  }

  /// 英雄スキル習得
  bool learnHeroSkill(String heroId, String skillId) {
    final hero = _gameState.getHeroById(heroId);
    if (hero == null || !hero.isRecruited) {
      _addEventLog('英雄が見つからないか、まだ仲間になっていません');
      return false;
    }

    final advancedHero = _advancedHeroes[heroId];
    if (advancedHero == null) {
      _addEventLog('${hero.name}はまだレベルアップしていません');
      return false;
    }

    // スキル習得の基本レベル要件をチェック
    final skillLevelRequirement = _getSkillLevelRequirement(skillId);
    if (advancedHero.advancedStats.level < skillLevelRequirement) {
      _addEventLog('${hero.name}はレベル$skillLevelRequirementに達していません（現在レベル${advancedHero.advancedStats.level}）');
      return false;
    }

    // スキルIDからHeroLevelSkillに変換
    final skill = _getSkillFromId(skillId);
    if (skill == null) {
      _addEventLog('無効なスキルです: $skillId');
      return false;
    }

    // 既に習得済みかチェック
    if (advancedHero.advancedStats.skills.contains(skill)) {
      _addEventLog('${hero.name}は既にそのスキルを習得しています');
      return false;
    }

    // スキル習得実行
    final newSkills = Set<HeroLevelSkill>.from(advancedHero.advancedStats.skills)..add(skill);
    final newStats = HeroAdvancedStats(
      baseStats: advancedHero.advancedStats.baseStats,
      level: advancedHero.advancedStats.level,
      experience: advancedHero.advancedStats.experience,
      skills: newSkills,
      equipment: advancedHero.advancedStats.equipment,
    );

    _advancedHeroes[heroId] = AdvancedHero(
      baseHero: advancedHero.baseHero,
      advancedStats: newStats,
      assignedProvince: advancedHero.assignedProvince,
      specialMissions: advancedHero.specialMissions,
    );

    _addEventLog('${hero.name}が新しいスキル「${_getSkillName(skillId)}」を習得しました！');
    notifyListeners();
    return true;
  }

  /// 英雄装備変更
  bool equipHeroItem(String heroId, String slot, String itemId) {
    final hero = _gameState.getHeroById(heroId);
    if (hero == null || !hero.isRecruited) {
      _addEventLog('英雄が見つからないか、まだ仲間になっていません');
      return false;
    }

    // 装備データを取得
    final item = _getEquipmentItem(itemId);
    if (item == null) {
      _addEventLog('装備アイテムが見つかりません');
      return false;
    }

    // 装備スロットの妥当性チェック
    if (!_isValidEquipmentSlot(slot, item['type'])) {
      _addEventLog('${item['name']}は$slotスロットに装備できません');
      return false;
    }

    var advancedHero = _advancedHeroes[heroId];
    if (advancedHero == null) {
      advancedHero = AdvancedHero(
        baseHero: hero,
        advancedStats: HeroAdvancedStats(
          baseStats: hero.stats,
          level: 1,
          experience: {
            ExperienceType.combat: 0,
            ExperienceType.administration: 0,
            ExperienceType.diplomacy: 0,
            ExperienceType.leadership: 0,
          },
          skills: {},
        ),
        specialMissions: [],
      );
      _advancedHeroes[heroId] = advancedHero;
    }

    // 装備変更実行
    _addEventLog('${hero.name}が${item['name']}を装備しました');
    notifyListeners();
    return true;
  }

  /// スキル習得に必要なレベルを取得
  int _getSkillLevelRequirement(String skillId) {
    switch (skillId) {
      case 'advanced_tactics':
        return 5;
      case 'leadership_enhancement':
        return 10;
      case 'berserker_rage':
        return 8;
      case 'administration_expert':
        return 6;
      default:
        return 3;
    }
  }

  /// 英雄のレベルアップ
  /// 装備スロットが有効かチェック
  bool _isValidEquipmentSlot(String slot, String? itemType) {
    switch (slot) {
      case 'weapon':
        return itemType == 'weapon';
      case 'armor':
        return itemType == 'armor';
      case 'accessory':
        return itemType == 'accessory';
      case 'horse':
        return itemType == 'horse';
      default:
        return false;
    }
  }

  // ========== 施設建設関連 ==========

  /// 施設建設を開始
  bool startFacilityConstruction(String provinceId, FacilityType facilityType) {
    final province = _gameState.provinces.firstWhere(
      (p) => p.id == provinceId,
      orElse: () => throw ArgumentError('Province not found: $provinceId'),
    );

    // プレイヤーが支配していない場合は建設不可
    if (province.controller != Faction.liangshan) {
      _addEventLog('$provinceId: プレイヤーが支配していない領土では建設できません');
      return false;
    }

    // 建設コストの確認
    final cost = _getFacilityConstructionCost(facilityType);
    if (_gameState.playerGold < cost) {
      _addEventLog('$provinceId: 建設資金が不足しています（必要: ${cost}G）');
      return false;
    }

    // 建設可能な施設かチェック
    if (!_canBuildFacility(province, facilityType)) {
      _addEventLog('$provinceId: この領土では${_getFacilityTypeName(facilityType)}を建設できません');
      return false;
    }

    // 建設開始
    _gameState = _gameState.copyWith(
      playerGold: _gameState.playerGold - cost,
    );

    // 施設情報を追加（即座に完成として扱う）
    final updatedProvinces = _gameState.provinces.map((p) {
      if (p.id == provinceId) {
        final currentFacilities = p.facilities ?? const ProvinceFacilities();
        // ここでは簡単のため、新しい施設リストを作成
        return p.copyWith(
          facilities: currentFacilities, // 実際の施設追加ロジックは省略
        );
      }
      return p;
    }).toList();

    _gameState = _gameState.copyWith(provinces: updatedProvinces);

    _addEventLog('$provinceId: ${_getFacilityTypeName(facilityType)}の建設を開始しました');
    notifyListeners();
    return true;
  }

  /// 施設建設コストを取得
  int _getFacilityConstructionCost(FacilityType facilityType) {
    switch (facilityType) {
      case FacilityType.market:
        return 300;
      case FacilityType.barracks:
        return 400;
      case FacilityType.fortress:
        return 600;
      case FacilityType.academy:
        return 500;
      case FacilityType.temple:
        return 350;
      case FacilityType.docks:
        return 450;
      case FacilityType.mine:
        return 300;
      case FacilityType.armory:
        return 350;
      case FacilityType.watchtower:
        return 250;
      case FacilityType.warehouse:
        return 200;
      case FacilityType.workshop:
        return 300;
      case FacilityType.library:
        return 400;
      case FacilityType.embassy:
        return 500;
      case FacilityType.spyNetwork:
        return 600;
    }
  }

  /// 施設建設可能かチェック
  bool _canBuildFacility(Province province, FacilityType facilityType) {
    final facilities = province.facilities;
    if (facilities == null) return true;

    // 特定の施設の建設条件をここで実装
    // 現在は簡単のため、すべて建設可能として扱う
    return true;
  }

  /// 施設タイプ名を取得
  String _getFacilityTypeName(FacilityType facilityType) {
    switch (facilityType) {
      case FacilityType.market:
        return '市場';
      case FacilityType.barracks:
        return '兵営';
      case FacilityType.fortress:
        return '要塞';
      case FacilityType.academy:
        return '学院';
      case FacilityType.temple:
        return '寺院';
      case FacilityType.docks:
        return '港';
      case FacilityType.mine:
        return '鉱山';
      case FacilityType.armory:
        return '武器庫';
      case FacilityType.watchtower:
        return '見張り台';
      case FacilityType.warehouse:
        return '倉庫';
      case FacilityType.workshop:
        return '工房';
      case FacilityType.library:
        return '図書館';
      case FacilityType.embassy:
        return '外交館';
      case FacilityType.spyNetwork:
        return '諜報網';
    }
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
