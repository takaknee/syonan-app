import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../services/mini_game_service.dart';

/// スライドパズルゲーム画面
class SlidingPuzzleGameScreen extends StatefulWidget {
  const SlidingPuzzleGameScreen({super.key});

  @override
  State<SlidingPuzzleGameScreen> createState() => _SlidingPuzzleGameScreenState();
}

class _SlidingPuzzleGameScreenState extends State<SlidingPuzzleGameScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _successController;

  List<int> _puzzle = [];
  int _emptyIndex = 15; // 4x4 puzzle, empty tile at bottom right
  int _moves = 0;
  bool _isGameComplete = false;
  bool _isGameStarted = false;
  late DateTime _startTime;

  final Random _random = Random();
  final int _gridSize = 4;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initializePuzzle();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _initializePuzzle() {
    // Initialize with solved state (1-15, 0 for empty)
    _puzzle = List.generate(16, (index) => index == 15 ? 0 : index + 1);
    _shufflePuzzle();
  }

  void _shufflePuzzle() {
    // Shuffle by making random valid moves to ensure solvability
    for (int i = 0; i < 1000; i++) {
      final validMoves = _getValidMoves();
      if (validMoves.isNotEmpty) {
        final randomMove = validMoves[_random.nextInt(validMoves.length)];
        _makeMove(randomMove, animate: false);
      }
    }
    _moves = 0;
    _isGameStarted = false;
  }

  List<int> _getValidMoves() {
    final moves = <int>[];
    final row = _emptyIndex ~/ _gridSize;
    final col = _emptyIndex % _gridSize;

    // Up
    if (row > 0) moves.add(_emptyIndex - _gridSize);
    // Down
    if (row < _gridSize - 1) moves.add(_emptyIndex + _gridSize);
    // Left
    if (col > 0) moves.add(_emptyIndex - 1);
    // Right
    if (col < _gridSize - 1) moves.add(_emptyIndex + 1);

    return moves;
  }

  void _makeMove(int tileIndex, {bool animate = true}) {
    if (_isGameComplete) return;

    final validMoves = _getValidMoves();
    if (!validMoves.contains(tileIndex)) return;

    if (!_isGameStarted) {
      _isGameStarted = true;
      _startTime = DateTime.now();
    }

    setState(() {
      // Swap tile with empty space
      final temp = _puzzle[tileIndex];
      _puzzle[tileIndex] = _puzzle[_emptyIndex];
      _puzzle[_emptyIndex] = temp;
      _emptyIndex = tileIndex;
      _moves++;
    });

    if (animate) {
      _slideController.forward().then((_) => _slideController.reset());
    }

    _checkWin();
  }

  void _checkWin() {
    bool isComplete = true;
    for (int i = 0; i < 15; i++) {
      if (_puzzle[i] != i + 1) {
        isComplete = false;
        break;
      }
    }

    if (isComplete && _puzzle[15] == 0) {
      _isGameComplete = true;
      _successController.forward();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    final duration = DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    // Calculate score based on moves and time
    const baseScore = 1000;
    final movesPenalty = _moves * 5;
    final timePenalty = duration.inSeconds;
    final score = (baseScore - movesPenalty - timePenalty).clamp(100, baseScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text('パズル完成！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉 おめでとうございます！'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('スコア:'),
                      Text(
                        '$score点',
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
                      const Text('手数:'),
                      Text('$_moves手'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('時間:'),
                      Text('$minutes分$seconds秒'),
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
                    'sliding_puzzle',
                    score,
                    MiniGameDifficulty.easy,
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
      _isGameComplete = false;
      _isGameStarted = false;
      _moves = 0;
    });
    _successController.reset();
    _initializePuzzle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('🧩 スライドパズル'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'リセット',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Score section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.touch_app),
                      const SizedBox(height: 4),
                      Text(
                        '手数',
                        style: theme.textTheme.labelSmall,
                      ),
                      Text(
                        '$_moves',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  if (_isGameStarted) ...[
                    Column(
                      children: [
                        const Icon(Icons.timer),
                        const SizedBox(height: 4),
                        Text(
                          '時間',
                          style: theme.textTheme.labelSmall,
                        ),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final elapsed = DateTime.now().difference(_startTime);
                            final minutes = elapsed.inMinutes;
                            final seconds = elapsed.inSeconds % 60;
                            return Text(
                              '$minutes:$seconds.toString().padLeft(2, '0')}',
                              style: theme.textTheme.headlineSmall,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Instruction
            if (!_isGameStarted)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '数字を1-15の順番に並べよう！\n空いているマスの隣のタイルをタップして移動できます。',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

            // Puzzle grid
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        final value = _puzzle[index];
                        final isEmpty = value == 0;

                        return AnimatedBuilder(
                          animation: _slideController,
                          builder: (context, child) {
                            return GestureDetector(
                              onTap: isEmpty ? null : () => _makeMove(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isEmpty ? Colors.transparent : theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isEmpty
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: isEmpty
                                    ? null
                                    : Center(
                                        child: Text(
                                          '$value',
                                          style: theme.textTheme.headlineMedium?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
