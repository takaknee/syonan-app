/// 改良されたAI思考システム
/// フェーズ2: より賢いAI行動、状況に応じた戦略
library;

import '../models/water_margin_strategy_game.dart' hide Hero;
import '../models/water_margin_strategy_game.dart';

/// AIの性格タイプ
enum AIPersonality {
  aggressive, // 攻撃的
  defensive, // 守備的
  balanced, // バランス型
  opportunistic, // 機会主義
  economic, // 経済重視
}

/// AI行動の種類
enum AIActionType {
  attack, // 攻撃
  develop, // 開発
  recruit, // 徴兵
  diplomacy, // 外交
  fortify, // 要塞化
  wait, // 待機
}

/// AI行動計画
class AIAction {
  const AIAction({
    required this.type,
    required this.priority,
    required this.sourceProvinceId,
    this.targetProvinceId,
    this.developmentType,
  });

  final AIActionType type;
  final int priority; // 1-100の優先度
  final String sourceProvinceId;
  final String? targetProvinceId;
  final DevelopmentType? developmentType;
}

/// AI思考結果
class AIThinkingResult {
  const AIThinkingResult({
    required this.chosenAction,
    required this.reasoning,
    required this.allActions,
  });

  final AIAction chosenAction;
  final String reasoning; // AI思考の理由
  final List<AIAction> allActions; // 検討した全行動
}

/// 勢力AIの設定
class FactionAI {
  const FactionAI({
    required this.faction,
    required this.personality,
    required this.aggressiveness,
    required this.economicFocus,
    required this.militaryFocus,
  });

  final Faction faction;
  final AIPersonality personality;
  final double aggressiveness; // 0.0-1.0
  final double economicFocus; // 0.0-1.0
  final double militaryFocus; // 0.0-1.0
}

/// 改良されたAI思考システム
class AdvancedAISystem {
  /// 各勢力のAI設定
  static const Map<Faction, FactionAI> factionAIs = {
    Faction.imperial: FactionAI(
      faction: Faction.imperial,
      personality: AIPersonality.aggressive,
      aggressiveness: 0.8,
      economicFocus: 0.7,
      militaryFocus: 0.9,
    ),
    Faction.warlord: FactionAI(
      faction: Faction.warlord,
      personality: AIPersonality.opportunistic,
      aggressiveness: 0.6,
      economicFocus: 0.8,
      militaryFocus: 0.7,
    ),
    Faction.bandit: FactionAI(
      faction: Faction.bandit,
      personality: AIPersonality.aggressive,
      aggressiveness: 0.9,
      economicFocus: 0.3,
      militaryFocus: 0.8,
    ),
    Faction.neutral: FactionAI(
      faction: Faction.neutral,
      personality: AIPersonality.defensive,
      aggressiveness: 0.2,
      economicFocus: 0.9,
      militaryFocus: 0.4,
    ),
  };

  /// AI行動を決定
  static AIThinkingResult decideAction(
    WaterMarginGameState gameState,
    Faction faction,
  ) {
    final ai = factionAIs[faction];
    if (ai == null) {
      return _createWaitAction('AI設定が見つかりません');
    }

    // 1. 現在の状況分析
    final situation = _analyzeSituation(gameState, faction);

    // 2. 可能な行動を列挙
    final possibleActions = _generatePossibleActions(gameState, faction, ai);

    // 3. 各行動を評価
    final evaluatedActions = possibleActions
        .map((action) => _evaluateAction(action, situation, ai))
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    // 4. 最適行動を選択
    if (evaluatedActions.isEmpty) {
      return _createWaitAction('実行可能な行動がありません');
    }

    final chosenAction = evaluatedActions.first;
    final reasoning = _generateReasoning(chosenAction, situation, ai);

    return AIThinkingResult(
      chosenAction: chosenAction,
      reasoning: reasoning,
      allActions: evaluatedActions,
    );
  }

  /// 状況分析
  static SituationAnalysis _analyzeSituation(
    WaterMarginGameState gameState,
    Faction faction,
  ) {
    final ownProvinces =
        gameState.provinces.where((p) => p.controller == faction).toList();

    final enemyProvinces = gameState.provinces
        .where((p) => p.controller == Faction.liangshan)
        .toList();

    final totalTroops = ownProvinces.fold(0, (sum, p) => sum + p.currentTroops);

    final averageLoyalty = ownProvinces.isNotEmpty
        ? ownProvinces.fold(0, (sum, p) => sum + p.state.loyalty) /
            ownProvinces.length
        : 0.0;

    final threatLevel = _calculateThreatLevel(gameState, faction);
    final economicStrength = _calculateEconomicStrength(ownProvinces);
    final militaryStrength = _calculateMilitaryStrength(ownProvinces);

    return SituationAnalysis(
      ownProvinceCount: ownProvinces.length,
      enemyProvinceCount: enemyProvinces.length,
      totalTroops: totalTroops,
      averageLoyalty: averageLoyalty,
      threatLevel: threatLevel,
      economicStrength: economicStrength,
      militaryStrength: militaryStrength,
      isUnderPressure: threatLevel > 0.7,
      canExpand: threatLevel < 0.4 && militaryStrength > 0.6,
    );
  }

  /// 脅威レベル計算
  static double _calculateThreatLevel(
      WaterMarginGameState gameState, Faction faction) {
    final ownProvinces =
        gameState.provinces.where((p) => p.controller == faction).toList();

    double threatLevel = 0.0;

    for (final province in ownProvinces) {
      for (final adjacentId in province.adjacentProvinceIds) {
        final adjacent = gameState.getProvinceById(adjacentId);
        if (adjacent != null && adjacent.controller == Faction.liangshan) {
          double provinceThreat =
              adjacent.currentTroops / (province.currentTroops + 1);
          threatLevel += provinceThreat;
        }
      }
    }

    return (threatLevel / ownProvinces.length).clamp(0.0, 1.0);
  }

  /// 経済力計算
  static double _calculateEconomicStrength(List<Province> provinces) {
    if (provinces.isEmpty) return 0.0;

    final totalIncome = provinces.fold(0, (sum, p) => sum + p.state.taxIncome);
    final averageCommerce =
        provinces.fold(0, (sum, p) => sum + p.state.commerce) /
            provinces.length;

    return ((totalIncome / 100) + (averageCommerce / 100)).clamp(0.0, 1.0);
  }

  /// 軍事力計算
  static double _calculateMilitaryStrength(List<Province> provinces) {
    if (provinces.isEmpty) return 0.0;

    final totalTroops = provinces.fold(0, (sum, p) => sum + p.currentTroops);
    final averageMilitary =
        provinces.fold(0, (sum, p) => sum + p.state.military) /
            provinces.length;

    return ((totalTroops / 10000) + (averageMilitary / 100)).clamp(0.0, 1.0);
  }

  /// 可能な行動を生成
  static List<AIAction> _generatePossibleActions(
    WaterMarginGameState gameState,
    Faction faction,
    FactionAI ai,
  ) {
    final actions = <AIAction>[];
    final ownProvinces =
        gameState.provinces.where((p) => p.controller == faction).toList();

    for (final province in ownProvinces) {
      // 攻撃行動
      for (final adjacentId in province.adjacentProvinceIds) {
        final target = gameState.getProvinceById(adjacentId);
        if (target != null &&
            target.controller != faction &&
            province.currentTroops > 1000) {
          actions.add(AIAction(
            type: AIActionType.attack,
            priority: 0, // 後で評価
            sourceProvinceId: province.id,
            targetProvinceId: target.id,
          ));
        }
      }

      // 開発行動
      if (province.state.agriculture < 90) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: 0,
          sourceProvinceId: province.id,
          developmentType: DevelopmentType.agriculture,
        ));
      }
      if (province.state.commerce < 90) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: 0,
          sourceProvinceId: province.id,
          developmentType: DevelopmentType.commerce,
        ));
      }
      if (province.state.military < 90) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: 0,
          sourceProvinceId: province.id,
          developmentType: DevelopmentType.military,
        ));
      }
      if (province.state.security < 90) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: 0,
          sourceProvinceId: province.id,
          developmentType: DevelopmentType.security,
        ));
      }

      // 要塞化行動
      if (province.state.military < 80) {
        actions.add(AIAction(
          type: AIActionType.fortify,
          priority: 0,
          sourceProvinceId: province.id,
        ));
      }
    }

    return actions;
  }

  /// 行動を評価
  static AIAction _evaluateAction(
    AIAction action,
    SituationAnalysis situation,
    FactionAI ai,
  ) {
    int priority = 0;

    switch (action.type) {
      case AIActionType.attack:
        priority = _evaluateAttackAction(action, situation, ai);
        break;
      case AIActionType.develop:
        priority = _evaluateDevelopAction(action, situation, ai);
        break;
      case AIActionType.fortify:
        priority = _evaluateFortifyAction(action, situation, ai);
        break;
      case AIActionType.recruit:
        priority = 30; // 基本優先度
        break;
      case AIActionType.diplomacy:
        priority = 20;
        break;
      case AIActionType.wait:
        priority = 10;
        break;
    }

    return AIAction(
      type: action.type,
      priority: priority,
      sourceProvinceId: action.sourceProvinceId,
      targetProvinceId: action.targetProvinceId,
      developmentType: action.developmentType,
    );
  }

  /// 攻撃行動の評価
  static int _evaluateAttackAction(
    AIAction action,
    SituationAnalysis situation,
    FactionAI ai,
  ) {
    int basePriority = 50;

    // 攻撃性による修正
    basePriority = (basePriority * (1 + ai.aggressiveness)).round();

    // 状況による修正
    if (situation.isUnderPressure) {
      basePriority = (basePriority * 0.5).round(); // 劣勢時は攻撃を控える
    } else if (situation.canExpand) {
      basePriority = (basePriority * 1.5).round(); // 拡張可能時は積極的
    }

    // 軍事力による修正
    basePriority = (basePriority * situation.militaryStrength).round();

    return basePriority.clamp(0, 100);
  }

  /// 開発行動の評価
  static int _evaluateDevelopAction(
    AIAction action,
    SituationAnalysis situation,
    FactionAI ai,
  ) {
    int basePriority = 40;

    switch (action.developmentType) {
      case DevelopmentType.agriculture:
      case DevelopmentType.commerce:
        basePriority = (basePriority * ai.economicFocus).round();
        break;
      case DevelopmentType.military:
        basePriority = (basePriority * ai.militaryFocus).round();
        break;
      case DevelopmentType.security:
        if (situation.averageLoyalty < 50) {
          basePriority = (basePriority * 1.5).round();
        }
        break;
      default:
        break;
    }

    // 脅威下では経済開発を後回し
    if (situation.isUnderPressure &&
        (action.developmentType == DevelopmentType.agriculture ||
            action.developmentType == DevelopmentType.commerce)) {
      basePriority = (basePriority * 0.7).round();
    }

    return basePriority.clamp(0, 100);
  }

  /// 要塞化行動の評価
  static int _evaluateFortifyAction(
    AIAction action,
    SituationAnalysis situation,
    FactionAI ai,
  ) {
    int basePriority = 35;

    // 守備的AIは要塞化を重視
    if (ai.personality == AIPersonality.defensive) {
      basePriority = (basePriority * 1.3).round();
    }

    // 脅威下では要塞化を優先
    if (situation.isUnderPressure) {
      basePriority = (basePriority * 1.5).round();
    }

    return basePriority.clamp(0, 100);
  }

  /// 推論理由を生成
  static String _generateReasoning(
    AIAction action,
    SituationAnalysis situation,
    FactionAI ai,
  ) {
    switch (action.type) {
      case AIActionType.attack:
        if (situation.canExpand) {
          return '軍事的優位を活かして領土拡張を図る';
        } else {
          return '先制攻撃で敵の勢力拡大を阻止する';
        }
      case AIActionType.develop:
        switch (action.developmentType) {
          case DevelopmentType.agriculture:
            return '食料生産を強化して持久戦に備える';
          case DevelopmentType.commerce:
            return '商業発展で経済基盤を強化する';
          case DevelopmentType.military:
            return '軍事力強化で防御態勢を整える';
          case DevelopmentType.security:
            return '治安改善で民心を安定させる';
          default:
            return '内政充実で国力向上を図る';
        }
      case AIActionType.fortify:
        return '要塞化で敵の攻撃に備える';
      case AIActionType.wait:
        return '現在は様子見が最適と判断';
      default:
        return '戦略的判断による行動';
    }
  }

  /// 待機行動を作成
  static AIThinkingResult _createWaitAction(String reason) {
    return AIThinkingResult(
      chosenAction: const AIAction(
        type: AIActionType.wait,
        priority: 0,
        sourceProvinceId: '',
      ),
      reasoning: reason,
      allActions: [],
    );
  }
}

/// 状況分析結果
class SituationAnalysis {
  const SituationAnalysis({
    required this.ownProvinceCount,
    required this.enemyProvinceCount,
    required this.totalTroops,
    required this.averageLoyalty,
    required this.threatLevel,
    required this.economicStrength,
    required this.militaryStrength,
    required this.isUnderPressure,
    required this.canExpand,
  });

  final int ownProvinceCount;
  final int enemyProvinceCount;
  final int totalTroops;
  final double averageLoyalty;
  final double threatLevel; // 0.0-1.0
  final double economicStrength; // 0.0-1.0
  final double militaryStrength; // 0.0-1.0
  final bool isUnderPressure;
  final bool canExpand;
}
