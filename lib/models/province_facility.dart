/// 州の施設建設システム
library;

import 'package:flutter/foundation.dart';

/// 施設の種類
enum FacilityType {
  // 軍事施設
  barracks, // 兵舎
  armory, // 武器庫
  watchtower, // 見張り台
  fortress, // 要塞

  // 経済施設
  market, // 市場
  warehouse, // 倉庫
  workshop, // 工房
  mine, // 鉱山

  // 文化施設
  academy, // 学院
  temple, // 神社
  library, // 図書館

  // 特殊施設
  docks, // 港湾
  embassy, // 外交館
  spyNetwork, // 諜報網
}

/// 資源の種類
enum ResourceType {
  population, // 人口
  food, // 食料
  wood, // 木材
  iron, // 鉄
  gold, // 金
  culture, // 文化値
  military, // 軍事力
}

/// 施設クラス
@immutable
class Facility {
  const Facility({
    required this.type,
    required this.name,
    required this.emoji,
    required this.description,
    required this.level,
    required this.maxLevel,
    required this.buildCost,
    required this.upkeepCost,
    required this.buildTime,
    required this.effects,
    required this.unlockRequirements,
    this.specialEffects = const {},
  });

  final FacilityType type;
  final String name;
  final String emoji;
  final String description;
  final int level;
  final int maxLevel;
  final Map<ResourceType, int> buildCost; // 建設コスト
  final Map<ResourceType, int> upkeepCost; // 維持費（毎ターン）
  final int buildTime; // 建設にかかるターン数
  final Map<ResourceType, int> effects; // 効果（毎ターンのボーナス）
  final Map<ResourceType, int> unlockRequirements; // 建設条件
  final Map<String, dynamic> specialEffects; // 特殊効果

  Facility copyWith({
    FacilityType? type,
    String? name,
    String? emoji,
    String? description,
    int? level,
    int? maxLevel,
    Map<ResourceType, int>? buildCost,
    Map<ResourceType, int>? upkeepCost,
    int? buildTime,
    Map<ResourceType, int>? effects,
    Map<ResourceType, int>? unlockRequirements,
    Map<String, dynamic>? specialEffects,
  }) {
    return Facility(
      type: type ?? this.type,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      buildCost: buildCost ?? this.buildCost,
      upkeepCost: upkeepCost ?? this.upkeepCost,
      buildTime: buildTime ?? this.buildTime,
      effects: effects ?? this.effects,
      unlockRequirements: unlockRequirements ?? this.unlockRequirements,
      specialEffects: specialEffects ?? this.specialEffects,
    );
  }

  /// レベルアップ可能かチェック
  bool canUpgrade() => level < maxLevel;

  /// 次のレベルの施設を取得
  Facility upgraded() {
    if (!canUpgrade()) return this;

    final newLevel = level + 1;
    final multiplier = 1.0 + (newLevel * 0.3); // レベルが上がるごとに30%向上

    return copyWith(
      level: newLevel,
      buildCost: buildCost.map((k, v) => MapEntry(k, (v * multiplier * 0.8).round())),
      effects: effects.map((k, v) => MapEntry(k, (v * multiplier).round())),
      upkeepCost: upkeepCost.map((k, v) => MapEntry(k, (v * multiplier * 0.6).round())),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Facility && runtimeType == other.runtimeType && type == other.type && level == other.level;

  @override
  int get hashCode => type.hashCode ^ level.hashCode;
}

/// 建設中の施設
@immutable
class ConstructionProject {
  const ConstructionProject({
    required this.facilityType,
    required this.targetLevel,
    required this.remainingTurns,
    required this.totalCost,
  });

  final FacilityType facilityType;
  final int targetLevel;
  final int remainingTurns;
  final Map<ResourceType, int> totalCost;

  ConstructionProject copyWith({
    FacilityType? facilityType,
    int? targetLevel,
    int? remainingTurns,
    Map<ResourceType, int>? totalCost,
  }) {
    return ConstructionProject(
      facilityType: facilityType ?? this.facilityType,
      targetLevel: targetLevel ?? this.targetLevel,
      remainingTurns: remainingTurns ?? this.remainingTurns,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  /// 建設を1ターン進める
  ConstructionProject advanceTurn() {
    return copyWith(remainingTurns: (remainingTurns - 1).clamp(0, 999));
  }

  /// 建設完了かチェック
  bool get isCompleted => remainingTurns <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstructionProject && runtimeType == other.runtimeType && facilityType == other.facilityType;

  @override
  int get hashCode => facilityType.hashCode;
}

/// 州の施設管理クラス
@immutable
class ProvinceFacilities {
  const ProvinceFacilities({
    this.facilities = const {},
    this.constructionProjects = const [],
  });

  final Map<FacilityType, Facility> facilities; // 建設済み施設
  final List<ConstructionProject> constructionProjects; // 建設中のプロジェクト

  ProvinceFacilities copyWith({
    Map<FacilityType, Facility>? facilities,
    List<ConstructionProject>? constructionProjects,
  }) {
    return ProvinceFacilities(
      facilities: facilities ?? this.facilities,
      constructionProjects: constructionProjects ?? this.constructionProjects,
    );
  }

  /// 施設の効果を計算（毎ターン）
  Map<ResourceType, int> calculateEffects() {
    final totalEffects = <ResourceType, int>{};

    for (final facility in facilities.values) {
      for (final entry in facility.effects.entries) {
        totalEffects[entry.key] = (totalEffects[entry.key] ?? 0) + entry.value;
      }
    }

    return totalEffects;
  }

  /// 維持費を計算（毎ターン）
  Map<ResourceType, int> calculateUpkeepCosts() {
    final totalUpkeep = <ResourceType, int>{};

    for (final facility in facilities.values) {
      for (final entry in facility.upkeepCost.entries) {
        totalUpkeep[entry.key] = (totalUpkeep[entry.key] ?? 0) + entry.value;
      }
    }

    return totalUpkeep;
  }

  /// 特定の施設があるかチェック
  bool hasFacility(FacilityType type) => facilities.containsKey(type);

  /// 施設レベルを取得
  int getFacilityLevel(FacilityType type) => facilities[type]?.level ?? 0;

  /// 建設中の施設があるかチェック
  bool isUnderConstruction(FacilityType type) => constructionProjects.any((p) => p.facilityType == type);

  /// 施設数を取得
  int get totalFacilities => facilities.length;

  /// 特殊効果を取得
  Map<String, dynamic> getSpecialEffects() {
    final allEffects = <String, dynamic>{};

    for (final facility in facilities.values) {
      allEffects.addAll(facility.specialEffects);
    }

    return allEffects;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProvinceFacilities &&
          runtimeType == other.runtimeType &&
          mapEquals(facilities, other.facilities) &&
          listEquals(constructionProjects, other.constructionProjects);

  @override
  int get hashCode => facilities.hashCode ^ constructionProjects.hashCode;
}
