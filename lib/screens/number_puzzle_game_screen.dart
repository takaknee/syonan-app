import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../services/mini_game_service.dart';

/// 数字パズルゲーム画面
class NumberPuzzleGameScreen extends StatefulWidget {
  const NumberPuzzleGameScreen({super.key});

  @override
  State<NumberPuzzleGameScreen> createState() => _NumberPuzzleGameScreenState();
}

class _NumberPuzzleGameScreenState extends State<NumberPuzzleGameScreen> {
  int _score = 0;
  int _level = 1;
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
      _level = 1;
    });
  }

  void _completeGame() {
    if (_isGameComplete) return;

    setState(() {
      _isGameComplete = true;
    });

    final duration = DateTime.now().difference(_startTime);
    final finalScore = _score + (1000 - duration.inSeconds).clamp(0, 1000);

    // スコアを記録
    final miniGameService = Provider.of<MiniGameService>(context, listen: false);
    miniGameService.recordScore('number_puzzle', finalScore, MiniGameDifficulty.normal);

    _showGameCompleteDialog(finalScore);
  }

  void _showGameCompleteDialog(int finalScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 ゲームクリア！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('最終スコア: $finalScore点'),
            const SizedBox(height: 8),
            Text('レベル: $_level'),
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
            child: const Text('もう一度'),
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
        title: const Text('数字パズル'),
        backgroundColor: const Color(0xFF795548),
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
                color: const Color(0xFF795548).withValues(alpha: 0.1),
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
                    'レベル: $_level',
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
                      '🔢',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '数字パズル',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '数字を使った論理パズルゲームです。\n近日公開予定！',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isGameComplete ? null : _completeGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF795548),
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
