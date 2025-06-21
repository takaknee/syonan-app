import 'package:flutter/material.dart';

/// チュートリアルオーバーレイWidget
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🏰 水滸伝 国盗り戦略 🏰',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const _TutorialContent(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onClose,
                  child: const Text('ゲーム開始！'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialContent extends StatelessWidget {
  const _TutorialContent();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '目標: 敵の首都（👑）を占領せよ！\n\n'
      '🟢 = あなたの領土\n'
      '🔴 = 敵の領土\n'
      '⚪ = 中立の領土\n\n'
      '1. 領土をタップして選択\n'
      '2. 隣接する敵領土を攻撃\n'
      '3. 金で兵士を募集\n'
      '4. ターン終了で資源獲得',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14),
    );
  }
}

/// ゲーム完了ダイアログ
class GameCompleteDialog extends StatelessWidget {
  const GameCompleteDialog({
    super.key,
    required this.isVictory,
    required this.finalScore,
    required this.gameState,
    required this.onRestartGame,
    required this.onReturnHome,
  });

  final bool isVictory;
  final int finalScore;
  final dynamic gameState; // StrategyGameState
  final VoidCallback onRestartGame;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isVictory ? '🏆 勝利！' : '😢 敗北...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('最終スコア: $finalScore点'),
          const SizedBox(height: 8),
          Text('支配領土: ${gameState.playerTerritoryCount}'),
          const SizedBox(height: 4),
          Text('ターン数: ${gameState.currentTurn}'),
          if (isVictory) ...[
            const SizedBox(height: 8),
            const Text('🎉 敵の首都を占領しました！'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onReturnHome,
          child: const Text('ホームに戻る'),
        ),
        ElevatedButton(
          onPressed: onRestartGame,
          child: const Text('再戦'),
        ),
      ],
    );
  }
}

/// 戦闘結果スナックバー
class BattleResultSnackBar {
  static void show(
    BuildContext context,
    String territoryName,
    bool victory,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          victory ? '🎉 $territoryNameを占領しました！' : '😓 $territoryNameの攻略に失敗...',
        ),
        backgroundColor: victory ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
