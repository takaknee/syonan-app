/// 水滸伝戦略ゲーム 英雄詳細・レベルアップUI
/// フェーズ3: 英雄システム拡張のUI表示
library;

import 'package:flutter/material.dart' hide Hero;
import 'package:provider/provider.dart';

import '../../controllers/water_margin_game_controller.dart';
import '../../models/hero_advancement.dart';
import '../../models/water_margin_strategy_game.dart';

/// 英雄詳細ダイアログ
class HeroDetailDialog extends StatelessWidget {
  const HeroDetailDialog({
    super.key,
    required this.hero,
  });

  final Hero hero;

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final advancedHero = controller.getAdvancedHero(hero.id);

        return AlertDialog(
          title: Row(
            children: [
              Text(hero.skillIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      hero.nickname,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // レベル情報
                  if (advancedHero != null) ...[
                    _buildLevelSection(context, advancedHero),
                    const Divider(),
                  ],

                  // 基本能力値
                  _buildStatsSection(context, hero, advancedHero),
                  const Divider(),

                  // 経験値情報
                  if (advancedHero != null) ...[
                    _buildExperienceSection(context, advancedHero),
                    const Divider(),
                  ],

                  // 習得スキル
                  if (advancedHero != null && advancedHero.advancedStats.skills.isNotEmpty) ...[
                    _buildSkillsSection(context, advancedHero),
                    const Divider(),
                  ],

                  // 装備情報
                  if (advancedHero?.advancedStats.equipment != null) ...[
                    _buildEquipmentSection(context, advancedHero!),
                    const Divider(),
                  ],

                  // 基本情報
                  _buildBasicInfoSection(context, hero),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLevelSection(BuildContext context, AdvancedHero advancedHero) {
    final level = advancedHero.advancedStats.level;
    final rank = advancedHero.advancedStats.rank;
    final expToNext = advancedHero.advancedStats.expToNextLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'レベル $level',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(_rankName(rank)),
                  backgroundColor: _rankColor(rank),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (level < 100) ...[
              Text('次のレベルまで: $expToNext経験値'),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: expToNext > 0 ? 0.5 : 1.0, // 簡易プログレス表示
                backgroundColor: Colors.grey[300],
              ),
            ] else
              const Text('最大レベル達成！', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Hero hero, AdvancedHero? advancedHero) {
    final effectiveStats = advancedHero?.advancedStats.effectiveStats ?? hero.stats;
    final hasBonus = advancedHero != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('能力値', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatRow('武力', hero.stats.force, effectiveStats.force, hasBonus),
            _buildStatRow('知力', hero.stats.intelligence, effectiveStats.intelligence, hasBonus),
            _buildStatRow('魅力', hero.stats.charisma, effectiveStats.charisma, hasBonus),
            _buildStatRow('統率', hero.stats.leadership, effectiveStats.leadership, hasBonus),
            _buildStatRow('義理', hero.stats.loyalty, effectiveStats.loyalty, hasBonus),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('戦闘力: ${effectiveStats.combatPower}'),
                Text('内政力: ${effectiveStats.administrativePower}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int base, int effective, bool hasBonus) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          hasBonus && effective != base
              ? RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: '$base'),
                      TextSpan(
                        text: ' → $effective',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Text('$effective'),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(BuildContext context, AdvancedHero advancedHero) {
    final experience = advancedHero.advancedStats.experience;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('経験値', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildExpRow('戦闘', experience[ExperienceType.combat] ?? 0, Icons.military_tech),
            _buildExpRow('内政', experience[ExperienceType.administration] ?? 0, Icons.home_work),
            _buildExpRow('外交', experience[ExperienceType.diplomacy] ?? 0, Icons.handshake),
            _buildExpRow('統率', experience[ExperienceType.leadership] ?? 0, Icons.groups),
            const SizedBox(height: 8),
            Text(
              '総経験値: ${experience.values.fold(0, (sum, exp) => sum + exp)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpRow(String label, int exp, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
          const Spacer(),
          Text('$exp'),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, AdvancedHero advancedHero) {
    final skills = advancedHero.advancedStats.skills;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('習得スキル', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: skills
                  .map((skill) => Chip(
                        label: Text(_skillName(skill)),
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSection(BuildContext context, AdvancedHero advancedHero) {
    final equipment = advancedHero.advancedStats.equipment!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('装備', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (equipment.weapon != null) _buildEquipRow('武器', equipment.weapon!),
            if (equipment.armor != null) _buildEquipRow('防具', equipment.armor!),
            if (equipment.accessory != null) _buildEquipRow('装身具', equipment.accessory!),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipRow(String type, Equipment equipment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(type)),
          Chip(
            label: Text(equipment.name),
            backgroundColor: _rarityColor(equipment.rarity),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, Hero hero) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基本情報', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow('専門技能', _skillTypeName(hero.skill)),
            _buildInfoRow('勢力', _factionName(hero.faction)),
            _buildInfoRow('登用状況', hero.isRecruited ? '仲間' : '未登用'),
            if (hero.currentProvinceId != null) _buildInfoRow('配置場所', hero.currentProvinceId!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ヘルパーメソッド
  String _rankName(HeroRank rank) {
    switch (rank) {
      case HeroRank.recruit:
        return '新人';
      case HeroRank.veteran:
        return '古参';
      case HeroRank.elite:
        return '精鋭';
      case HeroRank.master:
        return '達人';
      case HeroRank.legend:
        return '伝説';
    }
  }

  Color _rankColor(HeroRank rank) {
    switch (rank) {
      case HeroRank.recruit:
        return Colors.grey[300]!;
      case HeroRank.veteran:
        return Colors.blue[300]!;
      case HeroRank.elite:
        return Colors.purple[300]!;
      case HeroRank.master:
        return Colors.orange[300]!;
      case HeroRank.legend:
        return Colors.amber[300]!;
    }
  }

  Color _rarityColor(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.common:
        return Colors.grey[300]!;
      case EquipmentRarity.uncommon:
        return Colors.green[300]!;
      case EquipmentRarity.rare:
        return Colors.blue[300]!;
      case EquipmentRarity.epic:
        return Colors.purple[300]!;
      case EquipmentRarity.legendary:
        return Colors.amber[300]!;
    }
  }

  String _skillName(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '狂戦士';
      case HeroLevelSkill.tactician:
        return '戦術家';
      case HeroLevelSkill.administrator:
        return '行政官';
      case HeroLevelSkill.economist:
        return '経済学者';
      case HeroLevelSkill.negotiator:
        return '交渉人';
      case HeroLevelSkill.inspiring:
        return '鼓舞';
      case HeroLevelSkill.strategist:
        return '戦略家';
      default:
        return skill.name;
    }
  }

  String _skillTypeName(HeroSkill skill) {
    switch (skill) {
      case HeroSkill.warrior:
        return '武将';
      case HeroSkill.strategist:
        return '軍師';
      case HeroSkill.administrator:
        return '政治家';
      case HeroSkill.diplomat:
        return '外交官';
      case HeroSkill.scout:
        return '斥候';
    }
  }

  String _factionName(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return '梁山泊';
      case Faction.imperial:
        return '朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.bandit:
        return '盗賊';
      case Faction.neutral:
        return '中立';
    }
  }
}
