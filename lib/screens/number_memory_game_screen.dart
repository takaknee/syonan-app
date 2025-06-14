import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../services/mini_game_service.dart';
import '../services/points_service.dart';

/// 数字記憶ゲーム画面
class NumberMemoryGameScreen extends StatefulWidget {
  const NumberMemoryGameScreen({super.key});

  @override
  State<NumberMemoryGameScreen> createState() => _NumberMemoryGameScreenState();
}

class _NumberMemoryGameScreenState extends State<NumberMemoryGameScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  List<int> _sequence = [];
  String _userInput = '';
  int _currentLevel = 1;
  int _score = 0;
  bool _showingSequence = false;
  bool _isGameOver = false;
  bool _isInputPhase = false;

  final Random _random = Random();
  final int _maxLevel = 10;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _startGame();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startGame() {
    _generateSequence();
    _showSequence();
  }

  void _generateSequence() {
    _sequence = List.generate(_currentLevel + 2, (index) => _random.nextInt(10));
  }

  void _showSequence() async {
    setState(() {
      _showingSequence = true;
      _isInputPhase = false;
      _userInput = '';
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    for (int i = 0; i < _sequence.length; i++) {
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 800));
      _fadeController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _showingSequence = false;
      _isInputPhase = true;
    });
  }

  void _onNumberPressed(int number) {
    if (!_isInputPhase || _isGameOver) return;

    setState(() {
      _userInput += number.toString();
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    if (_userInput.length == _sequence.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final correctSequence = _sequence.join();
    if (_userInput == correctSequence) {
      // 正解
      setState(() {
        _score += _currentLevel * 10;
        _currentLevel++;
      });

      if (_currentLevel > _maxLevel) {
        _endGame(true);
      } else {
        _showCorrectFeedback();
      }
    } else {
      // 不正解
      _endGame(false);
    }
  }

  void _showCorrectFeedback() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'せいかい！ レベル $_currentLevel へ進みます',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    _startGame();
  }

  void _endGame(bool completed) async {
    setState(() {
      _isGameOver = true;
    });

    // スコアを記録
    final miniGameService = context.read<MiniGameService>();
    await miniGameService.recordScore(
      'number_memory',
      _score,
      MiniGameDifficulty.easy,
    );

    _showGameOverDialog(completed);
  }

  void _showGameOverDialog(bool completed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(completed ? 'ゲームクリア！' : 'ゲーム終了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              completed ? Icons.emoji_events : Icons.psychology,
              size: 48,
              color: completed ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'レベル: $_currentLevel',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'スコア: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (completed) ...[
              const SizedBox(height: 8),
              const Text(
                '全レベルクリアおめでとう！',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
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
              _resetGame();
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  void _resetGame() async {
    // ポイントを再消費
    final pointsService = context.read<PointsService>();
    final success = await pointsService.spendPoints(10);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ポイントが足りません'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentLevel = 1;
      _score = 0;
      _isGameOver = false;
      _userInput = '';
    });
    _startGame();
  }

  void _deleteLastInput() {
    if (_userInput.isNotEmpty) {
      setState(() {
        _userInput = _userInput.substring(0, _userInput.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('数字おぼえゲーム'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'スコア: $_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // レベル表示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'レベル $_currentLevel',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '覚える数字: ${_sequence.length}個',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // メイン表示エリア
            Expanded(
              child: _buildMainContent(theme),
            ),

            // 数字入力キーパッド
            if (_isInputPhase && !_isGameOver) _buildKeypad(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    if (_showingSequence) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '数字を覚えてください',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                final currentIndex = (_fadeController.value * _sequence.length).floor();
                final displayNumber = currentIndex < _sequence.length ? _sequence[currentIndex].toString() : '';

                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      displayNumber,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (_isInputPhase) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '覚えた順番に数字を入力してください',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _userInput.isEmpty ? '入力してください' : _userInput,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _userInput.isEmpty
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${_userInput.length} / ${_sequence.length}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildKeypad(ThemeData theme) {
    return Column(
      children: [
        // 数字ボタン 0-9
        for (int row = 0; row < 4; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (row < 3)
                  for (int col = 0; col < 3; col++) _buildNumberButton(row * 3 + col + 1, theme)
                else ...[
                  _buildDeleteButton(theme),
                  _buildNumberButton(0, theme),
                  const SizedBox(width: 60), // Empty space for symmetry
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNumberButton(int number, ThemeData theme) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scaleController.value * 0.1),
          child: SizedBox(
            width: 60,
            height: 60,
            child: ElevatedButton(
              onPressed: () => _onNumberPressed(number),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(ThemeData theme) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: _deleteLastInput,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: const Icon(Icons.backspace),
      ),
    );
  }
}
