import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../services/mini_game_service.dart';

/// 戦略バトルゲーム画面
class StrategyBattleGameScreen extends StatefulWidget {
  const StrategyBattleGameScreen({super.key});

  @override
  State<StrategyBattleGameScreen> createState() => _StrategyBattleGameScreenState();
}

class _StrategyBattleGameScreenState extends State<StrategyBattleGameScreen> {
  int _score = 0;
  int _enemiesDefeated = 0;
  bool _isGameComplete = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _startTime = DateTime.now();
      _score = 0;
      _enemiesDefeated = 0;
    });
  }

  void _completeGame() {
    if (_isGameComplete) return;

    setState(() {
      _isGameComplete = true;
    });

    final duration = DateTime.now().difference(_startTime);
    final finalScore = _score + (_enemiesDefeated * 100) + (1000 - duration.inSeconds).clamp(0, 1000);

    // スコアを記録
    final miniGameService = Provider.of<MiniGameService>(context, listen: false);
    miniGameService.recordScore('strategy_battle', finalScore, MiniGameDifficulty.hard);

    _showGameCompleteDialog(finalScore);
  }

  void _showGameCompleteDialog(int finalScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🏆 戦闘終了！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('最終スコア: $finalScore点'),
            const SizedBox(height: 8),
            Text('撃破数: $_enemiesDefeated体'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ホームに戻る'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('再戦'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _isGameComplete = false;
    });
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('戦略バトル'),
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // スコア表示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'スコア: $_score',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '撃破: $_enemiesDefeated',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ゲーム説明
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '⚔️',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '戦略バトル',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '敵を倒すための戦略を練り、\n勝利を目指すゲームです。\n近日公開予定！',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isGameComplete ? null : _completeGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('デモスコア獲得'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
