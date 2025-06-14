import 'package:flutter/material.dart';

import '../models/mini_game.dart';

/// ミニゲーム選択ボタンウィジェット
class MiniGameButton extends StatelessWidget {
  const MiniGameButton({
    super.key,
    required this.miniGame,
    required this.onTap,
    required this.hasEnoughPoints,
    this.playCount = 0,
    this.bestScore = 0,
  });

  final MiniGame miniGame;
  final VoidCallback onTap;
  final bool hasEnoughPoints;
  final int playCount;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColor = Color(miniGame.color);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: hasEnoughPoints ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: hasEnoughPoints
                  ? [
                      gameColor.withValues(alpha: 0.1),
                      gameColor.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.grey.withValues(alpha: 0.1),
                      Colors.grey.withValues(alpha: 0.05),
                    ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasEnoughPoints ? gameColor : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  miniGame.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                miniGame.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasEnoughPoints ? gameColor : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                miniGame.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasEnoughPoints ? gameColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasEnoughPoints ? gameColor : Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: hasEnoughPoints ? gameColor : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${miniGame.pointsCost}P',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasEnoughPoints ? gameColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (playCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$playCount回',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (bestScore > 0) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '最高: $bestScore',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (!hasEnoughPoints) ...[
                const SizedBox(height: 8),
                Text(
                  'ポイントが足りません',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
