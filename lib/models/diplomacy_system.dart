/// 外交システムモデル
/// 勢力間の関係・同盟・交渉を管理
library;

import 'package:flutter/foundation.dart';

import 'water_margin_strategy_game.dart';

/// 外交関係の種類
enum DiplomaticRelation {
  ally, // 同盟
  friendly, // 友好
  neutral, // 中立
  hostile, // 敵対
  war, // 戦争状態
}

/// 外交行動の種類
enum DiplomaticAction {
  proposePeace, // 和平提案
  proposeAlliance, // 同盟提案
  proposeTrade, // 貿易協定
  demandTribute, // 朝貢要求
  declareWar, // 宣戦布告
  exchangeInformation, // 情報交換
  requestSupport, // 支援要請
}

/// 条約の種類
enum TreatyType {
  peace, // 和平条約
  alliance, // 同盟条約
  trade, // 貿易協定
  nonAggression, // 不可侵協定
  militarySupport, // 軍事支援協定
}

/// 外交関係データ
@immutable
class DiplomaticRelationship {
  const DiplomaticRelationship({
    required this.faction1,
    required this.faction2,
    required this.relation,
    required this.relationValue,
    this.treaties = const [],
    this.lastAction,
    this.actionHistory = const [],
  });

  final Faction faction1;
  final Faction faction2;
  final DiplomaticRelation relation;
  final int relationValue; // -100 (最悪) ～ +100 (最良)
  final List<Treaty> treaties; // 締結中の条約
  final DiplomaticAction? lastAction; // 最後に行った外交行動
  final List<DiplomaticEvent> actionHistory; // 外交行動履歴

  DiplomaticRelationship copyWith({
    Faction? faction1,
    Faction? faction2,
    DiplomaticRelation? relation,
    int? relationValue,
    List<Treaty>? treaties,
    DiplomaticAction? lastAction,
    List<DiplomaticEvent>? actionHistory,
  }) {
    return DiplomaticRelationship(
      faction1: faction1 ?? this.faction1,
      faction2: faction2 ?? this.faction2,
      relation: relation ?? this.relation,
      relationValue: relationValue ?? this.relationValue,
      treaties: treaties ?? this.treaties,
      lastAction: lastAction,
      actionHistory: actionHistory ?? this.actionHistory,
    );
  }

  /// 関係値から自動的に関係種別を決定
  DiplomaticRelation get autoRelation {
    if (relationValue >= 70) return DiplomaticRelation.ally;
    if (relationValue >= 30) return DiplomaticRelation.friendly;
    if (relationValue >= -30) return DiplomaticRelation.neutral;
    if (relationValue >= -70) return DiplomaticRelation.hostile;
    return DiplomaticRelation.war;
  }

  /// 関係値を調整
  DiplomaticRelationship adjustRelation(int change, {String? reason}) {
    final newValue = (relationValue + change).clamp(-100, 100);
    final newRelation = autoRelation;

    final event = DiplomaticEvent(
      turn: DateTime.now().millisecondsSinceEpoch % 1000, // 簡易ターン数
      action: lastAction ?? DiplomaticAction.exchangeInformation,
      relationChange: change,
      reason: reason ?? '外交行動',
    );

    return copyWith(
      relationValue: newValue,
      relation: newRelation,
      actionHistory: [...actionHistory, event],
    );
  }

  /// 特定の条約があるかチェック
  bool hasTreaty(TreatyType type) {
    return treaties.any((treaty) => treaty.type == type && treaty.isActive);
  }

  /// 有効な条約を取得
  List<Treaty> get activeTreaties {
    return treaties.where((treaty) => treaty.isActive).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiplomaticRelationship &&
          runtimeType == other.runtimeType &&
          ((faction1 == other.faction1 && faction2 == other.faction2) ||
              (faction1 == other.faction2 && faction2 == other.faction1));

  @override
  int get hashCode => faction1.hashCode ^ faction2.hashCode;
}

/// 条約クラス
@immutable
class Treaty {
  const Treaty({
    required this.type,
    required this.signedTurn,
    required this.duration,
    this.conditions = const {},
    this.benefits = const {},
  });

  final TreatyType type;
  final int signedTurn; // 締結したターン
  final int duration; // 有効期間（ターン数、-1は永続）
  final Map<String, dynamic> conditions; // 条約条件
  final Map<String, dynamic> benefits; // 条約による利益

  Treaty copyWith({
    TreatyType? type,
    int? signedTurn,
    int? duration,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? benefits,
  }) {
    return Treaty(
      type: type ?? this.type,
      signedTurn: signedTurn ?? this.signedTurn,
      duration: duration ?? this.duration,
      conditions: conditions ?? this.conditions,
      benefits: benefits ?? this.benefits,
    );
  }

  /// 条約が有効かチェック
  bool isActiveAtTurn(int currentTurn) {
    if (duration == -1) return true; // 永続条約
    return currentTurn <= signedTurn + duration;
  }

  /// 現在有効かチェック（簡易実装）
  bool get isActive => isActiveAtTurn(DateTime.now().millisecondsSinceEpoch % 1000);

  /// 条約の日本語名
  String get displayName {
    switch (type) {
      case TreatyType.peace:
        return '和平条約';
      case TreatyType.alliance:
        return '同盟条約';
      case TreatyType.trade:
        return '貿易協定';
      case TreatyType.nonAggression:
        return '不可侵協定';
      case TreatyType.militarySupport:
        return '軍事支援協定';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Treaty && runtimeType == other.runtimeType && type == other.type && signedTurn == other.signedTurn;

  @override
  int get hashCode => type.hashCode ^ signedTurn.hashCode;
}

/// 外交イベント（行動履歴用）
@immutable
class DiplomaticEvent {
  const DiplomaticEvent({
    required this.turn,
    required this.action,
    required this.relationChange,
    this.reason,
  });

  final int turn;
  final DiplomaticAction action;
  final int relationChange;
  final String? reason;

  DiplomaticEvent copyWith({
    int? turn,
    DiplomaticAction? action,
    int? relationChange,
    String? reason,
  }) {
    return DiplomaticEvent(
      turn: turn ?? this.turn,
      action: action ?? this.action,
      relationChange: relationChange ?? this.relationChange,
      reason: reason ?? this.reason,
    );
  }

  /// 外交行動の日本語名
  String get actionName {
    switch (action) {
      case DiplomaticAction.proposePeace:
        return '和平提案';
      case DiplomaticAction.proposeAlliance:
        return '同盟提案';
      case DiplomaticAction.proposeTrade:
        return '貿易協定';
      case DiplomaticAction.demandTribute:
        return '朝貢要求';
      case DiplomaticAction.declareWar:
        return '宣戦布告';
      case DiplomaticAction.exchangeInformation:
        return '情報交換';
      case DiplomaticAction.requestSupport:
        return '支援要請';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiplomaticEvent && runtimeType == other.runtimeType && turn == other.turn && action == other.action;

  @override
  int get hashCode => turn.hashCode ^ action.hashCode;
}

/// 外交システム全体管理
@immutable
class DiplomaticSystem {
  const DiplomaticSystem({
    this.relationships = const [],
    this.globalEvents = const [],
  });

  final List<DiplomaticRelationship> relationships;
  final List<DiplomaticEvent> globalEvents; // 全体に影響する外交イベント

  DiplomaticSystem copyWith({
    List<DiplomaticRelationship>? relationships,
    List<DiplomaticEvent>? globalEvents,
  }) {
    return DiplomaticSystem(
      relationships: relationships ?? this.relationships,
      globalEvents: globalEvents ?? this.globalEvents,
    );
  }

  /// 二つの勢力間の関係を取得
  DiplomaticRelationship? getRelationship(Faction faction1, Faction faction2) {
    return relationships.firstWhere(
      (rel) =>
          (rel.faction1 == faction1 && rel.faction2 == faction2) ||
          (rel.faction1 == faction2 && rel.faction2 == faction1),
      orElse: () => DiplomaticRelationship(
        faction1: faction1,
        faction2: faction2,
        relation: DiplomaticRelation.neutral,
        relationValue: 0,
      ),
    );
  }

  /// 関係を更新
  DiplomaticSystem updateRelationship(DiplomaticRelationship newRelationship) {
    final updatedRelationships = relationships.map((rel) {
      if (rel == newRelationship) {
        return newRelationship;
      }
      return rel;
    }).toList();

    // 新しい関係が存在しない場合は追加
    if (!updatedRelationships.contains(newRelationship)) {
      updatedRelationships.add(newRelationship);
    }

    return copyWith(relationships: updatedRelationships);
  }

  /// 特定勢力の全関係を取得
  List<DiplomaticRelationship> getFactionsRelationships(Faction faction) {
    return relationships.where((rel) => rel.faction1 == faction || rel.faction2 == faction).toList();
  }

  /// 同盟勢力を取得
  List<Faction> getAllies(Faction faction) {
    return relationships
        .where((rel) => (rel.faction1 == faction || rel.faction2 == faction) && rel.relation == DiplomaticRelation.ally)
        .map((rel) => rel.faction1 == faction ? rel.faction2 : rel.faction1)
        .toList();
  }

  /// 敵対勢力を取得
  List<Faction> getEnemies(Faction faction) {
    return relationships
        .where((rel) =>
            (rel.faction1 == faction || rel.faction2 == faction) &&
            (rel.relation == DiplomaticRelation.hostile || rel.relation == DiplomaticRelation.war))
        .map((rel) => rel.faction1 == faction ? rel.faction2 : rel.faction1)
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiplomaticSystem && runtimeType == other.runtimeType && listEquals(relationships, other.relationships);

  @override
  int get hashCode => relationships.hashCode;
}
