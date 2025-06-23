/// 州詳細パネル
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/water_margin_game_controller.dart';
import '../../models/water_margin_strategy_game.dart';

/// 選択された州の詳細情報を表示するパネル
class ProvinceDetailPanel extends StatelessWidget {
  const ProvinceDetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<WaterMarginGameController>(
        builder: (context, controller, child) {
          final selectedProvince = controller.gameState.selectedProvince;

          if (selectedProvince == null) {
            return const _NoSelectionView();
          }

          return _ProvinceDetailView(
            province: selectedProvince,
            controller: controller,
          );
        },
      ),
    );
  }
}

/// 何も選択されていない時の表示
class _NoSelectionView extends StatelessWidget {
  const _NoSelectionView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'マップ上の州を選択してください',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '州をタップすると詳細情報と\n利用可能なアクションが表示されます',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 州詳細表示
class _ProvinceDetailView extends StatelessWidget {
  const _ProvinceDetailView({
    required this.province,
    required this.controller,
  });

  final Province province;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 州ヘッダー
          _ProvinceHeader(province: province),
          const SizedBox(height: 16),

          // 州の状態
          _ProvinceStats(province: province),
          const SizedBox(height: 16),

          // アクションボタン
          _ProvinceActions(
            province: province,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

/// 州ヘッダー
class _ProvinceHeader extends StatelessWidget {
  const _ProvinceHeader({required this.province});

  final Province province;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  province.provinceIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        province.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _getFactionName(province.controller),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: province.factionColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (province.specialFeature != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text(
                  '⭐ ${province.specialFeature}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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

/// 州の統計情報
class _ProvinceStats extends StatelessWidget {
  const _ProvinceStats({required this.province});

  final Province province;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '州の状況',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // 基本情報
            _StatRow(
              icon: Icons.people,
              label: '人口',
              value: '${province.state.population}万人',
              color: Colors.blue,
            ),
            _StatRow(
              icon: Icons.security,
              label: '兵力',
              value: '${province.currentTroops}人',
              color: Colors.red,
            ),

            const Divider(),

            // 内政状況
            _StatBar(
              label: '農業',
              value: province.state.agriculture,
              color: Colors.green,
              icon: Icons.eco,
            ),
            _StatBar(
              label: '商業',
              value: province.state.commerce,
              color: Colors.orange,
              icon: Icons.store,
            ),
            _StatBar(
              label: '治安',
              value: province.state.security,
              color: Colors.blue,
              icon: Icons.shield,
            ),
            _StatBar(
              label: '軍事',
              value: province.state.military,
              color: Colors.red,
              icon: Icons.castle,
            ),
            _StatBar(
              label: '民心',
              value: province.state.loyalty,
              color: Colors.purple,
              icon: Icons.favorite,
            ),

            const Divider(),

            // 収入情報
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '税収',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${province.state.taxIncome}両/ターン',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '兵力上限',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${province.state.maxTroops}人',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 統計行表示
class _StatRow extends StatelessWidget {
  const _StatRow({
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

/// 統計バー表示
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '$value',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}

/// 州のアクション
class _ProvinceActions extends StatelessWidget {
  const _ProvinceActions({
    required this.province,
    required this.controller,
  });

  final Province province;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final isPlayerProvince = province.controller == Faction.liangshan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'アクション',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (isPlayerProvince) ...[
              // プレイヤーの州の場合
              _DevelopmentActions(
                province: province,
                controller: controller,
              ),
            ] else ...[
              // 他勢力の州の場合
              _AttackActions(
                province: province,
                controller: controller,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 開発アクション（プレイヤーの州用）
class _DevelopmentActions extends StatelessWidget {
  const _DevelopmentActions({
    required this.province,
    required this.controller,
  });

  final Province province;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionButton(
          icon: Icons.eco,
          label: '農業開発 (200両)',
          onPressed: controller.gameState.playerGold >= 200
              ? () => controller.developProvince(
                  province.id, DevelopmentType.agriculture)
              : null,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.store,
          label: '商業開発 (300両)',
          onPressed: controller.gameState.playerGold >= 300
              ? () => controller.developProvince(
                  province.id, DevelopmentType.commerce)
              : null,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.castle,
          label: '軍事強化 (400両)',
          onPressed: controller.gameState.playerGold >= 400
              ? () => controller.developProvince(
                  province.id, DevelopmentType.military)
              : null,
          color: Colors.red,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.shield,
          label: '治安改善 (150両)',
          onPressed: controller.gameState.playerGold >= 150
              ? () => controller.developProvince(
                  province.id, DevelopmentType.security)
              : null,
          color: Colors.blue,
        ),
      ],
    );
  }
}

/// 攻撃アクション（他勢力の州用）
class _AttackActions extends StatelessWidget {
  const _AttackActions({
    required this.province,
    required this.controller,
  });

  final Province province;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final attackableFrom = controller.getAttackableProvinces(province.id);

    if (attackableFrom.isEmpty) {
      return Text(
        'この州への攻撃はできません\n（隣接する自軍領土がありません）',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '以下の州から攻撃できます:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ...attackableFrom.map((sourceProvince) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _ActionButton(
              icon: Icons.gps_fixed,
              label: '${sourceProvince.name}から攻撃',
              onPressed: sourceProvince.currentTroops >= 1000
                  ? () {
                      _showAttackConfirmation(
                        context,
                        sourceProvince,
                        province,
                        controller,
                      );
                    }
                  : null,
              color: Colors.red,
            ),
          );
        }),
      ],
    );
  }

  void _showAttackConfirmation(
    BuildContext context,
    Province source,
    Province target,
    WaterMarginGameController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('攻撃確認'),
        content: Text(
          '${source.name}（兵力${source.currentTroops}）から\n${target.name}（兵力${target.currentTroops}）に攻撃しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final success = controller.attackProvince(target.id, source.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '攻撃成功！' : '攻撃失敗...'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('攻撃'),
          ),
        ],
      ),
    );
  }
}

/// アクションボタン
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
      ),
    );
  }
}
