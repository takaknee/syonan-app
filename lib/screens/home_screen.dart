import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/math_problem.dart';
import '../services/score_service.dart';
import 'practice_screen.dart';
import 'score_history_screen.dart';
import '../widgets/stat_card.dart';
import '../widgets/practice_button.dart';

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
    // アプリ起動時にスコアサービスを初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoreService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreService = context.watch<ScoreService>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: scoreService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    _buildHeader(theme),
                    const SizedBox(height: 32),

                    // 練習ボタン
                    _buildPracticeSection(theme),
                    const SizedBox(height: 32),

                    // 統計情報
                    _buildStatsSection(theme, scoreService),
                    const SizedBox(height: 24),

                    // スコア履歴ボタン
                    _buildScoreHistoryButton(theme),
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
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
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
    final multiplicationAvg = scoreService.getAverageScore(MathOperationType.multiplication);
    final divisionAvg = scoreService.getAverageScore(MathOperationType.division);

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

  void _startPractice(MathOperationType operation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PracticeScreen(operation: operation),
      ),
    );
  }
}
