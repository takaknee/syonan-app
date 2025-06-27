import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/math_problem.dart';
import '../models/mini_game.dart';
import '../services/mini_game_service.dart';
import '../services/points_service.dart';

/// スピード計算ゲーム画面
class SpeedMathGameScreen extends StatefulWidget {
  const SpeedMathGameScreen({super.key});

  @override
  State<SpeedMathGameScreen> createState() => _SpeedMathGameScreenState();
}

class _SpeedMathGameScreenState extends State<SpeedMathGameScreen> with TickerProviderStateMixin {
  late Timer _gameTimer;
  late AnimationController _progressController;
  late AnimationController _feedbackController;

  int _timeLeft = 60; // 60秒間のゲーム
  int _score = 0;
  int _correctAnswers = 0;
  int _totalProblems = 0;
  bool _isGameActive = false;

  MathProblem? _currentProblem;
  String _userAnswer = '';

  final Random _random = Random();
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startGame();
  }

  @override
  void dispose() {
    if (_gameTimer.isActive) _gameTimer.cancel();
    _progressController.dispose();
    _feedbackController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _timeLeft = 60;
      _score = 0;
      _correctAnswers = 0;
      _totalProblems = 0;
    });

    _progressController.forward();
    _generateNewProblem();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
      });

      if (_timeLeft <= 0) {
        _endGame();
      }
    });
  }

  void _generateNewProblem() {
    final operations = [
      MathOperationType.addition,
      MathOperationType.subtraction,
      MathOperationType.multiplication,
    ];

    final operation = operations[_random.nextInt(operations.length)];

    int num1, num2;
    switch (operation) {
      case MathOperationType.addition:
        num1 = _random.nextInt(50) + 1;
        num2 = _random.nextInt(50) + 1;
        break;
      case MathOperationType.subtraction:
        num1 = _random.nextInt(50) + 20;
        num2 = _random.nextInt(num1 - 1) + 1;
        break;
      case MathOperationType.multiplication:
        num1 = _random.nextInt(9) + 1;
        num2 = _random.nextInt(9) + 1;
        break;
      case MathOperationType.division:
        num2 = _random.nextInt(9) + 1;
        num1 = num2 * (_random.nextInt(9) + 1);
        break;
    }

    final correctAnswer = switch (operation) {
      MathOperationType.addition => num1 + num2,
      MathOperationType.subtraction => num1 - num2,
      MathOperationType.multiplication => num1 * num2,
      MathOperationType.division => num1 ~/ num2,
    };

    setState(() {
      _currentProblem = MathProblem(
        firstNumber: num1,
        secondNumber: num2,
        operation: operation,
        correctAnswer: correctAnswer,
      );
      _userAnswer = '';
      _answerController.clear();
    });
  }

  void _submitAnswer() {
    if (_currentProblem == null || !_isGameActive || _userAnswer.isEmpty) {
      return;
    }

    final userAnswerInt = int.tryParse(_userAnswer);
    if (userAnswerInt == null) return;

    final isCorrect = _currentProblem!.isCorrectAnswer(userAnswerInt);

    setState(() {
      _totalProblems++;
      if (isCorrect) {
        _correctAnswers++;
        _score += _getPointsForProblem();
      }
    });

    _showFeedback(isCorrect);
    _generateNewProblem();
  }

  int _getPointsForProblem() {
    switch (_currentProblem!.operation) {
      case MathOperationType.addition:
        return 10;
      case MathOperationType.subtraction:
        return 15;
      case MathOperationType.multiplication:
        return 20;
      case MathOperationType.division:
        return 25;
    }
  }

  void _showFeedback(bool isCorrect) {
    _feedbackController.forward().then((_) {
      _feedbackController.reverse();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? 'せいかい！' : '不正解',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _endGame() async {
    if (_gameTimer.isActive) _gameTimer.cancel();

    setState(() {
      _isGameActive = false;
    });

    // スコアを記録
    final miniGameService = context.read<MiniGameService>();
    await miniGameService.recordScore(
      'speed_math',
      _score,
      MiniGameDifficulty.normal,
    );

    if (!mounted) return;
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    final accuracy = _totalProblems > 0 ? (_correctAnswers / _totalProblems * 100) : 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ゲーム終了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'スコア: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '正解数: $_correctAnswers / $_totalProblems',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '正答率: ${accuracy.round()}%',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (accuracy >= 90)
              const Text(
                'すばらしい！',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              )
            else if (accuracy >= 70)
              const Text(
                'よくできました！',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              )
            else
              const Text(
                'がんばりましょう！',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
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
    final success = await pointsService.spendPoints(15);

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

    _progressController.reset();
    _startGame();
  }

  void _onNumberPressed(String number) {
    if (!_isGameActive) return;

    setState(() {
      _userAnswer += number;
      _answerController.text = _userAnswer;
    });
  }

  void _onDeletePressed() {
    if (!_isGameActive || _userAnswer.isEmpty) return;

    setState(() {
      _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1);
      _answerController.text = _userAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('スピード計算'),
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
      body: Column(
        children: [
          // タイマー表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _timeLeft <= 10 ? Colors.red : Colors.orange,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '残り時間: $_timeLeft秒',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: 1 - _progressController.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 統計表示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('正解', _correctAnswers.toString(), Colors.green),
                      _buildStatCard('問題数', _totalProblems.toString(), Colors.blue),
                      _buildStatCard(
                        '正答率',
                        _totalProblems > 0 ? '${(_correctAnswers / _totalProblems * 100).round()}%' : '0%',
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 問題表示
                  if (_currentProblem != null && _isGameActive)
                    AnimatedBuilder(
                      animation: _feedbackController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_feedbackController.value * 0.1),
                          child: Card(
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Text(
                                    _currentProblem!.questionText,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text('=', style: TextStyle(fontSize: 32)),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: 200,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _userAnswer.isEmpty ? '?' : _userAnswer,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _userAnswer.isEmpty
                                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                            : theme.colorScheme.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const Spacer(),

                  // 数字キーパッド
                  if (_isGameActive) _buildKeypad(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme) {
    return Column(
      children: [
        // 数字ボタン 1-9
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 0; col < 3; col++)
                  _buildKeypadButton(
                    (row * 3 + col + 1).toString(),
                    theme,
                  ),
              ],
            ),
          ),

        // 最下段: 削除, 0, 決定
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('⌫', theme, isDelete: true),
              _buildKeypadButton('0', theme),
              _buildKeypadButton('決定', theme, isSubmit: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(
    String text,
    ThemeData theme, {
    bool isDelete = false,
    bool isSubmit = false,
  }) {
    return SizedBox(
      width: 80,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (isDelete) {
            _onDeletePressed();
          } else if (isSubmit) {
            _submitAnswer();
          } else {
            _onNumberPressed(text);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSubmit
              ? Colors.green
              : isDelete
                  ? Colors.orange
                  : theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSubmit ? 16 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
