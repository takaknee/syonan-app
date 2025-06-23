/// 施設管理パネル
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/water_margin_game_controller.dart';
import '../../models/province_facility.dart';
import '../../models/water_margin_strategy_game.dart';
import '../../services/facility_service.dart';

/// 選択された州の施設管理を行うパネル
class FacilityManagementPanel extends StatefulWidget {
  const FacilityManagementPanel({
    super.key,
    required this.province,
  });

  final Province province;

  @override
  State<FacilityManagementPanel> createState() => _FacilityManagementPanelState();
}

class _FacilityManagementPanelState extends State<FacilityManagementPanel> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final provinceFacilities = widget.province.facilities ?? const ProvinceFacilities();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 既存施設の表示
              _ExistingFacilitiesSection(
                facilities: provinceFacilities,
                controller: controller,
              ),
              const SizedBox(height: 24),

              // 建設可能な施設の表示
              _AvailableFacilitiesSection(
                province: widget.province,
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 既存施設セクション
class _ExistingFacilitiesSection extends StatelessWidget {
  const _ExistingFacilitiesSection({
    required this.facilities,
    required this.controller,
  });

  final ProvinceFacilities facilities;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final completedFacilities = facilities.facilities;
    final inProgressProjects = facilities.constructionProjects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏗️ 既存施設',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // 完成した施設
        if (completedFacilities.isEmpty && inProgressProjects.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('まだ施設が建設されていません'),
            ),
          ),

        // 完成した施設の表示
        ...completedFacilities.entries.map((entry) => _CompletedFacilityCard(
              facility: entry.value,
              controller: controller,
            )),

        // 建設中の施設の表示
        ...inProgressProjects.map((project) => _ConstructionProjectCard(
              project: project,
              controller: controller,
            )),
      ],
    );
  }
}

/// 完成した施設カード
class _CompletedFacilityCard extends StatelessWidget {
  const _CompletedFacilityCard({
    required this.facility,
    required this.controller,
  });

  final Facility facility;
  final WaterMarginGameController controller;

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
                  facility.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${facility.name} Lv.${facility.level}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        facility.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (facility.canUpgrade())
                  ElevatedButton(
                    onPressed: () => _showUpgradeConfirmation(context),
                    child: Text('Lv.${facility.level + 1}に強化'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 施設状態
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🏠 建設完了',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),
            // 施設効果
            _FacilityEffectsDisplay(facility: facility),
          ],
        ),
      ),
    );
  }

  void _showUpgradeConfirmation(BuildContext context) {
    final upgraded = facility.upgraded();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${facility.name}を強化'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${facility.name}をLv.${upgraded.level}に強化しますか？'),
            const SizedBox(height: 16),
            const Text(
              '強化費用:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...upgraded.buildCost.entries.map((entry) => Text(
                  '${_getResourceNameFromEffects(entry.key)}: ${entry.value}',
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 施設アップグレード機能を実装
              Navigator.of(context).pop();
            },
            child: const Text('強化開始'),
          ),
        ],
      ),
    );
  }
}

/// 建設中のプロジェクトカード
class _ConstructionProjectCard extends StatelessWidget {
  const _ConstructionProjectCard({
    required this.project,
    required this.controller,
  });

  final ConstructionProject project;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final template = FacilityService.getFacilityTemplate(project.facilityType);
    if (template == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  template.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        template.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 建設キャンセル機能を実装
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('建設中止'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 建設進行状況
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🚧 建設中',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _getConstructionProgress(template),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                const SizedBox(height: 4),
                Text(
                  '残り ${_getRemainingTurns(template)} ターン',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getConstructionProgress(Facility template) {
    // TODO: 実際の建設進行状況を計算
    return 0.3; // 仮の値
  }

  int _getRemainingTurns(Facility template) {
    // TODO: 実際の残りターン数を計算
    return template.buildTime - 1; // 仮の値
  }
}

/// 建設可能な施設セクション
class _AvailableFacilitiesSection extends StatelessWidget {
  const _AvailableFacilitiesSection({
    required this.province,
    required this.controller,
  });

  final Province province;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    // 利用可能な施設タイプ（基本的な施設のみ）
    final availableTypes = [
      FacilityType.barracks,
      FacilityType.market,
      FacilityType.academy,
      FacilityType.temple,
    ];

    final provinceFacilities = province.facilities ?? const ProvinceFacilities();
    final alreadyBuilt = provinceFacilities.facilities.keys.toSet();
    final inConstruction = provinceFacilities.constructionProjects.map((p) => p.facilityType).toSet();

    final availableTemplates = availableTypes
        .where((type) => !alreadyBuilt.contains(type) && !inConstruction.contains(type))
        .map((type) => FacilityService.getFacilityTemplate(type))
        .where((template) => template != null)
        .cast<Facility>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏗️ 建設可能な施設',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (availableTemplates.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('現在建設可能な施設はありません'),
            ),
          )
        else
          ...availableTemplates.map((template) => _AvailableFacilityCard(
                template: template,
                province: province,
                controller: controller,
              )),
      ],
    );
  }
}

/// 建設可能な施設カード
class _AvailableFacilityCard extends StatelessWidget {
  const _AvailableFacilityCard({
    required this.template,
    required this.province,
    required this.controller,
  });

  final Facility template;
  final Province province;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final goldCost = template.buildCost[ResourceType.gold] ?? 0;
    final canAfford = controller.gameState.playerGold >= goldCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  template.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        template.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: canAfford ? () => _showBuildConfirmation(context) : null,
                  child: Text('建設 ($goldCost💰)'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 建設情報
            Row(
              children: [
                _InfoChip(
                  icon: Icons.schedule,
                  label: '${template.buildTime}ターン',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.attach_money,
                  label: '$goldCost💰',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 施設効果
            _FacilityEffectsDisplay(facility: template),

            if (!canAfford) const SizedBox(height: 8),
            if (!canAfford)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '資金が不足しています',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBuildConfirmation(BuildContext context) {
    final goldCost = template.buildCost[ResourceType.gold] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${template.name}を建設'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${province.name}に${template.name}を建設しますか？'),
            const SizedBox(height: 16),
            Text('建設費用: $goldCost💰'),
            Text('建設期間: ${template.buildTime}ターン'),
            const SizedBox(height: 16),
            const Text(
              '建設効果:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _FacilityEffectsDisplay(facility: template),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.startFacilityConstruction(province.id, template.type);
              Navigator.of(context).pop();
            },
            child: const Text('建設開始'),
          ),
        ],
      ),
    );
  }
}

/// 施設効果表示ウィジェット
class _FacilityEffectsDisplay extends StatelessWidget {
  const _FacilityEffectsDisplay({required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...facility.effects.entries.map((entry) => _EffectItem(
              icon: _getResourceIcon(entry.key),
              text: '${_getResourceName(entry.key)} +${entry.value}',
            )),
        ...facility.specialEffects.entries.map((entry) => _EffectItem(
              icon: '⭐',
              text: '${entry.key}: ${entry.value}',
            )),
      ],
    );
  }

  String _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.gold:
        return '�';
      case ResourceType.food:
        return '🌾';
      case ResourceType.wood:
        return '🪵';
      case ResourceType.iron:
        return '⚒️';
      case ResourceType.military:
        return '⚔️';
      case ResourceType.culture:
        return '📚';
      case ResourceType.population:
        return '👥';
    }
  }

  String _getResourceName(ResourceType type) {
    switch (type) {
      case ResourceType.gold:
        return '金';
      case ResourceType.food:
        return '食料';
      case ResourceType.wood:
        return '木材';
      case ResourceType.iron:
        return '鉄';
      case ResourceType.military:
        return '軍事力';
      case ResourceType.culture:
        return '文化';
      case ResourceType.population:
        return '人口';
    }
  }
}

/// 効果項目
class _EffectItem extends StatelessWidget {
  const _EffectItem({
    required this.icon,
    required this.text,
  });

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// 情報チップ
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

String _getResourceNameFromEffects(ResourceType type) {
  switch (type) {
    case ResourceType.gold:
      return '金';
    case ResourceType.food:
      return '食料';
    case ResourceType.wood:
      return '木材';
    case ResourceType.iron:
      return '鉄';
    case ResourceType.military:
      return '軍事力';
    case ResourceType.culture:
      return '文化';
    case ResourceType.population:
      return '人口';
  }
}
