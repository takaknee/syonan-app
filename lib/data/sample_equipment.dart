/// サンプル装備データ
/// フェーズ3: 英雄装備システムのテスト用データ
library;

import '../models/hero_advancement.dart';
import '../models/water_margin_strategy_game.dart';

/// サンプル装備データクラス
class SampleEquipment {
  /// 武器一覧
  static const List<Equipment> weapons = [
    Equipment(
      id: 'wooden_sword',
      name: '木刀',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.common,
      statBonus: HeroStats(
        force: 5,
        intelligence: 0,
        charisma: 0,
        leadership: 0,
        loyalty: 0,
      ),
      description: '基本的な練習用武器',
    ),
    Equipment(
      id: 'iron_sword',
      name: '鉄剣',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.uncommon,
      statBonus: HeroStats(
        force: 10,
        intelligence: 0,
        charisma: 2,
        leadership: 0,
        loyalty: 0,
      ),
      description: '良質な鉄で作られた剣',
    ),
    Equipment(
      id: 'steel_spear',
      name: '鋼槍',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.rare,
      statBonus: HeroStats(
        force: 15,
        intelligence: 0,
        charisma: 0,
        leadership: 5,
        loyalty: 0,
      ),
      description: '軍師が愛用する長槍',
    ),
    Equipment(
      id: 'legendary_blade',
      name: '青竜偃月刀',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.legendary,
      statBonus: HeroStats(
        force: 25,
        intelligence: 0,
        charisma: 10,
        leadership: 10,
        loyalty: 5,
      ),
      specialEffect: '戦闘時に味方全体の士気を高める',
      description: '伝説の名将が使った偃月刀',
    ),
  ];

  /// 防具一覧
  static const List<Equipment> armors = [
    Equipment(
      id: 'cloth_armor',
      name: '布の服',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.common,
      statBonus: HeroStats(
        force: 0,
        intelligence: 2,
        charisma: 3,
        leadership: 0,
        loyalty: 0,
      ),
      description: '普通の衣服',
    ),
    Equipment(
      id: 'leather_armor',
      name: '革鎧',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.uncommon,
      statBonus: HeroStats(
        force: 5,
        intelligence: 0,
        charisma: 0,
        leadership: 5,
        loyalty: 0,
      ),
      description: '軽量で動きやすい革製の鎧',
    ),
    Equipment(
      id: 'iron_armor',
      name: '鉄鎧',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.rare,
      statBonus: HeroStats(
        force: 8,
        intelligence: 0,
        charisma: -2,
        leadership: 10,
        loyalty: 0,
      ),
      description: '重厚な鉄製の鎧',
    ),
    Equipment(
      id: 'golden_armor',
      name: '黄金の鎧',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.legendary,
      statBonus: HeroStats(
        force: 15,
        intelligence: 5,
        charisma: 15,
        leadership: 15,
        loyalty: 10,
      ),
      specialEffect: '全ての能力値に大幅ボーナス',
      description: '皇帝から下賜された黄金の鎧',
    ),
  ];

  /// アクセサリー一覧
  static const List<Equipment> accessories = [
    Equipment(
      id: 'simple_ring',
      name: '銀の指輪',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.common,
      statBonus: HeroStats(
        force: 0,
        intelligence: 3,
        charisma: 2,
        leadership: 0,
        loyalty: 0,
      ),
      description: '知力を少し高める指輪',
    ),
    Equipment(
      id: 'jade_pendant',
      name: '翡翠の首飾り',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.uncommon,
      statBonus: HeroStats(
        force: 0,
        intelligence: 5,
        charisma: 8,
        leadership: 3,
        loyalty: 5,
      ),
      description: '高貴さを演出する翡翠の装身具',
    ),
    Equipment(
      id: 'war_banner',
      name: '戦旗',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.rare,
      statBonus: HeroStats(
        force: 3,
        intelligence: 0,
        charisma: 5,
        leadership: 12,
        loyalty: 8,
      ),
      specialEffect: '戦闘時に部隊の統率力向上',
      description: '軍を率いる指揮官の象徴',
    ),
    Equipment(
      id: 'imperial_seal',
      name: '皇帝の印章',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.legendary,
      statBonus: HeroStats(
        force: 5,
        intelligence: 20,
        charisma: 20,
        leadership: 20,
        loyalty: 15,
      ),
      specialEffect: '全ての政治行動に大幅ボーナス',
      description: '皇帝の権威を象徴する印章',
    ),
  ];

  /// 全装備リスト
  static List<Equipment> get allEquipment => [
        ...weapons,
        ...armors,
        ...accessories,
      ];

  /// レアリティ別装備取得
  static List<Equipment> getEquipmentByRarity(EquipmentRarity rarity) {
    return allEquipment.where((equipment) => equipment.rarity == rarity).toList();
  }

  /// タイプ別装備取得
  static List<Equipment> getEquipmentByType(EquipmentType type) {
    return allEquipment.where((equipment) => equipment.type == type).toList();
  }

  /// ランダム装備取得
  static Equipment getRandomEquipment() {
    final equipment = allEquipment;
    return equipment[DateTime.now().millisecondsSinceEpoch % equipment.length];
  }

  /// ランダム装備取得（レアリティ指定）
  static Equipment? getRandomEquipmentByRarity(EquipmentRarity rarity) {
    final equipment = getEquipmentByRarity(rarity);
    if (equipment.isEmpty) return null;
    return equipment[DateTime.now().millisecondsSinceEpoch % equipment.length];
  }
}
