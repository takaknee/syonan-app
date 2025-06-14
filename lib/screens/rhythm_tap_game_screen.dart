import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../services/mini_game_service.dart';

/// リズムタップゲーム画面
class RhythmTapGameScreen extends StatefulWidget {
  const RhythmTapGameScreen({super.key});

  @override
  State<RhythmTapGameScreen> createState() => _RhythmTapGameScreenState();
}

class _RhythmTapGameScreenState extends State<RhythmTapGameScreen> with TickerProviderStateMixin {
  late AnimationController _beatController;
  late AnimationController _successController;
  late AnimationController _rippleController;

  Timer? _gameTimer;
  Timer? _beatTimer;
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _perfect = 0;
  int _good = 0;
  int _miss = 0;
  double _timeLeft = 60.0; // 60 seconds game

  // Beat timing
  final double _bpm = 120; // Beats per minute
  late double _beatInterval;
  DateTime? _lastBeatTime;
  bool _beatActive = false;

  final Random _random = Random();
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  Color _currentColor = Colors.red;
  int _currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _beatController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _beatInterval = 60000 / _bpm; // milliseconds per beat
    _currentColor = _colors[0];
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _beatTimer?.cancel();
    _beatController.dispose();
    _successController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _combo = 0;
      _maxCombo = 0;
      _perfect = 0;
      _good = 0;
      _miss = 0;
      _timeLeft = 60.0;
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

    // Start beat timer
    _startBeats();
  }

  void _startBeats() {
    _beatTimer = Timer.periodic(Duration(milliseconds: _beatInterval.round()), (timer) {
      if (!_isPlaying) return;

      setState(() {
        _lastBeatTime = DateTime.now();
        _beatActive = true;

        // Change color randomly
        _currentColorIndex = _random.nextInt(_colors.length);
        _currentColor = _colors[_currentColorIndex];
      });

      _beatController.forward().then((_) {
        _beatController.reverse();

        // Check if beat was missed after animation
        Timer(Duration(milliseconds: (_beatInterval * 0.3).round()), () {
          if (_beatActive) {
            _beatMissed();
          }
        });
      });
    });
  }

  void _onTap() {
    if (!_isPlaying || !_beatActive) {
      _beatMissed();
      return;
    }

    final now = DateTime.now();
    final timeDiff = now.difference(_lastBeatTime!).inMilliseconds;
    final perfectWindow = _beatInterval * 0.15; // 15% window for perfect
    final goodWindow = _beatInterval * 0.3; // 30% window for good

    if (timeDiff <= perfectWindow) {
      _hitPerfect();
    } else if (timeDiff <= goodWindow) {
      _hitGood();
    } else {
      _beatMissed();
    }

    _beatActive = false;
  }

  void _hitPerfect() {
    setState(() {
      _perfect++;
      _combo++;
      _maxCombo = max(_maxCombo, _combo);
      _score += 100 + (_combo * 10);
    });

    _successController.forward().then((_) => _successController.reverse());
    _rippleController.forward().then((_) => _rippleController.reset());
  }

  void _hitGood() {
    setState(() {
      _good++;
      _combo++;
      _maxCombo = max(_maxCombo, _combo);
      _score += 50 + (_combo * 5);
    });

    _rippleController.forward().then((_) => _rippleController.reset());
  }

  void _beatMissed() {
    setState(() {
      _miss++;
      _combo = 0;
      _beatActive = false;
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _beatTimer?.cancel();

    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    final totalHits = _perfect + _good;
    final totalBeats = _perfect + _good + _miss;
    final accuracy = totalBeats > 0 ? (totalHits / totalBeats * 100) : 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.music_note, color: Colors.pink, size: 32),
            SizedBox(width: 8),
            Text('ゲーム終了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎵 お疲れさまでした！'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.1),
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
                      const Text('最大コンボ:'),
                      Text('$_maxCombo'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('精度:'),
                      Text('${accuracy.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Perfect', style: TextStyle(color: Colors.green, fontSize: 12)),
                          Text('$_perfect'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Good', style: TextStyle(color: Colors.orange, fontSize: 12)),
                          Text('$_good'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Miss', style: TextStyle(color: Colors.red, fontSize: 12)),
                          Text('$_miss'),
                        ],
                      ),
                    ],
                  ),
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
              // Record score
              await context.read<MiniGameService>().recordScore(
                    'rhythm_tap',
                    _score,
                    MiniGameDifficulty.normal,
                  );

              if (!mounted) return;
              Navigator.of(context).pop();
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
      _isGameOver = false;
      _score = 0;
      _combo = 0;
      _maxCombo = 0;
      _perfect = 0;
      _good = 0;
      _miss = 0;
      _timeLeft = 60.0;
      _beatActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('🎵 リズムタップ'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.withValues(alpha: 0.3),
              Colors.pink.withValues(alpha: 0.3),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Score section
              Container(
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
                        const Icon(Icons.flash_on, color: Colors.orange),
                        const SizedBox(height: 4),
                        const Text(
                          'コンボ',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '$_combo',
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
              const SizedBox(height: 20),

              if (!_isPlaying && !_isGameOver) ...[
                // Start screen
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.pink,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'リズムタップ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '画面が光った瞬間にタップしよう！\n'
                            'タイミングが良いほど高得点！\n'
                            '60秒間でどれだけスコアを稼げるかな？',
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
                            backgroundColor: Colors.pink,
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
                  ),
                ),
              ] else if (_isPlaying) ...[
                // Game screen
                const SizedBox(height: 40),
                Expanded(
                  child: GestureDetector(
                    onTap: _onTap,
                    child: Stack(
                      children: [
                        // Main tap area
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: _currentColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _currentColor,
                              width: 3,
                            ),
                          ),
                          child: AnimatedBuilder(
                            animation: _beatController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: _beatActive
                                      ? _currentColor.withValues(alpha: 0.6 * _beatController.value)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Text(
                                    'TAP!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Success animation
                        AnimatedBuilder(
                          animation: _successController,
                          builder: (context, child) {
                            return _successController.value > 0
                                ? Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green.withValues(
                                          alpha: 1.0 - _successController.value,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'PERFECT!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),

                        // Ripple effect
                        AnimatedBuilder(
                          animation: _rippleController,
                          builder: (context, child) {
                            return _rippleController.value > 0
                                ? Center(
                                    child: Container(
                                      width: 200 * _rippleController.value,
                                      height: 200 * _rippleController.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _currentColor.withValues(
                                            alpha: 1.0 - _rippleController.value,
                                          ),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
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
