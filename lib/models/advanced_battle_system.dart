/// 改良された戦闘システム
/// フェーズ2: 一騎討ち、水戦、攻城戦など多様な戦闘
library;

import '../models/water_margin_strategy_game.dart' as game show Hero;
import '../models/water_margin_strategy_game.dart' hide Hero;

/// 戦闘の種類
enum BattleType {
  fieldBattle, // 野戦
  siegeBattle, // 攻城戦
  navalBattle, // 水戦
  duel, // 一騎討ち
  ambush, // 奇襲
}

/// 戦闘の地形効果
enum BattleTerrain {
  plains, // 平野
  mountains, // 山地
  forest, // 森林
  river, // 河川
  fortress, // 要塞
  marsh, // 湿地
}

/// 戦闘参加者
class BattleParticipant {
  const BattleParticipant({
    required this.faction,
    required this.troops,
    required this.heroes,
    required this.province,
  });

  final Faction faction;
  final int troops;
  final List<game.Hero> heroes;
  final Province province;

  /// 総戦闘力を計算
  int get totalCombatPower {
    int heroBonus = heroes.fold(0, (sum, hero) => sum + hero.stats.combatPower);
    return troops + (heroBonus * 10); // 英雄1人 = 兵力10人相当
  }

  /// 統率力ボーナス
  int get leadershipBonus {
    if (heroes.isEmpty) return 0;
    return heroes
        .map((h) => h.stats.leadership)
        .reduce((a, b) => a > b ? a : b);
  }

  /// 知力ボーナス（策略用）
  int get intelligenceBonus {
    if (heroes.isEmpty) return 0;
    return heroes
        .map((h) => h.stats.intelligence)
        .reduce((a, b) => a > b ? a : b);
  }
}

/// 戦闘結果
class AdvancedBattleResult {
  const AdvancedBattleResult({
    required this.winner,
    required this.battleType,
    required this.attackerLosses,
    required this.defenderLosses,
    required this.heroResults,
    required this.specialEvents,
    required this.territoryConquered,
    this.duelWinner,
  });

  final Faction winner;
  final BattleType battleType;
  final int attackerLosses;
  final int defenderLosses;
  final List<HeroBattleResult> heroResults;
  final List<String> specialEvents;
  final bool territoryConquered;
  final game.Hero? duelWinner; // 一騎討ちの勝者

  bool get attackerWins => winner == Faction.liangshan;
}

/// 英雄の戦闘結果
class HeroBattleResult {
  const HeroBattleResult({
    required this.hero,
    required this.performance,
    required this.experienceGained,
    this.isInjured = false,
    this.specialAchievement,
  });

  final game.Hero hero;
  final HeroPerformance performance;
  final int experienceGained;
  final bool isInjured;
  final String? specialAchievement;
}

/// 英雄の戦闘での活躍度
enum HeroPerformance {
  excellent, // 大活躍
  good, // 活躍
  average, // 普通
  poor, // 不振
}

/// 高度な戦闘システム
class AdvancedBattleSystem {
  /// メイン戦闘処理
  static AdvancedBattleResult calculateBattle({
    required BattleParticipant attacker,
    required BattleParticipant defender,
    required BattleType battleType,
    required BattleTerrain terrain,
  }) {
    // 1. 基本戦闘力計算
    int attackPower = _calculateAttackPower(attacker, battleType, terrain);
    int defensePower = _calculateDefensePower(defender, battleType, terrain);

    // 2. 特殊効果適用
    final modifiers = _applySpecialEffects(attacker, defender, terrain);
    attackPower = (attackPower * modifiers.attackModifier).round();
    defensePower = (defensePower * modifiers.defenseModifier).round();

    // 3. 戦闘結果判定
    final winner =
        attackPower > defensePower ? attacker.faction : defender.faction;
    final attackerWins = winner == attacker.faction;

    // 4. 損失計算
    final losses =
        _calculateLosses(attacker, defender, attackerWins, battleType);

    // 5. 英雄の活躍計算
    final heroResults = _calculateHeroResults(
      attacker.heroes + defender.heroes,
      attackerWins,
      battleType,
    );

    // 6. 特殊イベント
    final specialEvents = _generateSpecialEvents(
      attacker,
      defender,
      battleType,
      terrain,
    );

    // 7. 一騎討ち処理
    game.Hero? duelWinner;
    if (battleType == BattleType.duel &&
        attacker.heroes.isNotEmpty &&
        defender.heroes.isNotEmpty) {
      duelWinner = _processDuel(attacker.heroes.first, defender.heroes.first);
    }

    return AdvancedBattleResult(
      winner: winner,
      battleType: battleType,
      attackerLosses: losses.attackerLosses,
      defenderLosses: losses.defenderLosses,
      heroResults: heroResults,
      specialEvents: specialEvents,
      territoryConquered: attackerWins,
      duelWinner: duelWinner,
    );
  }

  /// 攻撃力計算
  static int _calculateAttackPower(
    BattleParticipant attacker,
    BattleType battleType,
    BattleTerrain terrain,
  ) {
    int basePower = attacker.totalCombatPower;

    // 戦闘タイプによる修正
    switch (battleType) {
      case BattleType.fieldBattle:
        basePower = (basePower * 1.0).round();
        break;
      case BattleType.siegeBattle:
        basePower = (basePower * 0.8).round(); // 攻城戦は攻撃側不利
        break;
      case BattleType.navalBattle:
        basePower = (basePower * 0.9).round();
        break;
      case BattleType.duel:
        basePower = attacker.heroes.isNotEmpty
            ? attacker.heroes.first.stats.combatPower * 100
            : basePower;
        break;
      case BattleType.ambush:
        basePower = (basePower * 1.3).round(); // 奇襲は攻撃側有利
        break;
    }

    // 地形による修正
    switch (terrain) {
      case BattleTerrain.plains:
        basePower = (basePower * 1.1).round(); // 平野は攻撃側有利
        break;
      case BattleTerrain.mountains:
        basePower = (basePower * 0.8).round();
        break;
      case BattleTerrain.forest:
        basePower = (basePower * 0.9).round();
        break;
      case BattleTerrain.river:
        if (battleType == BattleType.navalBattle) {
          basePower = (basePower * 1.2).round();
        } else {
          basePower = (basePower * 0.7).round();
        }
        break;
      case BattleTerrain.fortress:
        basePower = (basePower * 0.6).round(); // 要塞攻撃は困難
        break;
      case BattleTerrain.marsh:
        basePower = (basePower * 1.1).round(); // 梁山泊の地形効果
        break;
    }

    // 統率力ボーナス
    basePower += attacker.leadershipBonus * 5;

    return basePower;
  }

  /// 防御力計算
  static int _calculateDefensePower(
    BattleParticipant defender,
    BattleType battleType,
    BattleTerrain terrain,
  ) {
    int basePower = defender.totalCombatPower;

    // 戦闘タイプによる修正
    switch (battleType) {
      case BattleType.fieldBattle:
        basePower = (basePower * 1.0).round();
        break;
      case BattleType.siegeBattle:
        basePower = (basePower * 1.5).round(); // 攻城戦は防御側有利
        break;
      case BattleType.navalBattle:
        basePower = (basePower * 1.0).round();
        break;
      case BattleType.duel:
        basePower = defender.heroes.isNotEmpty
            ? defender.heroes.first.stats.combatPower * 100
            : basePower;
        break;
      case BattleType.ambush:
        basePower = (basePower * 0.7).round(); // 奇襲は防御側不利
        break;
    }

    // 地形による修正
    switch (terrain) {
      case BattleTerrain.plains:
        basePower = (basePower * 0.9).round();
        break;
      case BattleTerrain.mountains:
        basePower = (basePower * 1.3).round(); // 山地は防御側有利
        break;
      case BattleTerrain.forest:
        basePower = (basePower * 1.2).round();
        break;
      case BattleTerrain.river:
        basePower = (basePower * 1.1).round();
        break;
      case BattleTerrain.fortress:
        basePower = (basePower * 1.8).round(); // 要塞は防御側大幅有利
        break;
      case BattleTerrain.marsh:
        if (defender.faction == Faction.liangshan) {
          basePower = (basePower * 1.5).round(); // 梁山泊の地の利
        } else {
          basePower = (basePower * 0.8).round();
        }
        break;
    }

    // 統率力ボーナス
    basePower += defender.leadershipBonus * 5;

    return basePower;
  }

  /// 特殊効果の計算
  static BattleModifiers _applySpecialEffects(
    BattleParticipant attacker,
    BattleParticipant defender,
    BattleTerrain terrain,
  ) {
    double attackModifier = 1.0;
    double defenseModifier = 1.0;

    // 知力による策略効果
    int attackerIntelligence = attacker.intelligenceBonus;
    int defenderIntelligence = defender.intelligenceBonus;

    if (attackerIntelligence > defenderIntelligence + 20) {
      attackModifier += 0.2; // 策略成功
    } else if (defenderIntelligence > attackerIntelligence + 20) {
      defenseModifier += 0.2; // 策略看破
    }

    // 特殊な英雄の効果
    for (final hero in attacker.heroes) {
      if (hero.skill == HeroSkill.warrior && terrain == BattleTerrain.plains) {
        attackModifier += 0.1; // 武将は平野で力を発揮
      } else if (hero.skill == HeroSkill.strategist) {
        attackModifier += 0.05; // 軍師の策略効果
      }
    }

    for (final hero in defender.heroes) {
      if (hero.skill == HeroSkill.administrator &&
          terrain == BattleTerrain.fortress) {
        defenseModifier += 0.15; // 政治家は要塞防御で力を発揮
      }
    }

    return BattleModifiers(
      attackModifier: attackModifier,
      defenseModifier: defenseModifier,
    );
  }

  /// 損失計算
  static BattleLosses _calculateLosses(
    BattleParticipant attacker,
    BattleParticipant defender,
    bool attackerWins,
    BattleType battleType,
  ) {
    double attackerLossRate = attackerWins ? 0.2 : 0.5;
    double defenderLossRate = attackerWins ? 0.6 : 0.3;

    // 戦闘タイプによる損失率修正
    switch (battleType) {
      case BattleType.duel:
        attackerLossRate *= 0.1; // 一騎討ちは損失少ない
        defenderLossRate *= 0.1;
        break;
      case BattleType.siegeBattle:
        attackerLossRate *= 1.5; // 攻城戦は損失大
        defenderLossRate *= 1.2;
        break;
      case BattleType.ambush:
        if (attackerWins) {
          defenderLossRate *= 1.3; // 奇襲成功時は相手の損失大
        }
        break;
      default:
        break;
    }

    int attackerLosses = (attacker.troops * attackerLossRate).round();
    int defenderLosses = (defender.troops * defenderLossRate).round();

    return BattleLosses(
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
    );
  }

  /// 英雄の戦闘結果計算
  static List<HeroBattleResult> _calculateHeroResults(
    List<game.Hero> allHeroes,
    bool attackerWins,
    BattleType battleType,
  ) {
    return allHeroes.map((hero) {
      // 性能判定
      HeroPerformance performance = _calculateHeroPerformance(hero, battleType);

      // 経験値計算
      int experienceGained = _calculateExperienceGain(performance, battleType);

      // 負傷判定
      bool isInjured = _checkInjury(hero, performance);

      // 特殊な功績
      String? specialAchievement =
          _checkSpecialAchievement(hero, performance, battleType);

      return HeroBattleResult(
        hero: hero,
        performance: performance,
        experienceGained: experienceGained,
        isInjured: isInjured,
        specialAchievement: specialAchievement,
      );
    }).toList();
  }

  /// 英雄の性能判定
  static HeroPerformance _calculateHeroPerformance(
      game.Hero hero, BattleType battleType) {
    int relevantStat = 0;

    switch (battleType) {
      case BattleType.duel:
        relevantStat = hero.stats.force;
        break;
      case BattleType.siegeBattle:
        relevantStat = hero.stats.leadership;
        break;
      case BattleType.navalBattle:
        relevantStat = hero.stats.intelligence;
        break;
      default:
        relevantStat = hero.stats.combatPower;
        break;
    }

    // ランダム要素を加味
    int randomFactor =
        (DateTime.now().millisecondsSinceEpoch % 40) - 20; // -20 to +20
    int totalPerformance = relevantStat + randomFactor;

    if (totalPerformance >= 90) return HeroPerformance.excellent;
    if (totalPerformance >= 70) return HeroPerformance.good;
    if (totalPerformance >= 50) return HeroPerformance.average;
    return HeroPerformance.poor;
  }

  /// 経験値計算
  static int _calculateExperienceGain(
      HeroPerformance performance, BattleType battleType) {
    int baseExp = 0;

    switch (performance) {
      case HeroPerformance.excellent:
        baseExp = 50;
        break;
      case HeroPerformance.good:
        baseExp = 30;
        break;
      case HeroPerformance.average:
        baseExp = 20;
        break;
      case HeroPerformance.poor:
        baseExp = 10;
        break;
    }

    // 戦闘タイプによる修正
    switch (battleType) {
      case BattleType.duel:
        baseExp *= 2; // 一騎討ちは経験値2倍
        break;
      case BattleType.siegeBattle:
        baseExp = (baseExp * 1.5).round();
        break;
      default:
        break;
    }

    return baseExp;
  }

  /// 負傷判定
  static bool _checkInjury(game.Hero hero, HeroPerformance performance) {
    int injuryChance = 0;

    switch (performance) {
      case HeroPerformance.excellent:
        injuryChance = 5; // 5%
        break;
      case HeroPerformance.good:
        injuryChance = 10;
        break;
      case HeroPerformance.average:
        injuryChance = 15;
        break;
      case HeroPerformance.poor:
        injuryChance = 25;
        break;
    }

    int random = DateTime.now().millisecondsSinceEpoch % 100;
    return random < injuryChance;
  }

  /// 特殊功績判定
  static String? _checkSpecialAchievement(
    game.Hero hero,
    HeroPerformance performance,
    BattleType battleType,
  ) {
    if (performance != HeroPerformance.excellent) return null;

    switch (battleType) {
      case BattleType.duel:
        return '一騎討ちで見事な勝利を収めた';
      case BattleType.siegeBattle:
        return '攻城戦で一番乗りを果たした';
      case BattleType.navalBattle:
        return '水戦で見事な指揮を取った';
      default:
        if (hero.skill == HeroSkill.warrior) {
          return '戦場で鬼神のごとき活躍を見せた';
        } else if (hero.skill == HeroSkill.strategist) {
          return '見事な策略で勝利に導いた';
        }
        return '戦場で大活躍した';
    }
  }

  /// 特殊イベント生成
  static List<String> _generateSpecialEvents(
    BattleParticipant attacker,
    BattleParticipant defender,
    BattleType battleType,
    BattleTerrain terrain,
  ) {
    List<String> events = [];

    // 地形特殊イベント
    if (terrain == BattleTerrain.marsh &&
        defender.faction == Faction.liangshan) {
      events.add('梁山泊の水路を活用した巧妙な戦術');
    }

    if (battleType == BattleType.navalBattle) {
      events.add('水上での激しい船戦が繰り広げられた');
    }

    // 英雄特殊イベント
    final allHeroes = attacker.heroes + defender.heroes;
    for (final hero in allHeroes) {
      if (hero.name == '林冲' && battleType == BattleType.duel) {
        events.add('豹子頭林冲の槍技が炸裂');
      } else if (hero.name == '武松' && terrain == BattleTerrain.mountains) {
        events.add('行者武松が山地で真価を発揮');
      } else if (hero.name == '呉用' && battleType != BattleType.duel) {
        events.add('智多星呉用の策略が冴え渡る');
      }
    }

    return events;
  }

  /// 一騎討ち処理
  static game.Hero _processDuel(game.Hero hero1, game.Hero hero2) {
    int score1 = hero1.stats.force + hero1.stats.leadership;
    int score2 = hero2.stats.force + hero2.stats.leadership;

    // ランダム要素
    int random1 = DateTime.now().millisecondsSinceEpoch % 50;
    int random2 = (DateTime.now().millisecondsSinceEpoch + 1000) % 50;

    score1 += random1;
    score2 += random2;

    return score1 > score2 ? hero1 : hero2;
  }
}

/// 戦闘修正値
class BattleModifiers {
  const BattleModifiers({
    required this.attackModifier,
    required this.defenseModifier,
  });

  final double attackModifier;
  final double defenseModifier;
}

/// 戦闘損失
class BattleLosses {
  const BattleLosses({
    required this.attackerLosses,
    required this.defenderLosses,
  });

  final int attackerLosses;
  final int defenderLosses;
}
