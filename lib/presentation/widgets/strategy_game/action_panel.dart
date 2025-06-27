import 'package:flutter/material.dart';

import '../../../models/strategy_game.dart';
import '../../../services/strategy_game_service.dart';

/// アクションパネルWidget
class ActionPanel extends StatelessWidget {
  const ActionPanel({
    super.key,
    required this.gameState,
    required this.gameService,
    required this.onRecruitTroops,
    required this.onAttackTerritory,
    required this.onEndTurn,
  });

  final StrategyGameState gameState;
  final StrategyGameService gameService;
  final Function(String territoryId, int amount) onRecruitTroops;
  final Function(String attackerId, String defenderId) onAttackTerritory;
  final VoidCallback onEndTurn;

  @override
  Widget build(BuildContext context) {
    final selectedTerritory = gameState.selectedTerritory;

    if (selectedTerritory == null) {
      return const _EmptySelectionPanel();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '選択中: ${selectedTerritory.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (selectedTerritory.owner == Owner.player)
            _PlayerTerritoryActions(
              territory: selectedTerritory,
              gameState: gameState,
              gameService: gameService,
              onRecruitTroops: onRecruitTroops,
              onAttackTerritory: onAttackTerritory,
            )
          else
            _EnemyTerritoryActions(territory: selectedTerritory),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onEndTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8BC34A),
              foregroundColor: Colors.white,
            ),
            child: const Text('ターン終了'),
          ),
        ],
      ),
    );
  }
}

class _EmptySelectionPanel extends StatelessWidget {
  const _EmptySelectionPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          '領土をタップして選択してください',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

class _PlayerTerritoryActions extends StatelessWidget {
  const _PlayerTerritoryActions({
    required this.territory,
    required this.gameState,
    required this.gameService,
    required this.onRecruitTroops,
    required this.onAttackTerritory,
  });

  final Territory territory;
  final StrategyGameState gameState;
  final StrategyGameService gameService;
  final Function(String territoryId, int amount) onRecruitTroops;
  final Function(String attackerId, String defenderId) onAttackTerritory;

  @override
  Widget build(BuildContext context) {
    final canRecruit = gameState.playerGold >= StrategyGameService.troopCost && territory.troops < territory.maxTroops;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TerritoryInfo(territory: territory),
        const SizedBox(height: 8),
        _RecruitmentButton(
          canRecruit: canRecruit,
          onRecruitTroops: () => onRecruitTroops(territory.id, 1),
        ),
        const SizedBox(height: 4),
        ..._buildAttackButtons(),
      ],
    );
  }

  List<Widget> _buildAttackButtons() {
    final attackableTargets = gameService.getAttackableTargets(gameState, territory.id);

    if (attackableTargets.isEmpty || territory.troops <= 1) {
      return [
        const Text(
          '攻撃可能な敵がいません',
          style: TextStyle(color: Colors.grey),
        )
      ];
    }

    return attackableTargets
        .map((target) => _AttackButton(
              territory: territory,
              target: target,
              onAttack: () => onAttackTerritory(territory.id, target.id),
            ))
        .toList();
  }
}

class _EnemyTerritoryActions extends StatelessWidget {
  const _EnemyTerritoryActions({required this.territory});

  final Territory territory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${territory.name} ${territory.terrainIcon}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          territory.terrainDescription,
          style: const TextStyle(fontSize: 12, color: Colors.orange),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('敵兵力: ${territory.troops}'),
            const Spacer(),
            if (territory.defenseBonus > 0)
              Text(
                '防御: +${territory.defenseBonus}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        if (territory.isCapital) ...[
          const SizedBox(height: 4),
          const Text(
            '👑 敵の首都 - 追加防御+5',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

class _TerritoryInfo extends StatelessWidget {
  const _TerritoryInfo({required this.territory});

  final Territory territory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${territory.name} ${territory.terrainIcon}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          territory.terrainDescription,
          style: const TextStyle(fontSize: 12, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('兵力: ${territory.troops}/${territory.maxTroops}'),
            const Spacer(),
            Text('収入: +${territory.incomePerTurn}金/ターン'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('資源: ${territory.resources}'),
            const Spacer(),
            if (territory.defenseBonus > 0)
              Text(
                '防御: +${territory.defenseBonus}',
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecruitmentButton extends StatelessWidget {
  const _RecruitmentButton({
    required this.canRecruit,
    required this.onRecruitTroops,
  });

  final bool canRecruit;
  final VoidCallback onRecruitTroops;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canRecruit ? onRecruitTroops : null,
            child: const Text('兵士募集 (${StrategyGameService.troopCost}金)'),
          ),
        ),
      ],
    );
  }
}

class _AttackButton extends StatelessWidget {
  const _AttackButton({
    required this.territory,
    required this.target,
    required this.onAttack,
  });

  final Territory territory;
  final Territory target;
  final VoidCallback onAttack;

  @override
  Widget build(BuildContext context) {
    final attackPower = territory.troops - 1; // 1部隊は残す
    final defenseTotal = target.troops + target.defenseBonus + (target.isCapital ? 5 : 0);
    final winChance = attackPower > defenseTotal
        ? '勝率: 高'
        : attackPower == defenseTotal
            ? '勝率: 互角'
            : '勝率: 低';

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ElevatedButton(
        onPressed: onAttack,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${target.name}を攻撃 ${target.terrainIcon}'),
            Text(
              '敵兵力${target.troops}+防御${target.defenseBonus} | $winChance',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
