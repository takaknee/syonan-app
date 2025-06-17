import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../services/mini_game_service.dart';

/// 街づくりゲーム画面
class CityBuilderGameScreen extends StatefulWidget {
  const CityBuilderGameScreen({super.key});

  @override
  State<CityBuilderGameScreen> createState() => _CityBuilderGameScreenState();
}

class _CityBuilderGameScreenState extends State<CityBuilderGameScreen> {
  int _score = 0;
  int _population = 0;
  int _buildings = 0;
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
      _population = 0;
      _buildings = 0;
    });
  }

  void _completeGame() {
    if (_isGameComplete) return;

    setState(() {
      _isGameComplete = true;
    });

    final duration = DateTime.now().difference(_startTime);
    final finalScore = _score +
        (_population * 10) +
        (_buildings * 50) +
        (1000 - duration.inSeconds).clamp(0, 1000);

    // スコアを記録
    final miniGameService =
        Provider.of<MiniGameService>(context, listen: false);
    miniGameService.recordScore(
        'city_builder', finalScore, MiniGameDifficulty.hard);

    _showGameCompleteDialog(finalScore);
  }

  void _showGameCompleteDialog(int finalScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🏆 街づくり完了！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('最終スコア: $finalScore点'),
            const SizedBox(height: 8),
            Text('人口: $_population人'),
            const SizedBox(height: 4),
            Text('建物数: $_buildings棟'),
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
            child: const Text('新しい街づくり'),
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
        title: const Text('街づくり'),
        backgroundColor: const Color(0xFF607D8B),
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
                color: const Color(0xFF607D8B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'スコア',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '$_score',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '人口',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '$_population',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '建物',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '$_buildings',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
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
                      '🏙️',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '街づくり',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '理想の街を建設するシミュレーション\nゲームです。\n近日公開予定！',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isGameComplete ? null : _completeGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF607D8B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
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
