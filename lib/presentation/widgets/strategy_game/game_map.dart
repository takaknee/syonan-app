import 'package:flutter/material.dart';

import '../../../models/strategy_game.dart';
import '../../../services/strategy_game_service.dart';

/// 領土タイルWidget
class TerritoryTile extends StatelessWidget {
  const TerritoryTile({
    super.key,
    required this.territory,
    required this.gameState,
    required this.gameService,
    required this.onTerritorySelected,
  });

  final Territory territory;
  final StrategyGameState gameState;
  final StrategyGameService gameService;
  final VoidCallback onTerritorySelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = gameState.selectedTerritoryId == territory.id;
    final isPlayerTerritory = territory.owner == Owner.player;
    final canAttack = isSelected &&
        isPlayerTerritory &&
        gameService.getAttackableTargets(gameState, territory.id).isNotEmpty;

    final territoryStyle =
        _TerritoryStyle.fromOwner(territory.owner, isSelected);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTerritorySelected,
        child: Container(
          decoration: BoxDecoration(
            color: territoryStyle.backgroundColor
                .withValues(alpha: isSelected ? 1.0 : 0.8),
            border: Border.all(
              color: territoryStyle.borderColor,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: territoryStyle.borderColor.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              if (canAttack) const _AttackIndicator(),
              Center(
                child: _TerritoryContent(
                  territory: territory,
                  ownerEmoji: territoryStyle.ownerEmoji,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TerritoryStyle {
  factory _TerritoryStyle.fromOwner(Owner owner, bool isSelected) {
    switch (owner) {
      case Owner.player:
        return _TerritoryStyle(
          backgroundColor: const Color(0xFF4CAF50),
          borderColor: isSelected ? Colors.lightBlue : Colors.green,
          ownerEmoji: '🟢',
        );
      case Owner.enemy:
        return _TerritoryStyle(
          backgroundColor: const Color(0xFFF44336),
          borderColor: isSelected ? Colors.lightBlue : Colors.red,
          ownerEmoji: '🔴',
        );
      case Owner.neutral:
        return _TerritoryStyle(
          backgroundColor: const Color(0xFF9E9E9E),
          borderColor: isSelected ? Colors.lightBlue : Colors.grey,
          ownerEmoji: '⚪',
        );
    }
  }
  const _TerritoryStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.ownerEmoji,
  });

  final Color backgroundColor;
  final Color borderColor;
  final String ownerEmoji;
}

class _AttackIndicator extends StatelessWidget {
  const _AttackIndicator();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 2,
      right: 2,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.flash_on,
          size: 8,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TerritoryContent extends StatelessWidget {
  const _TerritoryContent({
    required this.territory,
    required this.ownerEmoji,
  });

  final Territory territory;
  final String ownerEmoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (territory.isCapital) ...[
              const Text('👑', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 2),
            ],
            Text(ownerEmoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 2),
            Text(territory.terrainIcon, style: const TextStyle(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          territory.name,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '⚔️${territory.troops}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// ゲームマップWidget
class GameMap extends StatelessWidget {
  const GameMap({
    super.key,
    required this.gameState,
    required this.gameService,
    required this.onTerritorySelected,
  });

  final StrategyGameState gameState;
  final StrategyGameService gameService;
  final Function(String territoryId) onTerritorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: StrategyGameService.mapWidth,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: gameState.territories.length,
        itemBuilder: (context, index) {
          final territory = gameState.territories[index];
          return TerritoryTile(
            territory: territory,
            gameState: gameState,
            gameService: gameService,
            onTerritorySelected: () => onTerritorySelected(territory.id),
          );
        },
      ),
    );
  }
}
