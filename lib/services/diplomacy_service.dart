/// 外交システムサービス
/// 外交行動の処理・条約管理・AI外交ロジック
library;

import '../models/diplomacy_system.dart';
import '../models/water_margin_strategy_game.dart';

/// 外交サービス
class DiplomacyService {
  /// 外交行動を実行
  static DiplomaticActionResult performDiplomaticAction({
    required DiplomaticSystem diplomacy,
    required Faction actor,
    required Faction target,
    required DiplomaticAction action,
    required int currentTurn,
    Map<String, dynamic>? parameters,
  }) {
    final relationship = diplomacy.getRelationship(actor, target);
    if (relationship == null) {
      return DiplomaticActionResult(
        success: false,
        message: '外交関係が見つかりません',
        updatedDiplomacy: diplomacy,
      );
    }

    switch (action) {
      case DiplomaticAction.proposePeace:
        return _proposePeace(diplomacy, relationship, currentTurn);

      case DiplomaticAction.proposeAlliance:
        return _proposeAlliance(diplomacy, relationship, currentTurn);

      case DiplomaticAction.proposeTrade:
        return _proposeTrade(diplomacy, relationship, currentTurn, parameters);

      case DiplomaticAction.demandTribute:
        return _demandTribute(diplomacy, relationship, currentTurn, parameters);

      case DiplomaticAction.declareWar:
        return _declareWar(diplomacy, relationship, currentTurn);

      case DiplomaticAction.exchangeInformation:
        return _exchangeInformation(diplomacy, relationship, currentTurn);

      case DiplomaticAction.requestSupport:
        return _requestSupport(diplomacy, relationship, currentTurn, parameters);
    }
  }

  /// 和平提案
  static DiplomaticActionResult _proposePeace(
    DiplomaticSystem diplomacy,
    DiplomaticRelationship relationship,
    int currentTurn,
  ) {
    if (relationship.relation == DiplomaticRelation.ally || relationship.relation == DiplomaticRelation.friendly) {
      return DiplomaticActionResult(
        success: false,
        message: '既に良好な関係です',
        updatedDiplomacy: diplomacy,
      );
    }

    // 和平提案の成功率計算
    final successChance = _calculatePeaceSuccessChance(relationship);
    final success = (DateTime.now().millisecondsSinceEpoch % 100) < successChance;

    if (success) {
      // 和平条約締結
      final peaceTreaty = Treaty(
        type: TreatyType.peace,
        signedTurn: currentTurn,
        duration: 10, // 10ターン有効
        conditions: const {'no_aggression': true},
        benefits: const {'relation_bonus': 20},
      );

      final updatedRelationship = relationship.adjustRelation(30, reason: '和平条約締結').copyWith(
        treaties: [...relationship.treaties, peaceTreaty],
        lastAction: DiplomaticAction.proposePeace,
      );

      return DiplomaticActionResult(
        success: true,
        message: '和平条約が締結されました',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
        treaty: peaceTreaty,
      );
    } else {
      final updatedRelationship = relationship.adjustRelation(-5, reason: '和平提案拒否');
      return DiplomaticActionResult(
        success: false,
        message: '和平提案は拒否されました',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
      );
    }
  }

  /// 同盟提案
  static DiplomaticActionResult _proposeAlliance(
    DiplomaticSystem diplomacy,
    DiplomaticRelationship relationship,
    int currentTurn,
  ) {
    if (relationship.relation == DiplomaticRelation.ally) {
      return DiplomaticActionResult(
        success: false,
        message: '既に同盟関係です',
        updatedDiplomacy: diplomacy,
      );
    }

    if (relationship.relationValue < 50) {
      return DiplomaticActionResult(
        success: false,
        message: '関係値が不足しています（必要: 50以上）',
        updatedDiplomacy: diplomacy,
      );
    }

    // 同盟成功率計算
    final successChance = _calculateAllianceSuccessChance(relationship);
    final success = (DateTime.now().millisecondsSinceEpoch % 100) < successChance;

    if (success) {
      // 同盟条約締結
      final allianceTreaty = Treaty(
        type: TreatyType.alliance,
        signedTurn: currentTurn,
        duration: -1, // 永続
        conditions: const {
          'mutual_defense': true,
          'shared_intelligence': true,
        },
        benefits: const {
          'military_support': true,
          'trade_bonus': 1.2,
        },
      );

      final updatedRelationship = relationship.adjustRelation(40, reason: '同盟条約締結').copyWith(
        treaties: [...relationship.treaties, allianceTreaty],
        lastAction: DiplomaticAction.proposeAlliance,
      );

      return DiplomaticActionResult(
        success: true,
        message: '同盟条約が締結されました！',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
        treaty: allianceTreaty,
      );
    } else {
      final updatedRelationship = relationship.adjustRelation(-10, reason: '同盟提案拒否');
      return DiplomaticActionResult(
        success: false,
        message: '同盟提案は拒否されました',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
      );
    }
  }

  /// 貿易協定
  static DiplomaticActionResult _proposeTrade(
    DiplomaticSystem diplomacy,
    DiplomaticRelationship relationship,
    int currentTurn,
    Map<String, dynamic>? parameters,
  ) {
    if (relationship.relation == DiplomaticRelation.hostile || relationship.relation == DiplomaticRelation.war) {
      return DiplomaticActionResult(
        success: false,
        message: '敵対関係では貿易できません',
        updatedDiplomacy: diplomacy,
      );
    }

    final tradeValue = parameters?['tradeValue'] ?? 100;
    final duration = parameters?['duration'] ?? 5;

    // 貿易協定締結
    final tradeTreaty = Treaty(
      type: TreatyType.trade,
      signedTurn: currentTurn,
      duration: duration,
      conditions: {
        'trade_value': tradeValue,
        'resource_exchange': true,
      },
      benefits: {
        'gold_per_turn': tradeValue ~/ 10,
        'relation_bonus': 2,
      },
    );

    final updatedRelationship = relationship.adjustRelation(15, reason: '貿易協定締結').copyWith(
      treaties: [...relationship.treaties, tradeTreaty],
      lastAction: DiplomaticAction.proposeTrade,
    );

    return DiplomaticActionResult(
      success: true,
      message: '貿易協定が締結されました',
      updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
      treaty: tradeTreaty,
    );
  }

  /// 朝貢要求
  static DiplomaticActionResult _demandTribute(
    DiplomaticSystem diplomacy,
    DiplomaticRelationship relationship,
    int currentTurn,
    Map<String, dynamic>? parameters,
  ) {
    final tributeAmount = parameters?['amount'] ?? 200;

    // 朝貢要求の成功率は相手の関係値と軍事力による
    final successChance = _calculateTributeSuccessChance(relationship);
    final success = (DateTime.now().millisecondsSinceEpoch % 100) < successChance;

    if (success) {
      final updatedRelationship = relationship.adjustRelation(-20, reason: '朝貢要求受諾');
      return DiplomaticActionResult(
        success: true,
        message: '朝貢要求が受諾されました',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
        goldGained: tributeAmount,
      );
    } else {
      final updatedRelationship = relationship.adjustRelation(-30, reason: '朝貢要求拒否');
      return DiplomaticActionResult(
        success: false,
        message: '朝貢要求は拒否されました',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
      );
    }
  }

  /// 宣戦布告
  static DiplomaticActionResult _declareWar(
    DiplomaticSystem diplomacy,
    DiplomaticRelationship relationship,
    int currentTurn,
  ) {
    if (relationship.relation == DiplomaticRelation.war) {
      return DiplomaticActionResult(
        success: false,
        message: '既に戦争状態です',
        updatedDiplomacy: diplomacy,
      );
    }

    // 条約破棄のペナルティ
    var relationPenalty = -50;
    if (relationship.hasTreaty(TreatyType.alliance)) {
      relationPenalty = -80; // 同盟破棄は重いペナルティ
    }

    // 全ての条約を無効化
    final updatedRelationship = relationship.adjustRelation(relationPenalty, reason: '宣戦布告').copyWith(
          relation: DiplomaticRelation.war,
          treaties: [], // 条約をすべて破棄
          lastAction: DiplomaticAction.declareWar,
        );

    return DiplomaticActionResult(
      success: true,
      message: '宣戦布告しました！',
      updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
    );
  }

  /// 情報交換
  static DiplomaticActionResult _exchangeInformation(
    DiplomaticSystem diplomacy,
    DiplomaticRelationship relationship,
    int currentTurn,
  ) {
    if (relationship.relation == DiplomaticRelation.war) {
      return DiplomaticActionResult(
        success: false,
        message: '戦争中は情報交換できません',
        updatedDiplomacy: diplomacy,
      );
    }

    final updatedRelationship =
        relationship.adjustRelation(5, reason: '情報交換').copyWith(lastAction: DiplomaticAction.exchangeInformation);

    return DiplomaticActionResult(
      success: true,
      message: '情報交換を行いました',
      updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
      intelligence: '他勢力の動向情報を入手',
    );
  }

  /// 支援要請
  static DiplomaticActionResult _requestSupport(
    DiplomaticSystem diplomacy,
    DiplomaticRelationship relationship,
    int currentTurn,
    Map<String, dynamic>? parameters,
  ) {
    final supportType = parameters?['type'] ?? 'military';
    final supportAmount = parameters?['amount'] ?? 1000;

    if (relationship.relationValue < 30) {
      return DiplomaticActionResult(
        success: false,
        message: '関係値が不足しています（必要: 30以上）',
        updatedDiplomacy: diplomacy,
      );
    }

    // 支援の成功率
    final successChance = (relationship.relationValue + 50).clamp(0, 90);
    final success = (DateTime.now().millisecondsSinceEpoch % 100) < successChance;

    if (success) {
      final updatedRelationship =
          relationship.adjustRelation(10, reason: '支援提供').copyWith(lastAction: DiplomaticAction.requestSupport);

      return DiplomaticActionResult(
        success: true,
        message: '支援を受けました',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
        supportReceived: {
          'type': supportType,
          'amount': supportAmount,
        },
      );
    } else {
      final updatedRelationship = relationship.adjustRelation(-5, reason: '支援要請拒否');
      return DiplomaticActionResult(
        success: false,
        message: '支援要請は拒否されました',
        updatedDiplomacy: diplomacy.updateRelationship(updatedRelationship),
      );
    }
  }

  /// 和平成功率計算
  static int _calculatePeaceSuccessChance(DiplomaticRelationship relationship) {
    var chance = 30; // 基本成功率

    // 関係値による補正
    if (relationship.relationValue > -50) chance += 20;
    if (relationship.relationValue > -20) chance += 20;

    // 戦争状態が長引いているほど和平しやすい
    final warEvents = relationship.actionHistory.where((e) => e.action == DiplomaticAction.declareWar).length;
    chance += warEvents * 10;

    return chance.clamp(5, 85);
  }

  /// 同盟成功率計算
  static int _calculateAllianceSuccessChance(DiplomaticRelationship relationship) {
    var chance = 20; // 基本成功率

    // 関係値による大きな影響
    chance += (relationship.relationValue - 50) * 2;

    // 既存の条約があると成功率アップ
    if (relationship.hasTreaty(TreatyType.peace)) chance += 15;
    if (relationship.hasTreaty(TreatyType.trade)) chance += 10;

    return chance.clamp(5, 80);
  }

  /// 朝貢成功率計算
  static int _calculateTributeSuccessChance(DiplomaticRelationship relationship) {
    var chance = 15; // 基本成功率（低い）

    // 関係値が悪いほど成功率は下がる
    if (relationship.relationValue < -30) chance -= 20;
    if (relationship.relationValue < -60) chance -= 30;

    // 友好関係では朝貢要求は失礼
    if (relationship.relationValue > 30) chance -= 25;

    return chance.clamp(0, 40);
  }

  /// AI外交行動決定
  static DiplomaticAction? decideAIDiplomaticAction(
    DiplomaticSystem diplomacy,
    Faction aiFaction,
    List<Faction> otherFactions,
  ) {
    // 簡易AI思考：関係値に基づいて行動決定
    for (final otherFaction in otherFactions) {
      final relationship = diplomacy.getRelationship(aiFaction, otherFaction);
      if (relationship == null) continue;

      // 戦争状態なら和平を検討
      if (relationship.relation == DiplomaticRelation.war && relationship.relationValue > -70) {
        return DiplomaticAction.proposePeace;
      }

      // 友好関係なら同盟を検討
      if (relationship.relation == DiplomaticRelation.friendly &&
          relationship.relationValue > 50 &&
          !relationship.hasTreaty(TreatyType.alliance)) {
        return DiplomaticAction.proposeAlliance;
      }

      // 中立なら貿易協定を検討
      if (relationship.relation == DiplomaticRelation.neutral && !relationship.hasTreaty(TreatyType.trade)) {
        return DiplomaticAction.proposeTrade;
      }
    }

    // デフォルトは情報交換
    return DiplomaticAction.exchangeInformation;
  }

  /// 条約効果を適用
  static Map<String, dynamic> applyTreatyEffects(
    List<Treaty> treaties,
    int currentTurn,
  ) {
    final effects = <String, dynamic>{};

    for (final treaty in treaties) {
      if (!treaty.isActiveAtTurn(currentTurn)) continue;

      switch (treaty.type) {
        case TreatyType.alliance:
          effects['military_support'] = true;
          effects['shared_vision'] = true;
          break;
        case TreatyType.trade:
          effects['gold_bonus'] = (effects['gold_bonus'] ?? 0) + (treaty.benefits['gold_per_turn'] ?? 0);
          break;
        case TreatyType.peace:
          effects['no_aggression'] = true;
          break;
        case TreatyType.nonAggression:
          effects['no_attacks'] = true;
          break;
        case TreatyType.militarySupport:
          effects['troop_support'] = true;
          break;
      }
    }

    return effects;
  }
}

/// 外交行動の結果
class DiplomaticActionResult {
  const DiplomaticActionResult({
    required this.success,
    required this.message,
    required this.updatedDiplomacy,
    this.treaty,
    this.goldGained,
    this.intelligence,
    this.supportReceived,
  });

  final bool success;
  final String message;
  final DiplomaticSystem updatedDiplomacy;
  final Treaty? treaty; // 締結された条約
  final int? goldGained; // 獲得した金銭
  final String? intelligence; // 入手した情報
  final Map<String, dynamic>? supportReceived; // 受けた支援
}
