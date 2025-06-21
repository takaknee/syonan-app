/// 英雄リストパネル
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/water_margin_game_controller.dart';
import '../../models/water_margin_strategy_game.dart' as game show Hero;
import '../../models/water_margin_strategy_game.dart' hide Hero;

/// 英雄の一覧と管理を行うパネル
class HeroListPanel extends StatefulWidget {
  const HeroListPanel({super.key});

  @override
  State<HeroListPanel> createState() => _HeroListPanelState();
}

class _HeroListPanelState extends State<HeroListPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          Text(
            '108星の英雄たち',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),

          // タブ
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '仲間'),
              Tab(text: '登用可能'),
            ],
          ),

          // タブコンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _RecruitedHeroesTab(),
                _AvailableHeroesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 仲間になった英雄のタブ
class _RecruitedHeroesTab extends StatelessWidget {
  const _RecruitedHeroesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final recruitedHeroes = controller.gameState.heroes.where((hero) => hero.isRecruited).toList();

        if (recruitedHeroes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'まだ仲間がいません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '英雄を登用して\n梁山泊を強化しましょう',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: recruitedHeroes.length,
          itemBuilder: (context, index) {
            return _HeroCard(
              hero: recruitedHeroes[index],
              isRecruited: true,
              controller: controller,
            );
          },
        );
      },
    );
  }
}

/// 登用可能な英雄のタブ
class _AvailableHeroesTab extends StatelessWidget {
  const _AvailableHeroesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final availableHeroes = controller.getRecruitableHeroes();

        if (availableHeroes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
                SizedBox(height: 16),
                Text(
                  '登用可能な英雄がありません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '全ての英雄を仲間にしたか、\n朝廷軍の英雄は登用できません',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: availableHeroes.length,
          itemBuilder: (context, index) {
            return _HeroCard(
              hero: availableHeroes[index],
              isRecruited: false,
              controller: controller,
            );
          },
        );
      },
    );
  }
}

/// 英雄カード
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.hero,
    required this.isRecruited,
    required this.controller,
  });

  final game.Hero hero;
  final bool isRecruited;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => controller.selectHero(hero.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  // 技能アイコン
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSkillColor(hero.skill).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hero.skillIcon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 名前と渾名
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hero.nickname,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getSkillColor(hero.skill),
                              ),
                        ),
                        Text(
                          hero.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // 勢力表示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getFactionColor(hero.faction),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getFactionName(hero.faction),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 能力値バー
              _StatBar(
                label: '武力',
                value: hero.stats.force,
                color: Colors.red,
                icon: Icons.sports_martial_arts,
              ),
              _StatBar(
                label: '知力',
                value: hero.stats.intelligence,
                color: Colors.blue,
                icon: Icons.psychology,
              ),
              _StatBar(
                label: '魅力',
                value: hero.stats.charisma,
                color: Colors.purple,
                icon: Icons.star,
              ),
              _StatBar(
                label: '統率',
                value: hero.stats.leadership,
                color: Colors.orange,
                icon: Icons.groups,
              ),
              _StatBar(
                label: '義理',
                value: hero.stats.loyalty,
                color: Colors.green,
                icon: Icons.favorite,
              ),

              const SizedBox(height: 8),

              // 技能説明
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      hero.skillDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ),
                ],
              ),

              // 登用ボタン（登用可能な場合のみ）
              if (!isRecruited) ...[
                const SizedBox(height: 12),
                _RecruitButton(hero: hero, controller: controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSkillColor(HeroSkill skill) {
    switch (skill) {
      case HeroSkill.warrior:
        return Colors.red;
      case HeroSkill.strategist:
        return Colors.blue;
      case HeroSkill.administrator:
        return Colors.green;
      case HeroSkill.diplomat:
        return Colors.purple;
      case HeroSkill.scout:
        return Colors.orange;
    }
  }

  Color _getFactionColor(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return Colors.blue;
      case Faction.imperial:
        return Colors.red;
      case Faction.warlord:
        return Colors.purple;
      case Faction.bandit:
        return Colors.orange;
      case Faction.neutral:
        return Colors.grey;
    }
  }

  String _getFactionName(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return '梁山';
      case Faction.imperial:
        return '朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.bandit:
        return '盗賊';
      case Faction.neutral:
        return '在野';
    }
  }
}

/// 能力値バー
class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          SizedBox(
            width: 30,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// 登用ボタン
class _RecruitButton extends StatelessWidget {
  const _RecruitButton({
    required this.hero,
    required this.controller,
  });

  final game.Hero hero;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final cost = _calculateRecruitmentCost(hero);
    final canAfford = controller.gameState.playerGold >= cost;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canAfford ? () => _showRecruitmentDialog(context, hero, cost, controller) : null,
        icon: const Icon(Icons.person_add, size: 16),
        label: Text('登用 ($cost両)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: canAfford ? Colors.green : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    );
  }

  int _calculateRecruitmentCost(game.Hero hero) {
    final totalStats = hero.stats.force + hero.stats.intelligence + hero.stats.charisma + hero.stats.leadership;
    return (totalStats * 3).round();
  }

  void _showRecruitmentDialog(
    BuildContext context,
    game.Hero hero,
    int cost,
    WaterMarginGameController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${hero.nickname}の登用'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${hero.name}（${hero.nickname}）を仲間にしますか？'),
            const SizedBox(height: 12),
            Text('登用費用: $cost両'),
            Text('現在の資金: ${controller.gameState.playerGold}両'),
            const SizedBox(height: 12),
            Text(
              '能力: 武${hero.stats.force} 知${hero.stats.intelligence} '
              '魅${hero.stats.charisma} 統${hero.stats.leadership}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '特技: ${hero.skillDescription}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final success = controller.recruitHero(hero.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '${hero.nickname}が仲間になりました！' : '登用に失敗しました'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('登用'),
          ),
        ],
      ),
    );
  }
}
