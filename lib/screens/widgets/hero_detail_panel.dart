/// 英雄詳細・レベルアップパネル
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/water_margin_game_controller.dart';
import '../../models/hero_advancement.dart';
import '../../models/water_margin_strategy_game.dart' as game;

/// 英雄詳細パネル
class HeroDetailPanel extends StatefulWidget {
  const HeroDetailPanel({
    super.key,
    required this.hero,
  });

  final game.Hero hero;

  @override
  State<HeroDetailPanel> createState() => _HeroDetailPanelState();
}

class _HeroDetailPanelState extends State<HeroDetailPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final advancement = controller.getAdvancedHero(widget.hero.id);

        return Card(
          child: Column(
            children: [
              // ヘッダー
              _HeroDetailHeader(
                hero: widget.hero,
                advancement: advancement,
              ),

              // タブバー
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.person),
                    text: '基本情報',
                  ),
                  Tab(
                    icon: Icon(Icons.star),
                    text: 'レベル・スキル',
                  ),
                  Tab(
                    icon: Icon(Icons.inventory),
                    text: '装備',
                  ),
                ],
              ),

              // タブビュー
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 基本情報タブ
                    _HeroBasicInfoTab(hero: widget.hero),

                    // レベル・スキルタブ
                    _HeroLevelSkillTab(
                      hero: widget.hero,
                      advancement: advancement,
                      controller: controller,
                    ),

                    // 装備タブ
                    _HeroEquipmentTab(
                      hero: widget.hero,
                      advancement: advancement,
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 英雄詳細ヘッダー
class _HeroDetailHeader extends StatelessWidget {
  const _HeroDetailHeader({
    required this.hero,
    this.advancement,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;

  @override
  Widget build(BuildContext context) {
    final level = advancement?.advancedStats.level ?? 1;
    final totalExperience = advancement?.advancedStats.experience.values.fold(0, (sum, exp) => sum + exp) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            hero.faction.factionColor.withValues(alpha: 0.8),
            hero.faction.factionColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 英雄アイコン
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  hero.skillIcon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),

              // 英雄情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      hero.nickname,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Lv.$level',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          hero.skillDescription,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ステータス
              if (hero.isRecruited)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '仲間',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          // 経験値バー
          if (hero.isRecruited) const SizedBox(height: 16),
          if (hero.isRecruited)
            _ExperienceBar(
              currentExp: totalExperience,
              level: level,
            ),
        ],
      ),
    );
  }
}

/// 経験値バー
class _ExperienceBar extends StatelessWidget {
  const _ExperienceBar({
    required this.currentExp,
    required this.level,
  });

  final int currentExp;
  final int level;

  @override
  Widget build(BuildContext context) {
    final currentLevelExp = _getExperienceRequirement(level);
    final nextLevelExp = _getExperienceRequirement(level + 1);
    final expInCurrentLevel = currentExp - currentLevelExp;
    final expNeededForLevel = nextLevelExp - currentLevelExp;
    final progress = expInCurrentLevel / expNeededForLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXP: $expInCurrentLevel / $expNeededForLevel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
            Text(
              '次のレベルまで: ${expNeededForLevel - expInCurrentLevel}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
        ),
      ],
    );
  }

  int _getExperienceRequirement(int level) {
    if (level <= 1) return 0;
    return (level - 1) * (level - 1) * 100;
  }
}

/// 基本情報タブ
class _HeroBasicInfoTab extends StatelessWidget {
  const _HeroBasicInfoTab({required this.hero});

  final game.Hero hero;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 能力値表示
          _StatDisplaySection(hero: hero),
          const SizedBox(height: 24),

          // 現在の配置
          _HeroLocationSection(hero: hero),
          const SizedBox(height: 24),

          // 英雄説明
          _HeroDescriptionSection(hero: hero),
        ],
      ),
    );
  }
}

/// 能力値表示セクション
class _StatDisplaySection extends StatelessWidget {
  const _StatDisplaySection({required this.hero});

  final game.Hero hero;

  @override
  Widget build(BuildContext context) {
    final stats = hero.stats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⭐ 能力値',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _StatBar(label: '統率', value: stats.leadership, icon: '👑'),
            _StatBar(label: '武力', value: stats.force, icon: '⚔️'),
            _StatBar(label: '知力', value: stats.intelligence, icon: '🧠'),
            _StatBar(label: '魅力', value: stats.charisma, icon: '✨'),
            _StatBar(label: '義理', value: stats.loyalty, icon: '❤️'),
          ],
        ),
      ),
    );
  }
}

/// 能力値バー
class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final percentage = value / 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                '$value',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 0.8
                  ? Colors.orange
                  : percentage >= 0.6
                      ? Colors.blue
                      : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// 英雄配置セクション
class _HeroLocationSection extends StatelessWidget {
  const _HeroLocationSection({required this.hero});

  final game.Hero hero;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 現在の配置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              hero.currentProvinceId != null ? '${hero.currentProvinceId}に配置中' : '未配置',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hero.isRecruited ? Icons.check_circle : Icons.help_outline,
                  color: hero.isRecruited ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  hero.isRecruited ? '梁山泊の仲間' : '未加入',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 英雄説明セクション
class _HeroDescriptionSection extends StatelessWidget {
  const _HeroDescriptionSection({required this.hero});

  final game.Hero hero;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📜 人物紹介',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _getHeroDescription(hero),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _getHeroDescription(game.Hero hero) {
    // TODO: 実際の英雄説明データを実装
    return '${hero.name}（${hero.nickname}）は${hero.skillDescription}として活躍する英雄です。'
        'その卓越した能力で梁山泊の発展に貢献することが期待されています。';
  }
}

/// レベル・スキルタブ
class _HeroLevelSkillTab extends StatelessWidget {
  const _HeroLevelSkillTab({
    required this.hero,
    this.advancement,
    required this.controller,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    if (!hero.isRecruited) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '仲間になってから\nレベルアップが可能です',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // レベルアップセクション
          _LevelUpSection(
            hero: hero,
            advancement: advancement,
            controller: controller,
          ),
          const SizedBox(height: 24),

          // 習得済みスキルセクション
          _LearnedSkillsSection(
            hero: hero,
            advancement: advancement,
          ),
          const SizedBox(height: 24),

          // 習得可能スキルセクション
          _AvailableSkillsSection(
            hero: hero,
            advancement: advancement,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

/// レベルアップセクション
class _LevelUpSection extends StatelessWidget {
  const _LevelUpSection({
    required this.hero,
    this.advancement,
    required this.controller,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final level = advancement?.advancedStats.level ?? 1;
    final totalExperience = advancement?.advancedStats.experience.values.fold(0, (sum, exp) => sum + exp) ?? 0;
    final canLevelUp = _canLevelUp(level, totalExperience);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '⬆️ レベルアップ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (canLevelUp)
                  ElevatedButton.icon(
                    onPressed: () => _showLevelUpConfirmation(context),
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('レベルアップ！'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 現在のレベル情報
            Row(
              children: [
                Text('現在レベル: $level'),
                const SizedBox(width: 24),
                Text('経験値: $totalExperience'),
              ],
            ),
            const SizedBox(height: 8),

            // レベルアップ時のボーナス表示
            if (canLevelUp) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'レベル${level + 1}への昇格で得られるボーナス:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 全能力値 +2'),
                    const Text('• スキルポイント +1'),
                    const Text('• 新しいスキル習得機会'),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '次のレベルまで: ${_getExperienceToNext(level, totalExperience)} 経験値',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canLevelUp(int level, int experience) {
    final nextLevelExp = _getExperienceRequirement(level + 1);
    return experience >= nextLevelExp && level < 50;
  }

  int _getExperienceToNext(int level, int experience) {
    final nextLevelExp = _getExperienceRequirement(level + 1);
    return (nextLevelExp - experience).clamp(0, double.infinity).toInt();
  }

  int _getExperienceRequirement(int level) {
    if (level <= 1) return 0;
    return (level - 1) * (level - 1) * 100;
  }

  void _showLevelUpConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レベルアップ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${hero.name}をレベルアップしますか？'),
            const SizedBox(height: 16),
            const Text('獲得ボーナス:'),
            const Text('• 全能力値 +2'),
            const Text('• スキルポイント +1'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // 経験値を付与してレベルアップを促進
              final controller = Provider.of<WaterMarginGameController>(context, listen: false);
              controller.addExperience(hero.id, 200, ExperienceType.combat);
              Navigator.of(context).pop();
              _showLevelUpSuccess(context);
            },
            child: const Text('レベルアップ'),
          ),
        ],
      ),
    );
  }

  void _showLevelUpSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${hero.name}がレベルアップしました！'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// 習得済みスキルセクション
class _LearnedSkillsSection extends StatelessWidget {
  const _LearnedSkillsSection({
    required this.hero,
    this.advancement,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;

  @override
  Widget build(BuildContext context) {
    final learnedSkills = _getLearnedSkills();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 習得済みスキル',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (learnedSkills.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'まだスキルを習得していません',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...learnedSkills.map((skill) => _SkillCard(
                    skill: skill,
                    isLearned: true,
                  )),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getLearnedSkills() {
    if (advancement == null) return [];
    
    return advancement!.advancedStats.skills.map((skill) => {
      'name': _getSkillDisplayName(skill),
      'description': _getSkillDescription(skill),
      'icon': _getSkillIcon(skill),
      'effect': _getSkillEffect(skill),
    }).toList();
  }

  // スキル表示用のヘルパーメソッド群（_LearnedSkillsSectionと共通）
  String _getSkillDisplayName(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '狂戦士';
      case HeroLevelSkill.tactician:
        return '戦術家';
      case HeroLevelSkill.duelMaster:
        return '一騎討ち名人';
      case HeroLevelSkill.siegeExpert:
        return '攻城専門家';
      case HeroLevelSkill.administrator:
        return '行政官';
      case HeroLevelSkill.economist:
        return '経済学者';
      case HeroLevelSkill.engineer:
        return '技術者';
      case HeroLevelSkill.scholar:
        return '学者';
      case HeroLevelSkill.negotiator:
        return '交渉人';
      case HeroLevelSkill.spy:
        return '諜報員';
      case HeroLevelSkill.ambassador:
        return '大使';
      case HeroLevelSkill.inspiring:
        return '鼓舞';
      case HeroLevelSkill.strategist:
        return '戦略家';
      case HeroLevelSkill.trainer:
        return '訓練官';
    }
  }

  String _getSkillDescription(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '戦闘時に狂戦士の力を発揮';
      case HeroLevelSkill.tactician:
        return '部隊の戦術指揮に長ける';
      case HeroLevelSkill.duelMaster:
        return '一騎討ちの達人';
      case HeroLevelSkill.siegeExpert:
        return '攻城戦のエキスパート';
      case HeroLevelSkill.administrator:
        return '優秀な行政手腕を持つ';
      case HeroLevelSkill.economist:
        return '経済政策に精通';
      case HeroLevelSkill.engineer:
        return '建設・技術開発の専門家';
      case HeroLevelSkill.scholar:
        return '学問・研究の第一人者';
      case HeroLevelSkill.negotiator:
        return '外交交渉の名手';
      case HeroLevelSkill.spy:
        return '諜報活動のプロフェッショナル';
      case HeroLevelSkill.ambassador:
        return '同盟関係の維持に長ける';
      case HeroLevelSkill.inspiring:
        return '部下の士気を高める';
      case HeroLevelSkill.strategist:
        return '大局的戦略の立案者';
      case HeroLevelSkill.trainer:
        return '兵士の訓練指導者';
    }
  }

  String _getSkillIcon(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '⚡';
      case HeroLevelSkill.tactician:
        return '🎯';
      case HeroLevelSkill.duelMaster:
        return '⚔️';
      case HeroLevelSkill.siegeExpert:
        return '🏰';
      case HeroLevelSkill.administrator:
        return '📋';
      case HeroLevelSkill.economist:
        return '💰';
      case HeroLevelSkill.engineer:
        return '⚙️';
      case HeroLevelSkill.scholar:
        return '📚';
      case HeroLevelSkill.negotiator:
        return '🤝';
      case HeroLevelSkill.spy:
        return '🕵️';
      case HeroLevelSkill.ambassador:
        return '🏛️';
      case HeroLevelSkill.inspiring:
        return '✨';
      case HeroLevelSkill.strategist:
        return '🧠';
      case HeroLevelSkill.trainer:
        return '🏋️';
    }
  }

  String _getSkillEffect(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '戦闘力+20%';
      case HeroLevelSkill.tactician:
        return '部隊指揮+30%';
      case HeroLevelSkill.duelMaster:
        return '一騎討ち勝率+50%';
      case HeroLevelSkill.siegeExpert:
        return '攻城戦+40%';
      case HeroLevelSkill.administrator:
        return '内政効率+25%';
      case HeroLevelSkill.economist:
        return '収入+20%';
      case HeroLevelSkill.engineer:
        return '建設速度+30%';
      case HeroLevelSkill.scholar:
        return '研究速度+25%';
      case HeroLevelSkill.negotiator:
        return '外交成功率+30%';
      case HeroLevelSkill.spy:
        return '情報収集+40%';
      case HeroLevelSkill.ambassador:
        return '同盟維持+25%';
      case HeroLevelSkill.inspiring:
        return '部隊士気+20%';
      case HeroLevelSkill.strategist:
        return '全体戦略+15%';
      case HeroLevelSkill.trainer:
        return '兵士成長+25%';
    }
  }
}

/// 習得可能スキルセクション
class _AvailableSkillsSection extends StatelessWidget {
  const _AvailableSkillsSection({
    required this.hero,
    this.advancement,
    required this.controller,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final level = advancement?.advancedStats.level ?? 1;
    // スキルポイントは仮実装：レベル5ごとに1ポイント、すでに習得したスキル分を減算
    final maxSkillPoints = (level / 5).floor();
    final usedSkillPoints = advancement?.advancedStats.skills.length ?? 0;
    final skillPoints = maxSkillPoints - usedSkillPoints;
    final availableSkills = _getAvailableSkills(level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '📚 習得可能スキル',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'SP: $skillPoints',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (availableSkills.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'レベルアップして新しいスキルを解放しましょう',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...availableSkills.map((skill) => _SkillCard(
                    skill: skill,
                    isLearned: false,
                    canLearn: skillPoints >= (skill['cost'] ?? 1),
                    onLearn: () => _learnSkill(context, skill),
                  )),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableSkills(int level) {
    final learnedSkills = advancement?.advancedStats.skills ?? <HeroLevelSkill>{};
    final skills = <Map<String, dynamic>>[];

    // レベルに応じて習得可能なスキルを定義
    final availableSkillsByLevel = <int, List<HeroLevelSkill>>{
      5: [HeroLevelSkill.berserker, HeroLevelSkill.administrator],
      10: [HeroLevelSkill.tactician, HeroLevelSkill.economist],
      15: [HeroLevelSkill.duelMaster, HeroLevelSkill.engineer],
      20: [HeroLevelSkill.siegeExpert, HeroLevelSkill.scholar],
      25: [HeroLevelSkill.negotiator, HeroLevelSkill.inspiring],
      30: [HeroLevelSkill.spy, HeroLevelSkill.strategist],
      35: [HeroLevelSkill.ambassador, HeroLevelSkill.trainer],
    };

    // 現在のレベルで習得可能で、まだ習得していないスキルを取得
    for (final entry in availableSkillsByLevel.entries) {
      if (level >= entry.key) {
        for (final skill in entry.value) {
          if (!learnedSkills.contains(skill)) {
            skills.add({
              'skill': skill,
              'name': _getSkillDisplayName(skill),
              'description': _getSkillDescription(skill),
              'icon': _getSkillIcon(skill),
              'effect': _getSkillEffect(skill),
              'cost': _getSkillCost(skill),
              'requiredLevel': entry.key,
            });
          }
        }
      }
    }

    return skills;
  }

  int _getSkillCost(HeroLevelSkill skill) {
    // スキルの習得コスト（種類に応じて変える）
    switch (skill) {
      case HeroLevelSkill.berserker:
      case HeroLevelSkill.administrator:
        return 1;
      case HeroLevelSkill.tactician:
      case HeroLevelSkill.economist:
        return 2;
      case HeroLevelSkill.duelMaster:
      case HeroLevelSkill.engineer:
      case HeroLevelSkill.scholar:
        return 2;
      case HeroLevelSkill.siegeExpert:
      case HeroLevelSkill.negotiator:
      case HeroLevelSkill.inspiring:
        return 3;
      case HeroLevelSkill.spy:
      case HeroLevelSkill.strategist:
      case HeroLevelSkill.ambassador:
      case HeroLevelSkill.trainer:
        return 3;
    }
  }

  // スキル表示用のヘルパーメソッド群
  String _getSkillDisplayName(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '狂戦士';
      case HeroLevelSkill.tactician:
        return '戦術家';
      case HeroLevelSkill.duelMaster:
        return '一騎討ち名人';
      case HeroLevelSkill.siegeExpert:
        return '攻城専門家';
      case HeroLevelSkill.administrator:
        return '行政官';
      case HeroLevelSkill.economist:
        return '経済学者';
      case HeroLevelSkill.engineer:
        return '技術者';
      case HeroLevelSkill.scholar:
        return '学者';
      case HeroLevelSkill.negotiator:
        return '交渉人';
      case HeroLevelSkill.spy:
        return '諜報員';
      case HeroLevelSkill.ambassador:
        return '大使';
      case HeroLevelSkill.inspiring:
        return '鼓舞';
      case HeroLevelSkill.strategist:
        return '戦略家';
      case HeroLevelSkill.trainer:
        return '訓練官';
    }
  }

  String _getSkillDescription(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '戦闘時に狂戦士の力を発揮';
      case HeroLevelSkill.tactician:
        return '部隊の戦術指揮に長ける';
      case HeroLevelSkill.duelMaster:
        return '一騎討ちの達人';
      case HeroLevelSkill.siegeExpert:
        return '攻城戦のエキスパート';
      case HeroLevelSkill.administrator:
        return '優秀な行政手腕を持つ';
      case HeroLevelSkill.economist:
        return '経済政策に精通';
      case HeroLevelSkill.engineer:
        return '建設・技術開発の専門家';
      case HeroLevelSkill.scholar:
        return '学問・研究の第一人者';
      case HeroLevelSkill.negotiator:
        return '外交交渉の名手';
      case HeroLevelSkill.spy:
        return '諜報活動のプロフェッショナル';
      case HeroLevelSkill.ambassador:
        return '同盟関係の維持に長ける';
      case HeroLevelSkill.inspiring:
        return '部下の士気を高める';
      case HeroLevelSkill.strategist:
        return '大局的戦略の立案者';
      case HeroLevelSkill.trainer:
        return '兵士の訓練指導者';
    }
  }

  String _getSkillIcon(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '⚡';
      case HeroLevelSkill.tactician:
        return '🎯';
      case HeroLevelSkill.duelMaster:
        return '⚔️';
      case HeroLevelSkill.siegeExpert:
        return '🏰';
      case HeroLevelSkill.administrator:
        return '📋';
      case HeroLevelSkill.economist:
        return '💰';
      case HeroLevelSkill.engineer:
        return '⚙️';
      case HeroLevelSkill.scholar:
        return '📚';
      case HeroLevelSkill.negotiator:
        return '🤝';
      case HeroLevelSkill.spy:
        return '🕵️';
      case HeroLevelSkill.ambassador:
        return '🏛️';
      case HeroLevelSkill.inspiring:
        return '✨';
      case HeroLevelSkill.strategist:
        return '🧠';
      case HeroLevelSkill.trainer:
        return '🏋️';
    }
  }

  String _getSkillEffect(HeroLevelSkill skill) {
    switch (skill) {
      case HeroLevelSkill.berserker:
        return '戦闘力+20%';
      case HeroLevelSkill.tactician:
        return '部隊指揮+30%';
      case HeroLevelSkill.duelMaster:
        return '一騎討ち勝率+50%';
      case HeroLevelSkill.siegeExpert:
        return '攻城戦+40%';
      case HeroLevelSkill.administrator:
        return '内政効率+25%';
      case HeroLevelSkill.economist:
        return '収入+20%';
      case HeroLevelSkill.engineer:
        return '建設速度+30%';
      case HeroLevelSkill.scholar:
        return '研究速度+25%';
      case HeroLevelSkill.negotiator:
        return '外交成功率+30%';
      case HeroLevelSkill.spy:
        return '情報収集+40%';
      case HeroLevelSkill.ambassador:
        return '同盟維持+25%';
      case HeroLevelSkill.inspiring:
        return '部隊士気+20%';
      case HeroLevelSkill.strategist:
        return '全体戦略+15%';
      case HeroLevelSkill.trainer:
        return '兵士成長+25%';
    }
  }

  void _learnSkill(BuildContext context, Map<String, dynamic> skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('スキル習得: ${skill['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(skill['description']),
            const SizedBox(height: 12),
            Text('効果: ${skill['effect']}'),
            Text('必要SP: ${skill['cost']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // スキル習得を実行 - skillオブジェクトから直接HeroLevelSkillを取得
              final heroSkill = skill['skill'] as HeroLevelSkill;
              final skillId = _getSkillIdFromEnum(heroSkill);
              final success = controller.learnHeroSkill(hero.id, skillId);
              Navigator.of(context).pop();
              if (success) {
                _showSkillLearnSuccess(context, skill);
              } else {
                _showSkillLearnError(context, skill);
              }
            },
            child: const Text('習得'),
          ),
        ],
      ),
    );
  }

  void _showSkillLearnSuccess(BuildContext context, Map<String, dynamic> skill) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${skill['name']}を習得しました！'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSkillLearnError(BuildContext context, Map<String, dynamic> skill) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${skill['name']}の習得に失敗しました'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getSkillIdFromEnum(HeroLevelSkill skill) {
    // HeroLevelSkillからスキルIDに変換
    switch (skill) {
      case HeroLevelSkill.berserker:
        return 'berserker_rage';
      case HeroLevelSkill.tactician:
        return 'advanced_tactics';
      case HeroLevelSkill.duelMaster:
        return 'duel_master';
      case HeroLevelSkill.siegeExpert:
        return 'siege_expert';
      case HeroLevelSkill.administrator:
        return 'administration_expert';
      case HeroLevelSkill.economist:
        return 'economist';
      case HeroLevelSkill.engineer:
        return 'engineer';
      case HeroLevelSkill.scholar:
        return 'scholar';
      case HeroLevelSkill.negotiator:
        return 'negotiator';
      case HeroLevelSkill.spy:
        return 'spy';
      case HeroLevelSkill.ambassador:
        return 'ambassador';
      case HeroLevelSkill.inspiring:
        return 'inspiring';
      case HeroLevelSkill.strategist:
        return 'strategist';
      case HeroLevelSkill.trainer:
        return 'trainer';
    }
  }
}

/// スキルカード
class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.skill,
    required this.isLearned,
    this.canLearn = false,
    this.onLearn,
  });

  final Map<String, dynamic> skill;
  final bool isLearned;
  final bool canLearn;
  final VoidCallback? onLearn;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLearned
            ? Colors.green.shade50
            : canLearn
                ? Colors.blue.shade50
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLearned
              ? Colors.green.shade200
              : canLearn
                  ? Colors.blue.shade200
                  : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // スキルアイコン
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLearned
                  ? Colors.green.shade100
                  : canLearn
                      ? Colors.blue.shade100
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              skill['icon'] ?? '📖',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),

          // スキル情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill['name'] ?? '',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  skill['description'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (skill['effect'] != null)
                  Text(
                    skill['effect'],
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // アクション
          if (isLearned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '習得済み',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (canLearn && onLearn != null)
            ElevatedButton(
              onPressed: onLearn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text('習得 (${skill['cost']}SP)'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                skill['requiredLevel'] != null ? 'Lv.${skill['requiredLevel']}必要' : 'SP不足',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 装備タブ
class _HeroEquipmentTab extends StatelessWidget {
  const _HeroEquipmentTab({
    required this.hero,
    this.advancement,
    required this.controller,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    if (!hero.isRecruited) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '仲間になってから\n装備の管理が可能です',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 装備スロット表示
          _EquipmentSlotsSection(
            hero: hero,
            advancement: advancement,
            controller: controller,
          ),
          const SizedBox(height: 24),

          // 装備効果表示
          _EquipmentEffectsSection(
            hero: hero,
            advancement: advancement,
          ),
          const SizedBox(height: 24),

          // 利用可能装備
          _AvailableEquipmentSection(
            hero: hero,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

/// 装備スロットセクション
class _EquipmentSlotsSection extends StatelessWidget {
  const _EquipmentSlotsSection({
    required this.hero,
    this.advancement,
    required this.controller,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚔️ 装備スロット',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // 装備スロット
            _EquipmentSlot(
              slotName: '武器',
              slotIcon: '⚔️',
              equippedItem: _getEquippedItem('weapon'),
              onEquip: () => _showEquipmentSelection(context, 'weapon'),
            ),
            const SizedBox(height: 12),
            _EquipmentSlot(
              slotName: '防具',
              slotIcon: '🛡️',
              equippedItem: _getEquippedItem('armor'),
              onEquip: () => _showEquipmentSelection(context, 'armor'),
            ),
            const SizedBox(height: 12),
            _EquipmentSlot(
              slotName: '装身具',
              slotIcon: '💍',
              equippedItem: _getEquippedItem('accessory'),
              onEquip: () => _showEquipmentSelection(context, 'accessory'),
            ),
            const SizedBox(height: 12),
            _EquipmentSlot(
              slotName: '愛馬',
              slotIcon: '🐎',
              equippedItem: _getEquippedItem('horse'),
              onEquip: () => _showEquipmentSelection(context, 'horse'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _getEquippedItem(String slot) {
    // TODO: 実際の装備データを取得
    if (slot == 'weapon') {
      return {
        'name': '青龍偃月刀',
        'rarity': '伝説',
        'effect': '武力+15',
      };
    }
    return null;
  }

  void _showEquipmentSelection(BuildContext context, String slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getSlotDisplayName(slot)}を選択'),
        content: const SizedBox(
          width: 300,
          height: 400,
          child: Center(child: Text('装備選択機能（実装予定）')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  String _getSlotDisplayName(String slot) {
    switch (slot) {
      case 'weapon':
        return '武器';
      case 'armor':
        return '防具';
      case 'accessory':
        return '装身具';
      case 'horse':
        return '愛馬';
      default:
        return slot;
    }
  }
}

/// 装備スロット
class _EquipmentSlot extends StatelessWidget {
  const _EquipmentSlot({
    required this.slotName,
    required this.slotIcon,
    this.equippedItem,
    required this.onEquip,
  });

  final String slotName;
  final String slotIcon;
  final Map<String, dynamic>? equippedItem;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEquip,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // スロットアイコン
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: equippedItem != null ? Colors.orange.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                slotIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),

            // スロット情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slotName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (equippedItem != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equippedItem!['name'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          equippedItem!['effect'] ?? '',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '未装備',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // アクション
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

/// 装備効果セクション
class _EquipmentEffectsSection extends StatelessWidget {
  const _EquipmentEffectsSection({
    required this.hero,
    this.advancement,
  });

  final game.Hero hero;
  final AdvancedHero? advancement;

  @override
  Widget build(BuildContext context) {
    final equipmentBonus = _calculateEquipmentBonus();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 装備効果',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (equipmentBonus.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '装備による能力ボーナスはありません',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...equipmentBonus.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(_getStatIcon(entry.key)),
                        const SizedBox(width: 8),
                        Text(entry.key),
                        const Spacer(),
                        Text(
                          '+${entry.value}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateEquipmentBonus() {
    // TODO: 実際の装備ボーナス計算
    return {
      '武力': 15,
      '統率': 5,
    };
  }

  String _getStatIcon(String stat) {
    switch (stat) {
      case '武力':
        return '⚔️';
      case '統率':
        return '👑';
      case '知力':
        return '🧠';
      case '魅力':
        return '✨';
      case '義理':
        return '❤️';
      default:
        return '📊';
    }
  }
}

/// 利用可能装備セクション
class _AvailableEquipmentSection extends StatelessWidget {
  const _AvailableEquipmentSection({
    required this.hero,
    required this.controller,
  });

  final game.Hero hero;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final availableEquipment = _getAvailableEquipment();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎒 利用可能な装備',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (availableEquipment.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '利用可能な装備はありません',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...availableEquipment.map((equipment) => _EquipmentItem(
                    equipment: equipment,
                    onEquip: () => _equipItem(context, equipment),
                  )),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableEquipment() {
    // TODO: 実際の利用可能装備データを取得
    return [
      {
        'name': '鉄剣',
        'type': '武器',
        'rarity': '一般',
        'effect': '武力+5',
        'icon': '⚔️',
      },
      {
        'name': '革鎧',
        'type': '防具',
        'rarity': '一般',
        'effect': '防御+3',
        'icon': '🛡️',
      },
    ];
  }

  String _getEquipmentSlot(String type) {
    switch (type) {
      case '武器':
        return 'weapon';
      case '防具':
        return 'armor';
      case 'アクセサリー':
        return 'accessory';
      case '馬':
        return 'horse';
      default:
        return 'weapon';
    }
  }

  String _getEquipmentId(String name) {
    switch (name) {
      case '鉄剣':
        return 'iron_sword';
      case '鋼鉄剣':
        return 'steel_sword';
      case '革鎧':
        return 'leather_armor';
      default:
        return name.toLowerCase().replaceAll(' ', '_');
    }
  }

  void _equipItem(BuildContext context, Map<String, dynamic> equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('装備: ${equipment['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('種類: ${equipment['type']}'),
            Text('品質: ${equipment['rarity']}'),
            Text('効果: ${equipment['effect']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // 装備機能を実装
              final slot = _getEquipmentSlot(equipment['type']);
              final itemId = _getEquipmentId(equipment['name']);
              final success = controller.equipHeroItem(hero.id, slot, itemId);
              Navigator.of(context).pop();
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${equipment['name']}を装備しました'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${equipment['name']}の装備に失敗しました'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('装備'),
          ),
        ],
      ),
    );
  }
}

/// 装備アイテム
class _EquipmentItem extends StatelessWidget {
  const _EquipmentItem({
    required this.equipment,
    required this.onEquip,
  });

  final Map<String, dynamic> equipment;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onEquip,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // アイテムアイコン
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getRarityColor(equipment['rarity']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  equipment['icon'] ?? '📦',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),

              // アイテム情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment['name'] ?? '',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${equipment['type']} - ${equipment['rarity']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      equipment['effect'] ?? '',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 装備ボタン
              ElevatedButton(
                onPressed: onEquip,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('装備'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(String? rarity) {
    switch (rarity) {
      case '伝説':
        return Colors.orange.shade100;
      case '英雄級':
        return Colors.purple.shade100;
      case '稀少':
        return Colors.green.shade100;
      case '優良':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
