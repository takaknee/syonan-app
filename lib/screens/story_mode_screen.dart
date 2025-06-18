import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/math_problem.dart';
import '../services/math_service.dart';
import '../services/score_service.dart';
import '../services/points_service.dart';
import '../widgets/problem_card.dart';
import '../widgets/answer_input.dart';

/// ストーリーモード画面
/// 冒険しながら算数を学ぶストーリー形式の学習画面
class StoryModeScreen extends StatefulWidget {
  const StoryModeScreen({super.key});

  @override
  State<StoryModeScreen> createState() => _StoryModeScreenState();
}

class _StoryModeScreenState extends State<StoryModeScreen> {
  int _currentChapter = 1;
  int _currentStage = 1;
  bool _isInBattle = false;
  int _currentProblemIndex = 0;
  List<MathProblem> _currentProblems = [];
  List<int?> _userAnswers = [];
  int _correctAnswers = 0;

  static const int _maxChapters = 3;
  static const int _stagesPerChapter = 5;
  static const int _problemsPerStage = 3;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    // TODO: 実際の実装では SharedPreferences から進捗を読み込む
    // 今回はデモ用に固定値
  }

  void _saveProgress() {
    // TODO: 実際の実装では SharedPreferences に進捗を保存
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 ストーリーモード'),
        backgroundColor: theme.colorScheme.tertiaryContainer,
      ),
      body: _isInBattle
          ? _buildBattleScreen(theme)
          : _buildStoryScreen(theme),
    );
  }

  Widget _buildStoryScreen(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStoryHeader(theme),
          const SizedBox(height: 24),
          _buildCurrentChapterCard(theme),
          const SizedBox(height: 24),
          _buildChaptersList(theme),
        ],
      ),
    );
  }

  Widget _buildStoryHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiaryContainer,
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🏰', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            '算数王国の冒険',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '計算の力で魔王を倒し、\n平和を取り戻そう！',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentChapterCard(ThemeData theme) {
    final chapterInfo = _getChapterInfo(_currentChapter);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  chapterInfo.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'チャプター $_currentChapter',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        chapterInfo.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              chapterInfo.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'ステージ $_currentStage / $_stagesPerChapter',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startStage(),
                icon: const Icon(Icons.play_arrow),
                label: Text('ステージ $_currentStage を開始'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaptersList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'すべてのチャプター',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_maxChapters, (index) {
          final chapterNumber = index + 1;
          final chapterInfo = _getChapterInfo(chapterNumber);
          final isUnlocked = chapterNumber <= _currentChapter;
          final isCompleted = chapterNumber < _currentChapter;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isUnlocked
                ? theme.cardColor
                : theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
            child: ListTile(
              leading: Text(
                chapterInfo.emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: isUnlocked ? null : theme.disabledColor,
                ),
              ),
              title: Text(
                chapterInfo.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? null : theme.disabledColor,
                ),
              ),
              subtitle: Text(
                chapterInfo.description,
                style: TextStyle(
                  color: isUnlocked ? null : theme.disabledColor,
                ),
              ),
              trailing: isCompleted
                  ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    )
                  : isUnlocked
                      ? Icon(
                          Icons.play_arrow,
                          color: theme.colorScheme.primary,
                        )
                      : Icon(
                          Icons.lock,
                          color: theme.disabledColor,
                        ),
              onTap: isUnlocked ? () => _selectChapter(chapterNumber) : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBattleScreen(ThemeData theme) {
    if (_currentProblems.isEmpty || _currentProblemIndex >= _currentProblems.length) {
      return _buildBattleCompleteScreen(theme);
    }

    final currentProblem = _currentProblems[_currentProblemIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildBattleHeader(theme),
          const SizedBox(height: 24),
          _buildStoryContext(theme),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProblemCard(problem: currentProblem),
                const SizedBox(height: 24),
                AnswerInput(
                  onAnswerSubmitted: _handleAnswer,
                  autofocus: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'チャプター $_currentChapter - ステージ $_currentStage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                Text(
                  '問題 ${_currentProblemIndex + 1} / $_problemsPerStage',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          CircularProgressIndicator(
            value: (_currentProblemIndex + 1) / _problemsPerStage,
            backgroundColor: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContext(ThemeData theme) {
    final storyText = _getStoryText(_currentChapter, _currentStage, _currentProblemIndex);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('🧙‍♂️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '賢者の助言',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              storyText,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleCompleteScreen(ThemeData theme) {
    final isStageComplete = _correctAnswers >= (_problemsPerStage * 0.7); // 70%以上で合格
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    isStageComplete ? '🎉' : '😅',
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isStageComplete ? 'ステージクリア！' : 'もう一度挑戦！',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isStageComplete
                          ? theme.colorScheme.primary
                          : theme.colors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正解数: $_correctAnswers / $_problemsPerStage',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isStageComplete
                        ? _getVictoryMessage(_currentChapter, _currentStage)
                        : _getRetryMessage(_currentChapter, _currentStage),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
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
                    setState(() {
                      _isInBattle = false;
                    });
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('マップに戻る'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isStageComplete ? _proceedToNextStage : _retryStage,
                  icon: Icon(isStageComplete ? Icons.arrow_forward : Icons.refresh),
                  label: Text(isStageComplete ? '次へ進む' : '再挑戦'),
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

  void _selectChapter(int chapterNumber) {
    if (chapterNumber <= _currentChapter) {
      setState(() {
        _currentChapter = chapterNumber;
        _currentStage = 1;
      });
    }
  }

  void _startStage() {
    final mathService = context.read<MathService>();
    final chapterInfo = _getChapterInfo(_currentChapter);
    
    // チャプターに応じた問題を生成
    _currentProblems = List.generate(_problemsPerStage, (index) {
      return mathService.generateProblem(
        chapterInfo.operationType,
        difficultyLevel: chapterInfo.difficulty,
      );
    });

    setState(() {
      _isInBattle = true;
      _currentProblemIndex = 0;
      _userAnswers = List.filled(_problemsPerStage, null);
      _correctAnswers = 0;
    });
  }

  void _handleAnswer(int answer) {
    final currentProblem = _currentProblems[_currentProblemIndex];
    final isCorrect = answer == currentProblem.answer;
    
    _userAnswers[_currentProblemIndex] = answer;
    if (isCorrect) {
      _correctAnswers++;
    }

    if (_currentProblemIndex < _problemsPerStage - 1) {
      setState(() {
        _currentProblemIndex++;
      });
    } else {
      // ステージ完了
      _recordStageResult();
      setState(() {
        _currentProblemIndex = _problemsPerStage; // 結果画面を表示するため
      });
    }
  }

  void _recordStageResult() {
    final scoreService = context.read<ScoreService>();
    final pointsService = context.read<PointsService>();
    final chapterInfo = _getChapterInfo(_currentChapter);

    // スコアを記録
    final score = (_correctAnswers / _problemsPerStage * 100).toDouble();
    scoreService.addScore(
      chapterInfo.operationType,
      score,
      _problemsPerStage,
      _correctAnswers,
    );

    // ポイントを追加
    pointsService.addPoints(_correctAnswers * 15, 'ストーリーモード');
    
    if (_correctAnswers >= (_problemsPerStage * 0.7)) {
      pointsService.addPoints(25, 'ステージクリアボーナス');
    }
  }

  void _proceedToNextStage() {
    if (_currentStage < _stagesPerChapter) {
      setState(() {
        _currentStage++;
        _isInBattle = false;
      });
    } else if (_currentChapter < _maxChapters) {
      setState(() {
        _currentChapter++;
        _currentStage = 1;
        _isInBattle = false;
      });
    } else {
      // 全チャプター完了
      _showGameCompleteDialog();
    }
    _saveProgress();
  }

  void _retryStage() {
    _startStage();
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎊 おめでとう！'),
        content: const Text('すべてのチャプターをクリアしました！\n算数王国に平和が戻りました！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    );
  }

  _ChapterInfo _getChapterInfo(int chapter) {
    switch (chapter) {
      case 1:
        return _ChapterInfo(
          title: '森の村の危機',
          description: '掛け算の力で魔物を倒そう！',
          emoji: '🌲',
          operationType: MathOperationType.multiplication,
          difficulty: 1,
        );
      case 2:
        return _ChapterInfo(
          title: '砂漠の遺跡',
          description: '割り算で古代の謎を解き明かせ！',
          emoji: '🏜️',
          operationType: MathOperationType.division,
          difficulty: 2,
        );
      case 3:
        return _ChapterInfo(
          title: '魔王城の決戦',
          description: 'すべての計算スキルで魔王に立ち向かえ！',
          emoji: '🏰',
          operationType: MathOperationType.multiplication,
          difficulty: 3,
        );
      default:
        return _getChapterInfo(1);
    }
  }

  String _getStoryText(int chapter, int stage, int problemIndex) {
    // チャプター、ステージ、問題番号に応じたストーリーテキストを返す
    switch (chapter) {
      case 1:
        if (problemIndex == 0) {
          return '村に魔物が現れました！掛け算の呪文で退治しましょう。';
        } else if (problemIndex == 1) {
          return '魔物がまだいます。続けて呪文を唱えてください！';
        } else {
          return '最後の魔物です。正確な計算で村を守りましょう！';
        }
      case 2:
        if (problemIndex == 0) {
          return '古代の石版に謎かけが刻まれています。割り算で解読してください。';
        } else if (problemIndex == 1) {
          return 'もう一つの石版を発見しました。引き続き計算で謎を解きましょう。';
        } else {
          return '最後の謎です。これを解けば遺跡の宝が手に入ります！';
        }
      case 3:
        if (problemIndex == 0) {
          return '魔王が現れました！あなたの全ての力を見せてください！';
        } else if (problemIndex == 1) {
          return '魔王の力が弱まってきました。この調子で続けてください！';
        } else {
          return '最後の一撃です！正確な計算で平和を取り戻しましょう！';
        }
      default:
        return '頑張って計算してください！';
    }
  }

  String _getVictoryMessage(int chapter, int stage) {
    switch (chapter) {
      case 1:
        return '魔物を退治しました！村人たちが喜んでいます。';
      case 2:
        return '古代の謎を解きました！貴重な宝物を手に入れました。';
      case 3:
        return '魔王を倒しました！算数王国に平和が戻りました！';
      default:
        return 'よくできました！';
    }
  }

  String _getRetryMessage(int chapter, int stage) {
    return 'まだ敵が残っています。もう一度挑戦して、正確な計算で勝利を掴みましょう！';
  }
}

class _ChapterInfo {
  const _ChapterInfo({
    required this.title,
    required this.description,
    required this.emoji,
    required this.operationType,
    required this.difficulty,
  });

  final String title;
  final String description;
  final String emoji;
  final MathOperationType operationType;
  final int difficulty;
}