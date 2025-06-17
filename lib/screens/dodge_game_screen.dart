import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../services/mini_game_service.dart';

/// ドッジゲーム画面
class DodgeGameScreen extends StatefulWidget {
  const DodgeGameScreen({super.key});

  @override
  State<DodgeGameScreen> createState() => _DodgeGameScreenState();
}

class _DodgeGameScreenState extends State<DodgeGameScreen> with TickerProviderStateMixin {
  late AnimationController _gameController;
  late AnimationController _explosionController;

  Timer? _gameTimer;
  Timer? _obstacleTimer;
  bool _isPlaying = false;
  int _score = 0;
  double _timeLeft = 60.0; // 60 seconds game

  // Player position
  double _playerX = 0.5; // Center of screen (0.0 to 1.0)
  final double _playerY = 0.8; // Near bottom
  final double _playerSize = 0.08;

  // Obstacles
  final List<Obstacle> _obstacles = [];
  final Random _random = Random();
  double _obstacleSpeed = 2.0; // pixels per frame
  double _spawnRate = 2000; // milliseconds between spawns

  // Game state
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _obstacleTimer?.cancel();
    _gameController.dispose();
    _explosionController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _gameStarted = true;
      _score = 0;
      _timeLeft = 60.0;
      _obstacles.clear();
      _playerX = 0.5;
      _obstacleSpeed = 2.0;
      _spawnRate = 2000;
    });

    // Start game timer (countdown)
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timeLeft -= 0.1;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    // Start obstacle spawning
    _startObstacleSpawning();

    // Start game loop
    _gameController.repeat();
    _gameLoop();
  }

  void _startObstacleSpawning() {
    _obstacleTimer = Timer.periodic(Duration(milliseconds: _spawnRate.round()), (timer) {
      if (!_isPlaying) return;

      _spawnObstacle();

      // Increase difficulty over time
      if (_spawnRate > 800) {
        _spawnRate -= 50;
        _obstacleSpeed += 0.1;
      }
    });
  }

  void _spawnObstacle() {
    final x = _random.nextDouble();
    final size = 0.04 + _random.nextDouble() * 0.04; // Random size between 0.04 and 0.08
    final speed = _obstacleSpeed + _random.nextDouble() * 1.0;

    final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.purple];
    final color = colors[_random.nextInt(colors.length)];

    _obstacles.add(Obstacle(
      x: x,
      y: -0.1,
      size: size,
      speed: speed,
      color: color,
    ));
  }

  void _gameLoop() {
    if (!_isPlaying) return;

    setState(() {
      // Update obstacles
      _obstacles.removeWhere((obstacle) {
        obstacle.y += obstacle.speed / 100;

        // Remove obstacles that are off screen
        if (obstacle.y > 1.1) {
          _score += 10; // Points for surviving
          return true;
        }

        // Check collision with player
        if (_checkCollision(obstacle)) {
          _gameOver();
          return true;
        }

        return false;
      });
    });

    // Continue game loop
    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 16), _gameLoop);
    }
  }

  bool _checkCollision(Obstacle obstacle) {
    final dx = _playerX - obstacle.x;
    final dy = _playerY - obstacle.y;
    final distance = sqrt(dx * dx + dy * dy);
    final minDistance = (_playerSize + obstacle.size) / 2;

    return distance < minDistance;
  }

  void _gameOver() {
    _explosionController.forward();
    _endGame();
  }

  void _endGame() {
    _gameTimer?.cancel();
    _obstacleTimer?.cancel();

    setState(() {
      _isPlaying = false;
    });

    _gameController.stop();

    // Add time bonus to score
    final timeBonus = (_timeLeft * 5).round();
    _score += timeBonus;

    Future.delayed(const Duration(milliseconds: 500), () {
      _showResultDialog();
    });
  }

  void _showResultDialog() {
    final survivedTime = 60.0 - _timeLeft;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sports_esports, color: Colors.blue, size: 32),
            SizedBox(width: 8),
            Text('ゲーム終了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_timeLeft <= 0 ? '🎉 時間切れまで生き延びた！' : '💥 障害物に当たった！'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('スコア:'),
                      Text(
                        '$_score点',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('生存時間:'),
                      Text('${survivedTime.toStringAsFixed(1)}秒'),
                    ],
                  ),
                  if (_timeLeft <= 0) ...[
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '完全クリア！',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('終了'),
          ),
          ElevatedButton(
            onPressed: () async {
              // BuildContextを先に取得
              if (!mounted) return;
              final navigator = Navigator.of(context);
              final miniGameService = context.read<MiniGameService>();

              // Record score
              await miniGameService.recordScore(
                'dodge_game',
                _score,
                MiniGameDifficulty.easy,
              );

              if (!mounted) return;
              navigator.pop();
              _resetGame();
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _isPlaying = false;
      _gameStarted = false;
      _score = 0;
      _timeLeft = 60.0;
      _obstacles.clear();
      _playerX = 0.5;
      _obstacleSpeed = 2.0;
      _spawnRate = 2000;
    });
    _explosionController.reset();
  }

  void _movePlayer(double deltaX) {
    setState(() {
      _playerX = (_playerX + deltaX).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('🎯 ドッジゲーム'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.withValues(alpha: 0.8),
              Colors.blue.withValues(alpha: 0.6),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Score section
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow),
                        const SizedBox(height: 4),
                        const Text(
                          'スコア',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '$_score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.timer, color: Colors.blue),
                        const SizedBox(height: 4),
                        const Text(
                          '残り時間',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '${_timeLeft.toStringAsFixed(1)}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Game area
            Expanded(
              child: !_gameStarted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videogame_asset,
                            size: 80,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'ドッジゲーム',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '画面をタップ・ドラッグして\n'
                              '落ちてくる障害物を避けよう！\n'
                              '60秒間生き延びることができるかな？',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                            ),
                            child: const Text(
                              'ゲーム開始',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onPanUpdate: (details) {
                        if (!_isPlaying) return;
                        final deltaX = details.delta.dx / screenSize.width;
                        _movePlayer(deltaX);
                      },
                      onTapDown: (details) {
                        if (!_isPlaying) return;
                        final tapX = details.localPosition.dx / screenSize.width;
                        final deltaX = tapX - _playerX;
                        _movePlayer(deltaX * 0.3); // Smooth movement
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          children: [
                            // Obstacles
                            ..._obstacles.map((obstacle) => Positioned(
                                  left: obstacle.x * screenSize.width - (obstacle.size * screenSize.width / 2),
                                  top: obstacle.y * (screenSize.height - 200) - (obstacle.size * screenSize.width / 2),
                                  child: Container(
                                    width: obstacle.size * screenSize.width,
                                    height: obstacle.size * screenSize.width,
                                    decoration: BoxDecoration(
                                      color: obstacle.color,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: obstacle.color.withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),

                            // Player
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 100),
                              left: _playerX * screenSize.width - (_playerSize * screenSize.width / 2),
                              top: _playerY * (screenSize.height - 200) - (_playerSize * screenSize.width / 2),
                              child: AnimatedBuilder(
                                animation: _explosionController,
                                builder: (context, child) {
                                  if (_explosionController.value > 0) {
                                    return Container(
                                      width: _playerSize * screenSize.width * (1 + _explosionController.value * 2),
                                      height: _playerSize * screenSize.width * (1 + _explosionController.value * 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 1 - _explosionController.value),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: _playerSize * screenSize.width,
                                    height: _playerSize * screenSize.width,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue,
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Obstacle {
  Obstacle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;
}
