import 'package:flutter/material.dart';

import '../../../models/strategy_game.dart';
import '../../../services/strategy_game_service.dart';

/// ゲーム情報パネルWidget
class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({
    super.key,
    required this.gameState,
  });

  final StrategyGameState gameState;

  @override
  Widget build(BuildContext context) {
    final totalTerritories = gameState.territories.length;
    final playerPercent = gameState.playerTerritoryCount / totalTerritories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8BC34A).withValues(alpha: 0.1),
        border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                emoji: '💰',
                value: '${gameState.playerGold}',
                label: '金',
              ),
              _InfoItem(
                emoji: '⚔️',
                value: '${gameState.playerTroops}',
                label: '兵力',
              ),
              _InfoItem(
                emoji: '🏰',
                value: '${gameState.playerTerritoryCount}',
                label: '領土',
              ),
              _InfoItem(
                emoji: '📅',
                value: '${gameState.currentTurn}/${StrategyGameService.maxTurns}',
                label: 'ターン',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 支配状況を表示
          _DominationProgress(
            playerPercent: playerPercent,
            totalTerritories: totalTerritories,
            gameState: gameState,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _DominationProgress extends StatelessWidget {
  const _DominationProgress({
    required this.playerPercent,
    required this.totalTerritories,
    required this.gameState,
  });

  final double playerPercent;
  final int totalTerritories;
  final StrategyGameState gameState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('支配状況: ', style: TextStyle(fontSize: 12)),
        Expanded(
          child: LinearProgressIndicator(
            value: playerPercent,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(gameState.playerTerritoryCount / totalTerritories * 100).round()}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
