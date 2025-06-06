import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/math_problem.dart';
import '../models/score_record.dart';
import '../services/score_service.dart';
import '../widgets/score_card.dart';

/// スコア履歴画面
/// 過去の練習結果を一覧表示し、統計情報を提供
class ScoreHistoryScreen extends StatefulWidget {
  const ScoreHistoryScreen({super.key});

  @override
  State<ScoreHistoryScreen> createState() => _ScoreHistoryScreenState();
}

class _ScoreHistoryScreenState extends State<ScoreHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MathOperationType _selectedOperation =
      MathOperationType.multiplication;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedOperation = _tabController.index == 0
              ? MathOperationType.multiplication
              : _tabController.index == 1
              ? MathOperationType.division
              : MathOperationType.multiplication; // 全体表示では掛け算をデフォルト
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreService = context.watch<ScoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('スコア履歴'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimaryContainer,
          unselectedLabelColor: theme.colorScheme.onPrimaryContainer
              .withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: '掛け算', icon: Icon(Icons.close)),
            Tab(text: '割り算', icon: Icon(Icons.more_horiz)),
            Tab(text: '全体', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: scoreService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOperationHistory(
                  MathOperationType.multiplication,
                  scoreService,
                ),
                _buildOperationHistory(
                  MathOperationType.division,
                  scoreService,
                ),
                _buildOverallStats(scoreService),
              ],
            ),
    );
  }

  Widget _buildOperationHistory(
    MathOperationType operation,
    ScoreService scoreService,
  ) {
    final scores = scoreService.getScoresByOperation(operation);
    final bestScore = scoreService.getBestScore(operation);
    final averageScore = scoreService.getAverageScore(operation);

    if (scores.isEmpty) {
      return _buildEmptyState(operation);
    }

    return Column(
      children: [
        // 統計サマリー
        _buildStatsSummary(
          operation,
          bestScore,
          averageScore,
          scores.length,
        ),

        // スコア一覧
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final score = scores[index];
              final isRecentBest =
                  bestScore != null && score.id == bestScore.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ScoreCard(
                  scoreRecord: score,
                  isBest: isRecentBest,
                  showImprovement: index < scores.length - 1,
                  previousScore: index < scores.length - 1
                      ? scores[index + 1]
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverallStats(ScoreService scoreService) {
    final allScores = scoreService.scores;
    final streakDays = scoreService.getStreakDays();
    final weeklyCount = scoreService.getWeeklyPracticeCount();
    final multiplicationScores = scoreService.getScoresByOperation(
      MathOperationType.multiplication,
    );
    final divisionScores = scoreService.getScoresByOperation(
      MathOperationType.division,
    );

    if (allScores.isEmpty) {
      return _buildEmptyState(null);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 全体統計
          _buildOverallStatsCard(
            streakDays,
            weeklyCount,
            allScores.length,
          ),

          const SizedBox(height: 16),

          // 操作別比較
          _buildComparisonCard(
            multiplicationScores,
            divisionScores,
            scoreService,
          ),

          const SizedBox(height: 16),

          // 最近の記録
          _buildRecentScores(allScores),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MathOperationType? operation) {
    final operationName = operation?.displayName ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            operation != null ? '$operationNameの記録がありません' : '記録がありません',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '練習を始めて記録を作りましょう！',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(
    MathOperationType operation,
    ScoreRecord? bestScore,
    double averageScore,
    int totalPractices,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '最高記録',
            bestScore != null ? '${bestScore.accuracyPercentage}%' : '-',
            Icons.star,
          ),
          _buildStatItem(
            '平均スコア',
            '${(averageScore * 100).round()}%',
            Icons.trending_up,
          ),
          _buildStatItem(
            '練習回数',
            '$totalPractices回',
            Icons.fitness_center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onPrimaryContainer,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallStatsCard(
    int streakDays,
    int weeklyCount,
    int totalPractices,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('全体統計', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '連続練習',
                  '$streakDays日',
                  Icons.local_fire_department,
                ),
                _buildStatItem(
                  '今週の練習',
                  '$weeklyCount回',
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  '総練習回数',
                  '$totalPractices回',
                  Icons.emoji_events,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(
    List<ScoreRecord> multiplicationScores,
    List<ScoreRecord> divisionScores,
    ScoreService scoreService,
  ) {
    final theme = Theme.of(context);
    final multiplicationAvg = scoreService.getAverageScore(
      MathOperationType.multiplication,
    );
    final divisionAvg = scoreService.getAverageScore(
      MathOperationType.division,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('掛け算 vs 割り算', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.close,
                        color: Colors.blue,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '掛け算',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${multiplicationScores.length}回練習'),
                      Text(
                        '平均 ${(multiplicationAvg * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.more_horiz,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '割り算',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${divisionScores.length}回練習'),
                      Text(
                        '平均 ${(divisionAvg * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScores(List<ScoreRecord> allScores) {
    final theme = Theme.of(context);
    final recentScores = allScores.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最近の記録', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...recentScores.map(
              (score) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ScoreCard(
                  scoreRecord: score,
                  isBest: false,
                  showImprovement: false,
                  isCompact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
