import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';

import '../models/math_problem.dart';
import '../services/math_service.dart';
import '../services/score_service.dart';
import '../services/points_service.dart';

/// みんなでバトル画面
/// AIとの算数バトルゲーム
class MultiplayerBattleScreen extends StatefulWidget {
  const MultiplayerBattleScreen({super.key});

  @override
  State<MultiplayerBattleScreen> createState() => _MultiplayerBattleScreenState();
}

class _MultiplayerBattleScreenState extends State<MultiplayerBattleScreen> with TickerProviderStateMixin {
  static const int _roundCount = 5;
  static const int _timePerRound = 10; // seconds

  late AnimationController _timerController;
  late AnimationController _battleController;
  Timer? _roundTimer;

  int _currentRound = 0;
  int _playerScore = 0;
  int _aiScore = 0;
  int _timeRemaining = _timePerRound;
  bool _isGameActive = false;
  bool _isGameFinished = false;
  bool _roundAnswered = false;

  MathProblem? _currentProblem;
  final TextEditingController _answerController = TextEditingController();

  // AI opponent data
  final List<String> _aiNames = ['ロボット君', 'サイバー先生', 'デジタル博士', 'AI助手'];
  late String _aiOpponentName;
  late String _aiOpponentEmoji;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: _timePerRound),
      vsync: this,
    );
    _battleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _selectRandomAiOpponent();
    _startBattle();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _battleController.dispose();
    _roundTimer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _selectRandomAiOpponent() {
    final random = Random();
    _aiOpponentName = _aiNames[random.nextInt(_aiNames.length)];
    _aiOpponentEmoji = ['🤖', '🦾', '👨‍💻', '🧠'][random.nextInt(4)];
  }

  void _startBattle() {
    setState(() {
      _isGameActive = true;
      _currentRound = 1;
    });
    _startNewRound();
  }

  void _startNewRound() {
    if (_currentRound > _roundCount) {
      _finishGame();
      return;
    }

    final mathService = context.read<MathService>();
    _currentProblem = mathService.generateProblem(
      MathOperationType.multiplication,
      difficultyLevel: 2,
    );

    setState(() {
      _timeRemaining = _timePerRound;
      _roundAnswered = false;
    });

    _answerController.clear();
    _timerController.reset();
    _timerController.forward();

    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    if (!_roundAnswered) {
      _handleAnswer(null);
    }
  }

  void _handleAnswer(int? playerAnswer) {
    if (_roundAnswered) return;

    _roundTimer?.cancel();
    _timerController.stop();

    setState(() {
      _roundAnswered = true;
    });

    final isPlayerCorrect = playerAnswer == _currentProblem!.answer;
    final isAiCorrect = _simulateAiAnswer();

    // スコア更新
    if (isPlayerCorrect) _playerScore++;
    if (isAiCorrect) _aiScore++;

    // バトルアニメーション
    _battleController.forward().then((_) {
      _battleController.reverse();
    });

    // 結果表示後、次のラウンドへ
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentRound++;
        });
        _startNewRound();
      }
    });
  }

  bool _simulateAiAnswer() {
    // AIの正答率をプレイヤーより少し低めに設定
    final random = Random();
    final aiAccuracy = 0.7 + (random.nextDouble() * 0.2); // 70-90%
    return random.nextDouble() < aiAccuracy;
  }

  void _finishGame() async {
    setState(() {
      _isGameActive = false;
      _isGameFinished = true;
    });

    // スコアとポイントを記録
    final scoreService = context.read<ScoreService>();
    final pointsService = context.read<PointsService>();

    await scoreService.addScore(
      MathOperationType.multiplication,
      _playerScore, // 正解数
      _roundCount, // 総問題数
      const Duration(seconds: _roundCount * 30), // 推定時間
    );

    // 勝利ボーナス
    if (_playerScore > _aiScore) {
      pointsService.addPoints(50, 'バトル勝利ボーナス');
    } else if (_playerScore == _aiScore) {
      pointsService.addPoints(25, 'バトル引き分けボーナス');
    }
    pointsService.addPoints(_playerScore * 10, 'バトル参加ポイント');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ みんなでバトル'),
        backgroundColor: theme.colorScheme.errorContainer,
      ),
      body: !_isGameFinished ? _buildGameScreen(theme) : _buildResultScreen(theme),
    );
  }

  Widget _buildGameScreen(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildBattleHeader(theme),
          const SizedBox(height: 24),
          if (_currentProblem != null) _buildProblemSection(theme),
          const SizedBox(height: 24),
          _buildTimerSection(theme),
          const SizedBox(height: 24),
          _buildAnswerSection(theme),
        ],
      ),
    );
  }

  Widget _buildBattleHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.errorContainer,
            theme.colorScheme.errorContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'ラウンド $_currentRound / $_roundCount',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Player
              Expanded(
                child: Column(
                  children: [
                    const Text('👤', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      'あなた',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_playerScore',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // VS
              Column(
                children: [
                  Text(
                    'VS',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  if (_roundAnswered)
                    AnimatedBuilder(
                      animation: _battleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_battleController.value * 0.3),
                          child: const Text('💥', style: TextStyle(fontSize: 24)),
                        );
                      },
                    ),
                ],
              ),
              // AI
              Expanded(
                child: Column(
                  children: [
                    Text(_aiOpponentEmoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      _aiOpponentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_aiScore',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProblemSection(ThemeData theme) {
    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '問題',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_currentProblem!.operand1} × ${_currentProblem!.operand2} = ?',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          '残り時間',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: _timeRemaining / _timePerRound,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeRemaining > 3 ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_timeRemaining秒',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _timeRemaining > 3 ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '答えを入力してください',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
                decoration: InputDecoration(
                  hintText: '答え',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                enabled: !_roundAnswered,
                onSubmitted: _roundAnswered ? null : _handleTextSubmit,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _roundAnswered ? null : _handleButtonSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('答える！'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(ThemeData theme) {
    final isWin = _playerScore > _aiScore;
    final isDraw = _playerScore == _aiScore;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'バトル終了！',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    isWin
                        ? '🏆 勝利！'
                        : isDraw
                            ? '🤝 引き分け！'
                            : '😅 敗北...',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: isWin
                          ? theme.colorScheme.primary
                          : isDraw
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('👤', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text('あなた', style: theme.textTheme.titleMedium),
                          Text(
                            '$_playerScore',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(_aiOpponentEmoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(_aiOpponentName, style: theme.textTheme.titleMedium),
                          Text(
                            '$_aiScore',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isWin
                        ? 'おめでとうございます！'
                        : isDraw
                            ? 'いい勝負でした！'
                            : '次回頑張りましょう！',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('ホームに戻る'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 再戦
                    setState(() {
                      _currentRound = 0;
                      _playerScore = 0;
                      _aiScore = 0;
                      _isGameFinished = false;
                    });
                    _selectRandomAiOpponent();
                    _startBattle();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('再戦する'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTextSubmit(String value) {
    if (value.isNotEmpty) {
      final answer = int.tryParse(value);
      _handleAnswer(answer);
    }
  }

  void _handleButtonSubmit() {
    final text = _answerController.text;
    if (text.isNotEmpty) {
      final answer = int.tryParse(text);
      _handleAnswer(answer);
    }
  }
}
