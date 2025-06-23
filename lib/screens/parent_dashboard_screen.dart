import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/math_problem.dart';
import '../models/score_record.dart';
import '../services/points_service.dart';
import '../services/score_service.dart';

/// 保護者ダッシュボード画面
/// 子供の学習進捗を詳しく確認できる画面
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 保護者ダッシュボード'),
        backgroundColor: theme.colorScheme.primaryContainer,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '概要'),
            Tab(icon: Icon(Icons.analytics), text: '成績'),
            Tab(icon: Icon(Icons.timeline), text: '進捗'),
            Tab(icon: Icon(Icons.settings), text: '設定'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPerformanceTab(),
          _buildProgressTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<ScoreService, PointsService>(
      builder: (context, scoreService, pointsService, child) {
        final theme = Theme.of(context);
        final allScores = scoreService.getAllScores();
        final summary = _calculateSummary(allScores);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(theme, summary),
              const SizedBox(height: 24),
              _buildQuickStatsGrid(theme, summary, pointsService),
              const SizedBox(height: 24),
              _buildRecentActivityCard(theme, allScores),
              const SizedBox(height: 24),
              _buildRecommendationsCard(theme, summary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(ThemeData theme, _LearningySummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'お子さんの学習状況',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '総練習回数: ${summary.totalPractices}回',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '平均スコア: ${summary.averageScore.toStringAsFixed(1)}点',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '学習継続日数: ${summary.streakDays}日',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(
    ThemeData theme,
    _LearningySummary summary,
    PointsService pointsService,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          theme,
          '総合成績',
          summary.overallGrade,
          Icons.grade,
          _getGradeColor(theme, summary.overallGrade),
        ),
        _buildStatCard(
          theme,
          '獲得ポイント',
          '${pointsService.totalPoints}P',
          Icons.stars,
          theme.colorScheme.tertiary,
        ),
        _buildStatCard(
          theme,
          '得意分野',
          summary.strongestSubject,
          Icons.trending_up,
          theme.colorScheme.primary,
        ),
        _buildStatCard(
          theme,
          '改善分野',
          summary.weakestSubject,
          Icons.school,
          theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(
      ThemeData theme, List<ScoreRecord> allScores) {
    final recentScores = allScores.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '最近の学習履歴',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentScores.isEmpty)
              const Center(
                child: Text('まだ学習記録がありません'),
              )
            else
              ...recentScores.map((score) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                _getOperationColor(theme, score.operationType)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getOperationIcon(score.operationType),
                            color:
                                _getOperationColor(theme, score.operationType),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getOperationName(score.operationType),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${score.score.toStringAsFixed(0)}点 (${score.correctAnswers}/${score.totalQuestions}問正解)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(score.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(ThemeData theme, _LearningySummary summary) {
    final recommendations = _generateRecommendations(summary);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '学習アドバイス',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return Consumer<ScoreService>(
      builder: (context, scoreService, child) {
        final theme = Theme.of(context);
        final allScores = scoreService.getAllScores();
        final performanceData = _calculatePerformanceData(allScores);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPerformanceOverview(theme, performanceData),
              const SizedBox(height: 24),
              _buildSubjectPerformance(theme, performanceData),
              const SizedBox(height: 24),
              _buildAccuracyTrends(theme, allScores),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceOverview(
    ThemeData theme,
    _PerformanceData performanceData,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '成績概要',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    theme,
                    '平均正答率',
                    '${performanceData.overallAccuracy.toStringAsFixed(1)}%',
                    _getAccuracyColor(theme, performanceData.overallAccuracy),
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    theme,
                    '最高スコア',
                    '${performanceData.highestScore.toStringAsFixed(0)}点',
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    theme,
                    '改善度',
                    performanceData.improvementTrend > 0
                        ? '+${performanceData.improvementTrend.toStringAsFixed(1)}%'
                        : '${performanceData.improvementTrend.toStringAsFixed(1)}%',
                    performanceData.improvementTrend > 0
                        ? Colors.green
                        : performanceData.improvementTrend < 0
                            ? Colors.red
                            : theme.colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    theme,
                    '総問題数',
                    '${performanceData.totalProblems}問',
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectPerformance(
    ThemeData theme,
    _PerformanceData performanceData,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分野別成績',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...performanceData.subjectPerformances.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getOperationName(entry.key),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(1)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getAccuracyColor(theme, entry.value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getAccuracyColor(theme, entry.value),
                      ),
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

  Widget _buildAccuracyTrends(ThemeData theme, List<ScoreRecord> allScores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '学習トレンド',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: allScores.isEmpty
                  ? const Center(child: Text('データが不足しています'))
                  : _buildSimpleTrendChart(theme, allScores),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTrendChart(ThemeData theme, List<ScoreRecord> scores) {
    final recentScores = scores.take(10).toList().reversed.toList();

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _SimpleTrendPainter(
        scores: recentScores,
        primaryColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildProgressTab() {
    return Consumer<ScoreService>(
      builder: (context, scoreService, child) {
        final theme = Theme.of(context);
        final allScores = scoreService.getAllScores();
        final progressData = _calculateProgressData(allScores);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLearningGoals(theme, progressData),
              const SizedBox(height: 24),
              _buildMilestones(theme, progressData),
              const SizedBox(height: 24),
              _buildWeeklyProgress(theme, allScores),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLearningGoals(ThemeData theme, _ProgressData progressData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '学習目標',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalItem(
              theme,
              '毎日練習',
              progressData.dailyStreak,
              7,
              '日連続',
            ),
            _buildGoalItem(
              theme,
              '週間練習回数',
              progressData.weeklyPractices,
              10,
              '回',
            ),
            _buildGoalItem(
              theme,
              '平均正答率',
              progressData.averageAccuracy,
              80,
              '%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(
    ThemeData theme,
    String title,
    double current,
    double target,
    String unit,
  ) {
    final progress = current / target;
    final isAchieved = progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    current.toStringAsFixed(current % 1 == 0 ? 0 : 1),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isAchieved ? Colors.green : theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    ' / ${target.toStringAsFixed(target % 1 == 0 ? 0 : 1)}$unit',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (isAchieved) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress > 1.0 ? 1.0 : progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isAchieved ? Colors.green : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones(ThemeData theme, _ProgressData progressData) {
    final milestones = [
      _Milestone('初回練習完了', progressData.totalPractices >= 1, '最初の一歩'),
      _Milestone('10回練習達成', progressData.totalPractices >= 10, '継続力を身につけた'),
      _Milestone('平均80%達成', progressData.averageAccuracy >= 80, '高い正答率を維持'),
      _Milestone('全分野練習', progressData.allSubjectsTried, 'バランスよく学習'),
      _Milestone('100回練習達成', progressData.totalPractices >= 100, '真の努力家'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '達成バッジ',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...milestones.map((milestone) => ListTile(
                  leading: Icon(
                    milestone.isAchieved ? Icons.star : Icons.star_border,
                    color: milestone.isAchieved
                        ? Colors.amber
                        : theme.disabledColor,
                    size: 32,
                  ),
                  title: Text(
                    milestone.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: milestone.isAchieved ? null : theme.disabledColor,
                    ),
                  ),
                  subtitle: Text(
                    milestone.description,
                    style: TextStyle(
                      color: milestone.isAchieved
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                          : theme.disabledColor,
                    ),
                  ),
                  trailing: milestone.isAchieved
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress(ThemeData theme, List<ScoreRecord> allScores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '週間進捗',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '今週の学習パターン',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: _buildWeeklyChart(theme, allScores),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(ThemeData theme, List<ScoreRecord> allScores) {
    // 過去7日間の学習回数を計算
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayScores = allScores.where((score) {
        return score.createdAt.day == date.day &&
            score.createdAt.month == date.month &&
            score.createdAt.year == date.year;
      }).length;
      return dayScores;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final dayNames = ['月', '火', '水', '木', '金', '土', '日'];
        final count = weekData[index];
        final maxCount = weekData.reduce((a, b) => a > b ? a : b);
        final height = maxCount > 0 ? (count / maxCount * 60).clamp(5, 60) : 5;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: height.toDouble(),
              decoration: BoxDecoration(
                color: count > 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayNames[index],
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSettingsTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '保護者設定',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('学習リマインダー'),
                  subtitle: const Text('毎日の学習時間を通知'),
                  trailing: Switch(
                    value: true, // TODO: 実際の設定値に置き換え
                    onChanged: (value) {
                      // TODO: 設定の保存
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('学習目標時間'),
                  subtitle: const Text('1日15分'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 目標時間設定画面へ
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('週次レポート'),
                  subtitle: const Text('毎週の進捗をメールで受信'),
                  trailing: Switch(
                    value: false, // TODO: 実際の設定値に置き換え
                    onChanged: (value) {
                      // TODO: 設定の保存
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('データエクスポート'),
                  subtitle: const Text('学習データをCSVファイルでダウンロード'),
                  onTap: () {
                    // TODO: データエクスポート機能
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('準備中の機能です')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('データリセット'),
                  subtitle: const Text('すべての学習記録を削除'),
                  onTap: () {
                    _showResetDataDialog();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ データリセット'),
        content: const Text(
          'すべての学習記録が削除されます。\nこの操作は取り消せません。\n\n本当に実行しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              // TODO: データリセット機能
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('準備中の機能です')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  // Helper methods

  _LearningySummary _calculateSummary(List<ScoreRecord> allScores) {
    if (allScores.isEmpty) {
      return const _LearningySummary(
        totalPractices: 0,
        averageScore: 0.0,
        streakDays: 0,
        overallGrade: 'F',
        strongestSubject: '未設定',
        weakestSubject: '未設定',
      );
    }

    final totalScore = allScores.map((s) => s.score).reduce((a, b) => a + b);
    final averageScore = totalScore / allScores.length;

    // 分野別平均スコアを計算
    final subjectScores = <MathOperationType, List<double>>{};
    for (final score in allScores) {
      subjectScores
          .putIfAbsent(score.operationType, () => [])
          .add(score.score.toDouble());
    }

    String strongestSubject = '未設定';
    String weakestSubject = '未設定';
    double highestAvg = 0;
    double lowestAvg = 100;

    for (final entry in subjectScores.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg > highestAvg) {
        highestAvg = avg;
        strongestSubject = _getOperationName(entry.key);
      }
      if (avg < lowestAvg) {
        lowestAvg = avg;
        weakestSubject = _getOperationName(entry.key);
      }
    }

    return _LearningySummary(
      totalPractices: allScores.length,
      averageScore: averageScore,
      streakDays: _calculateStreakDays(allScores),
      overallGrade: _calculateGrade(averageScore),
      strongestSubject: strongestSubject,
      weakestSubject: weakestSubject,
    );
  }

  _PerformanceData _calculatePerformanceData(List<ScoreRecord> allScores) {
    if (allScores.isEmpty) {
      return const _PerformanceData(
        overallAccuracy: 0.0,
        highestScore: 0.0,
        improvementTrend: 0.0,
        totalProblems: 0,
        subjectPerformances: {},
      );
    }

    final totalCorrect =
        allScores.map((s) => s.correctAnswers).reduce((a, b) => a + b);
    final totalQuestions =
        allScores.map((s) => s.totalQuestions).reduce((a, b) => a + b);
    final overallAccuracy = (totalCorrect / totalQuestions) * 100;

    final highestScore = allScores
        .map((s) => s.score.toDouble())
        .reduce((a, b) => a > b ? a : b);

    // 改善度を計算（最初の5回と最後の5回の平均スコアを比較）
    double improvementTrend = 0.0;
    if (allScores.length >= 10) {
      final firstFiveAvg = allScores.reversed
              .take(5)
              .map((s) => s.score.toDouble())
              .reduce((a, b) => a + b) /
          5;
      final lastFiveAvg = allScores
              .take(5)
              .map((s) => s.score.toDouble())
              .reduce((a, b) => a + b) /
          5;
      improvementTrend = lastFiveAvg - firstFiveAvg;
    }

    // 分野別パフォーマンスを計算
    final subjectPerformances = <MathOperationType, double>{};
    final subjectScores = <MathOperationType, List<int>>{};
    final subjectTotalQuestions = <MathOperationType, List<int>>{};

    for (final score in allScores) {
      subjectScores
          .putIfAbsent(score.operationType, () => [])
          .add(score.correctAnswers);
      subjectTotalQuestions
          .putIfAbsent(score.operationType, () => [])
          .add(score.totalQuestions);
    }

    for (final entry in subjectScores.entries) {
      final totalCorrectForSubject = entry.value.reduce((a, b) => a + b);
      final totalQuestionsForSubject =
          subjectTotalQuestions[entry.key]!.reduce((a, b) => a + b);
      subjectPerformances[entry.key] =
          (totalCorrectForSubject / totalQuestionsForSubject) * 100;
    }

    return _PerformanceData(
      overallAccuracy: overallAccuracy,
      highestScore: highestScore,
      improvementTrend: improvementTrend,
      totalProblems: totalQuestions,
      subjectPerformances: subjectPerformances,
    );
  }

  _ProgressData _calculateProgressData(List<ScoreRecord> allScores) {
    final totalPractices = allScores.length.toDouble();
    final streakDays = _calculateStreakDays(allScores).toDouble();

    // 週間練習回数を計算
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyPractices = allScores
        .where((score) => score.createdAt.isAfter(weekStart))
        .length
        .toDouble();

    // 平均正答率を計算
    double averageAccuracy = 0.0;
    if (allScores.isNotEmpty) {
      final totalCorrect =
          allScores.map((s) => s.correctAnswers).reduce((a, b) => a + b);
      final totalQuestions =
          allScores.map((s) => s.totalQuestions).reduce((a, b) => a + b);
      averageAccuracy = (totalCorrect / totalQuestions) * 100;
    }

    // すべての分野を試したかチェック
    final triedOperations = allScores.map((s) => s.operationType).toSet();
    final allSubjectsTried = triedOperations.length >= 2; // 最低2つの分野

    return _ProgressData(
      totalPractices: totalPractices,
      dailyStreak: streakDays,
      weeklyPractices: weeklyPractices,
      averageAccuracy: averageAccuracy,
      allSubjectsTried: allSubjectsTried,
    );
  }

  int _calculateStreakDays(List<ScoreRecord> allScores) {
    if (allScores.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final hasScoreOnDate = allScores.any((score) {
        final scoreDate = DateTime(
          score.createdAt.year,
          score.createdAt.month,
          score.createdAt.day,
        );
        return scoreDate == date;
      });

      if (hasScoreOnDate) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  String _calculateGrade(double averageScore) {
    if (averageScore >= 90) return 'A';
    if (averageScore >= 80) return 'B';
    if (averageScore >= 70) return 'C';
    if (averageScore >= 60) return 'D';
    return 'F';
  }

  Color _getGradeColor(ThemeData theme, String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return theme.colorScheme.error;
    }
  }

  Color _getOperationColor(ThemeData theme, MathOperationType operation) {
    switch (operation) {
      case MathOperationType.multiplication:
        return Colors.blue;
      case MathOperationType.division:
        return Colors.green;
      case MathOperationType.addition:
        return Colors.orange;
      case MathOperationType.subtraction:
        return Colors.purple;
    }
  }

  IconData _getOperationIcon(MathOperationType operation) {
    switch (operation) {
      case MathOperationType.multiplication:
        return Icons.close;
      case MathOperationType.division:
        return Icons.keyboard_arrow_right;
      case MathOperationType.addition:
        return Icons.add;
      case MathOperationType.subtraction:
        return Icons.remove;
    }
  }

  String _getOperationName(MathOperationType operation) {
    switch (operation) {
      case MathOperationType.multiplication:
        return '掛け算';
      case MathOperationType.division:
        return '割り算';
      case MathOperationType.addition:
        return '足し算';
      case MathOperationType.subtraction:
        return '引き算';
    }
  }

  Color _getAccuracyColor(ThemeData theme, double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 80) return Colors.blue;
    if (accuracy >= 70) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  List<String> _generateRecommendations(_LearningySummary summary) {
    final recommendations = <String>[];

    if (summary.totalPractices < 5) {
      recommendations.add('毎日少しずつでも練習を続けることが大切です');
    } else if (summary.averageScore < 70) {
      recommendations.add('${summary.weakestSubject}の基礎問題から始めてみましょう');
    } else {
      recommendations.add('素晴らしい成績です！この調子で続けてください');
    }

    if (summary.streakDays < 3) {
      recommendations.add('毎日の習慣づけを目指しましょう');
    } else {
      recommendations.add('継続的な学習ができています！');
    }

    recommendations.add('褒めることで子供のやる気を引き出しましょう');

    return recommendations;
  }
}

// Data classes
class _LearningySummary {
  const _LearningySummary({
    required this.totalPractices,
    required this.averageScore,
    required this.streakDays,
    required this.overallGrade,
    required this.strongestSubject,
    required this.weakestSubject,
  });

  final int totalPractices;
  final double averageScore;
  final int streakDays;
  final String overallGrade;
  final String strongestSubject;
  final String weakestSubject;
}

class _PerformanceData {
  const _PerformanceData({
    required this.overallAccuracy,
    required this.highestScore,
    required this.improvementTrend,
    required this.totalProblems,
    required this.subjectPerformances,
  });

  final double overallAccuracy;
  final double highestScore;
  final double improvementTrend;
  final int totalProblems;
  final Map<MathOperationType, double> subjectPerformances;
}

class _ProgressData {
  const _ProgressData({
    required this.totalPractices,
    required this.dailyStreak,
    required this.weeklyPractices,
    required this.averageAccuracy,
    required this.allSubjectsTried,
  });

  final double totalPractices;
  final double dailyStreak;
  final double weeklyPractices;
  final double averageAccuracy;
  final bool allSubjectsTried;
}

class _Milestone {
  const _Milestone(this.title, this.isAchieved, this.description);

  final String title;
  final bool isAchieved;
  final String description;
}

class _SimpleTrendPainter extends CustomPainter {
  const _SimpleTrendPainter({
    required this.scores,
    required this.primaryColor,
    required this.backgroundColor,
  });

  final List<ScoreRecord> scores;
  final Color primaryColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxScore = scores.map((s) => s.score).reduce((a, b) => a > b ? a : b);
    final minScore = scores.map((s) => s.score).reduce((a, b) => a < b ? a : b);
    final range = maxScore - minScore;

    final path = Path();
    for (int i = 0; i < scores.length; i++) {
      final x = (i / (scores.length - 1)) * size.width;
      final y =
          size.height - ((scores[i].score - minScore) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      final x = (i / (scores.length - 1)) * size.width;
      final y =
          size.height - ((scores[i].score - minScore) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
