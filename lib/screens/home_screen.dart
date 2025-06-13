import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/math_problem.dart';
import '../services/points_service.dart';
import '../services/score_service.dart';
import '../utils/build_info.dart';
import '../widgets/points_card.dart';
import '../widgets/practice_button.dart';
import '../widgets/stat_card.dart';
import 'achievements_screen.dart';
import 'practice_screen.dart';
import 'score_history_screen.dart';

/// ホーム画面
/// アプリのメイン画面で、練習選択とスコア概要を表示
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // アプリ起動時にサービスを初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoreService>().initialize();
      context.read<PointsService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreService = context.watch<ScoreService>();
    final pointsService = context.watch<PointsService>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: scoreService.isLoading || pointsService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    _buildHeader(theme),
                    const SizedBox(height: 24),

                    // ポイント表示
                    _buildPointsSection(pointsService),
                    const SizedBox(height: 24),

                    // 練習ボタン
                    _buildPracticeSection(theme),
                    const SizedBox(height: 32),

                    // 統計情報
                    _buildStatsSection(theme, scoreService),
                    const SizedBox(height: 24),

                    // スコア履歴ボタン
                    _buildScoreHistoryButton(theme),
                    const SizedBox(height: 24),

                    // ビルド情報
                    _buildBuildInfo(theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '算数れんしゅう',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '今日も楽しく勉強しましょう！',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSection(PointsService pointsService) {
    return PointsCard(
      points: pointsService.totalPoints,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AchievementsScreen(),
          ),
        );
      },
    );
  }

  Widget _buildPracticeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '練習する',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '長押しで難易度を選択できます',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PracticeButton(
                title: '掛け算',
                subtitle: '九九の練習',
                icon: Icons.close,
                color: Colors.blue,
                onTap: () => _startPractice(MathOperationType.multiplication),
                onLongPress: () => _showDifficultyDialog(MathOperationType.multiplication),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PracticeButton(
                title: '割り算',
                subtitle: '割り算の練習',
                icon: Icons.more_horiz,
                color: Colors.green,
                onTap: () => _startPractice(MathOperationType.division),
                onLongPress: () => _showDifficultyDialog(MathOperationType.division),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PracticeButton(
                title: '足し算',
                subtitle: '足し算の練習',
                icon: Icons.add,
                color: Colors.orange,
                onTap: () => _startPractice(MathOperationType.addition),
                onLongPress: () => _showDifficultyDialog(MathOperationType.addition),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PracticeButton(
                title: '引き算',
                subtitle: '引き算の練習',
                icon: Icons.remove,
                color: Colors.purple,
                onTap: () => _startPractice(MathOperationType.subtraction),
                onLongPress: () => _showDifficultyDialog(MathOperationType.subtraction),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme, ScoreService scoreService) {
    final streakDays = scoreService.getStreakDays();
    final weeklyCount = scoreService.getWeeklyPracticeCount();
    final multiplicationAvg = scoreService.getAverageScore(
      MathOperationType.multiplication,
    );
    final divisionAvg = scoreService.getAverageScore(
      MathOperationType.division,
    );
    final additionAvg = scoreService.getAverageScore(
      MathOperationType.addition,
    );
    final subtractionAvg = scoreService.getAverageScore(
      MathOperationType.subtraction,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'あなたの記録',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '連続練習',
                value: '$streakDays日',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: '今週の練習',
                value: '$weeklyCount回',
                icon: Icons.calendar_today,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '掛け算平均',
                value: '${(multiplicationAvg * 100).round()}%',
                icon: Icons.close,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: '割り算平均',
                value: '${(divisionAvg * 100).round()}%',
                icon: Icons.more_horiz,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '足し算平均',
                value: '${(additionAvg * 100).round()}%',
                icon: Icons.add,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: '引き算平均',
                value: '${(subtractionAvg * 100).round()}%',
                icon: Icons.remove,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreHistoryButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScoreHistoryScreen(),
            ),
          );
        },
        icon: const Icon(Icons.history),
        label: const Text('スコア履歴を見る'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget _buildBuildInfo(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'アプリ情報',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // タップで詳細表示
              GestureDetector(
                onTap: () => _showBuildDetails(theme),
                child: Icon(
                  Icons.help_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '最終更新: ${BuildInfo.getBuildDateTime()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'バージョン: ${BuildInfo.getBuildNumber()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showBuildDetails(ThemeData theme) {
    final buildInfo = BuildInfo.getAllInfo();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.code),
            SizedBox(width: 8),
            Text('詳細ビルド情報'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('最終更新', buildInfo['buildDateTime']!),
            _buildInfoRow('ビルド番号', buildInfo['buildNumber']!),
            _buildInfoRow('コミット', buildInfo['commitHash']!),
            const SizedBox(height: 16),
            Text(
              'この情報は、GitHub Pagesが正しく更新されているかを確認するために表示されています。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  void _startPractice(MathOperationType operation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PracticeScreen(operation: operation),
      ),
    );
  }

  void _showDifficultyDialog(MathOperationType operation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('${operation.displayName}の難易度を選んでください'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyButton(
              context,
              '初級',
              'かんたんな問題',
              Icons.sentiment_satisfied,
              Colors.green,
              1,
              operation,
            ),
            const SizedBox(height: 8),
            _buildDifficultyButton(
              context,
              '中級',
              'ふつうの問題',
              Icons.sentiment_neutral,
              Colors.orange,
              3,
              operation,
            ),
            const SizedBox(height: 8),
            _buildDifficultyButton(
              context,
              'エキスパート',
              'とても難しい問題',
              Icons.emoji_events,
              Colors.red,
              5,
              operation,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    int difficulty,
    MathOperationType operation,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PracticeScreen(
                operation: operation,
                difficultyLevel: difficulty,
              ),
            ),
          );
        },
        icon: Icon(icon),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          minimumSize: const Size(double.infinity, 60),
        ),
      ),
    );
  }
}
