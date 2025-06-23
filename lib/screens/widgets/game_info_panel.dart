/// ゲーム情報パネル
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/water_margin_game_controller.dart';
import '../../models/water_margin_strategy_game.dart';

/// ゲーム全体の情報を表示するパネル
class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<WaterMarginGameController>(
        builder: (context, controller, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              Text(
                '梁山泊戦況',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),

              // 勢力状況
              _FactionStatus(gameState: controller.gameState),
              const SizedBox(height: 16),

              // 資源状況
              _ResourceStatus(gameState: controller.gameState),
              const SizedBox(height: 16),

              // 英雄状況
              _HeroStatus(gameState: controller.gameState),
            ],
          );
        },
      ),
    );
  }
}

/// 勢力の状況表示
class _FactionStatus extends StatelessWidget {
  const _FactionStatus({required this.gameState});

  final WaterMarginGameState gameState;

  @override
  Widget build(BuildContext context) {
    final factionCounts = <Faction, int>{};
    for (final faction in Faction.values) {
      factionCounts[faction] =
          gameState.provinces.where((p) => p.controller == faction).length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '勢力分布',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...factionCounts.entries.map((entry) {
              return _FactionRow(
                faction: entry.key,
                count: entry.value,
                total: gameState.provinces.length,
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 個別勢力の行表示
class _FactionRow extends StatelessWidget {
  const _FactionRow({
    required this.faction,
    required this.count,
    required this.total,
  });

  final Faction faction;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage = (count / total * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getFactionColor(faction),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFactionName(faction),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '$count州 ($percentage%)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
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
        return '梁山泊';
      case Faction.imperial:
        return '宋朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.bandit:
        return '盗賊';
      case Faction.neutral:
        return '中立';
    }
  }
}

/// 資源状況表示
class _ResourceStatus extends StatelessWidget {
  const _ResourceStatus({required this.gameState});

  final WaterMarginGameState gameState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '資源状況',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ResourceRow(
              icon: Icons.monetization_on,
              label: '軍資金',
              value: '${gameState.playerGold}両',
              color: Colors.amber,
            ),
            _ResourceRow(
              icon: Icons.people,
              label: '総兵力',
              value: '${gameState.playerTotalTroops}人',
              color: Colors.red,
            ),
            _ResourceRow(
              icon: Icons.location_city,
              label: '支配州',
              value: '${gameState.playerProvinceCount}州',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

/// 個別資源の行表示
class _ResourceRow extends StatelessWidget {
  const _ResourceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

/// 英雄状況表示
class _HeroStatus extends StatelessWidget {
  const _HeroStatus({required this.gameState});

  final WaterMarginGameState gameState;

  @override
  Widget build(BuildContext context) {
    final recruitedCount = gameState.recruitedHeroCount;
    final totalCount = gameState.heroes.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '英雄状況',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.group, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '仲間の英雄',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  '$recruitedCount / $totalCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: recruitedCount / totalCount,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              '108星収集進度: ${(recruitedCount / totalCount * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
