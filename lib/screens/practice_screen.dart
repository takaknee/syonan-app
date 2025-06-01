import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/math_problem.dart';
import '../models/score_record.dart';
import '../services/math_service.dart';
import '../services/score_service.dart';
import '../widgets/problem_card.dart';
import '../widgets/answer_input.dart';
import '../widgets/encouragement_dialog.dart';

/// 練習画面
/// 算数問題を出題して答えを入力する画面
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.operation,
    this.problemCount = 10,
  });

  final MathOperationType operation;
  final int problemCount;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  late final List<MathProblem> _problems;
  late final List<int?> _userAnswers;
  late final List<bool> _isCorrect;
  late final DateTime _startTime;

  int _currentProblemIndex = 0;
  bool _isCompleted = false;
  late AnimationController _progressController;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // 問題を生成
    final mathService = context.read<MathService>();
    _problems = mathService.generateProblems(widget.operation, widget.problemCount);
    _userAnswers = List.filled(widget.problemCount, null);
    _isCorrect = List.filled(widget.problemCount, false);

    // アニメーションコントローラーの初期化
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.operation.displayName}の練習'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: Column(
        children: [
          // プログレスバー
          _buildProgressBar(theme),

          // メインコンテンツ
          Expanded(
            child: _isCompleted ? _buildResultView(theme) : _buildProblemView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final progress = (_currentProblemIndex + 1) / widget.problemCount;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '問題 ${_currentProblemIndex + 1} / ${widget.problemCount}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.onPrimaryContainer.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemView(ThemeData theme) {
    final currentProblem = _problems[_currentProblemIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 問題カード
          ProblemCard(problem: currentProblem),

          const SizedBox(height: 32),

          // 答え入力
          AnswerInput(
            onAnswerSubmitted: _handleAnswerSubmitted,
            onAnswerChanged: (value) {
              setState(() {
                _userAnswers[_currentProblemIndex] = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // ヒントボタン（必要に応じて）
          if (_shouldShowHint()) _buildHintButton(theme, currentProblem),
        ],
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    final correctCount = _isCorrect.where((correct) => correct).length;
    final accuracy = correctCount / widget.problemCount;
    final timeSpent = DateTime.now().difference(_startTime);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 結果カード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    accuracy >= 0.8 ? Icons.star : Icons.thumb_up,
                    size: 64,
                    color: accuracy >= 0.8 ? Colors.amber : theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'お疲れ様でした！',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$correctCount問正解 / ${widget.problemCount}問',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '正答率: ${(accuracy * 100).round()}%',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '時間: ${_formatDuration(timeSpent)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ボタン
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _retryPractice,
                  child: const Text('もう一度'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _goHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('ホームに戻る'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton(ThemeData theme, MathProblem problem) {
    return TextButton.icon(
      onPressed: () => _showHint(problem),
      icon: const Icon(Icons.lightbulb_outline),
      label: const Text('ヒント'),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.secondary,
      ),
    );
  }

  bool _shouldShowHint() {
    // 3問目以降でヒントを表示可能にする
    return _currentProblemIndex >= 2;
  }

  void _handleAnswerSubmitted(int answer) {
    final currentProblem = _problems[_currentProblemIndex];
    final isCorrect = currentProblem.isCorrectAnswer(answer);

    setState(() {
      _userAnswers[_currentProblemIndex] = answer;
      _isCorrect[_currentProblemIndex] = isCorrect;
    });

    // フィードバックアニメーション
    _feedbackController.forward().then((_) {
      _feedbackController.reset();
    });

    // 正解・不正解のフィードバック
    _showAnswerFeedback(isCorrect, currentProblem.correctAnswer);

    // 次の問題に進むか完了する
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentProblemIndex < widget.problemCount - 1) {
        setState(() {
          _currentProblemIndex++;
        });
        _progressController.animateTo((_currentProblemIndex + 1) / widget.problemCount);
      } else {
        _completePractice();
      }
    });
  }

  void _showAnswerFeedback(bool isCorrect, int correctAnswer) {
    final message = isCorrect ? 'せいかい！' : '答えは $correctAnswer です';
    final color = isCorrect ? Colors.green : Colors.orange;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHint(MathProblem problem) {
    String hint = '';

    if (problem.operation == MathOperationType.multiplication) {
      hint = '${problem.firstNumber}を${problem.secondNumber}回足してみましょう';
    } else {
      hint = '${problem.firstNumber}を${problem.secondNumber}個に分けてみましょう';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ヒント'),
        content: Text(hint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('わかりました'),
          ),
        ],
      ),
    );
  }

  void _completePractice() async {
    setState(() {
      _isCompleted = true;
    });

    // スコアを保存
    final correctCount = _isCorrect.where((correct) => correct).length;
    final timeSpent = DateTime.now().difference(_startTime);

    final scoreRecord = ScoreRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      operation: widget.operation,
      correctAnswers: correctCount,
      totalQuestions: widget.problemCount,
      timeSpent: timeSpent,
    );

    final scoreService = context.read<ScoreService>();
    await scoreService.saveScore(scoreRecord);

    // 改善度をチェックして励ましのメッセージを表示
    final improvement = scoreService.getImprovement(widget.operation);
    if (improvement == ScoreImprovement.improved) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => EncouragementDialog(
              scoreRecord: scoreRecord,
              improvement: improvement,
            ),
          );
        }
      });
    }
  }

  void _retryPractice() {
    // 同じ操作タイプで新しい練習を開始
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PracticeScreen(
          operation: widget.operation,
          problemCount: widget.problemCount,
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}分${seconds}秒';
  }
}