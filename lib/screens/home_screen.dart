import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coming_soon_feature.dart';
import '../models/math_problem.dart';
import '../models/mini_game.dart';
import '../services/mini_game_service.dart';
import '../services/points_service.dart';
import '../services/score_service.dart';
import '../utils/build_info.dart';
import '../widgets/feature_card.dart';
import '../widgets/mini_game_button.dart';
import '../widgets/points_card.dart';
import '../widgets/practice_button.dart';
import '../widgets/stat_card.dart';
import 'achievements_screen.dart';
import 'ai_tutor_screen.dart';
import 'city_builder_game_screen.dart';
import 'dodge_game_screen.dart';
import 'multiplayer_battle_screen.dart';
import 'number_memory_game_screen.dart';
import 'number_puzzle_game_screen.dart';
import 'parent_dashboard_screen.dart';
import 'practice_screen.dart';
import 'rhythm_tap_game_screen.dart';
import 'score_history_screen.dart';
import 'sliding_puzzle_game_screen.dart';
import 'speed_math_game_screen.dart';
import 'story_mode_screen.dart';
import 'strategy_battle_game_screen.dart';
import 'water_margin_game_screen.dart';

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
      context.read<MiniGameService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreService = context.watch<ScoreService>();
    final pointsService = context.watch<PointsService>();
    final miniGameService = context.watch<MiniGameService>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: scoreService.isLoading ||
                pointsService.isLoading ||
                miniGameService.isLoading
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

                    // ミニゲーム
                    _buildMiniGamesSection(
                        theme, pointsService, miniGameService),
                    const SizedBox(height: 32),

                    // 新機能
                    _buildFeaturesSection(theme),
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
                onLongPress: () =>
                    _showDifficultyDialog(MathOperationType.multiplication),
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
                onLongPress: () =>
                    _showDifficultyDialog(MathOperationType.division),
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
                onLongPress: () =>
                    _showDifficultyDialog(MathOperationType.addition),
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
                onLongPress: () =>
                    _showDifficultyDialog(MathOperationType.subtraction),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniGamesSection(
    ThemeData theme,
    PointsService pointsService,
    MiniGameService miniGameService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ミニゲーム',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ポイントを使って楽しいゲームで遊ぼう！',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        // First row - Study games
        Row(
          children: [
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'number_memory'),
                hasEnoughPoints: pointsService.totalPoints >= 10,
                playCount: miniGameService.getPlayCount('number_memory'),
                bestScore: miniGameService.getBestScore('number_memory'),
                onTap: () => _startMiniGame('number_memory', pointsService),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'speed_math'),
                hasEnoughPoints: pointsService.totalPoints >= 15,
                playCount: miniGameService.getPlayCount('speed_math'),
                bestScore: miniGameService.getBestScore('speed_math'),
                onTap: () => _startMiniGame('speed_math', pointsService),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - Entertainment games
        Row(
          children: [
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'sliding_puzzle'),
                hasEnoughPoints: pointsService.totalPoints >= 8,
                playCount: miniGameService.getPlayCount('sliding_puzzle'),
                bestScore: miniGameService.getBestScore('sliding_puzzle'),
                onTap: () => _startMiniGame('sliding_puzzle', pointsService),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'rhythm_tap'),
                hasEnoughPoints: pointsService.totalPoints >= 12,
                playCount: miniGameService.getPlayCount('rhythm_tap'),
                bestScore: miniGameService.getBestScore('rhythm_tap'),
                onTap: () => _startMiniGame('rhythm_tap', pointsService),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Third row - Action game (centered)
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: MiniGameButton(
              miniGame: AvailableMiniGames.all
                  .firstWhere((game) => game.id == 'dodge_game'),
              hasEnoughPoints: pointsService.totalPoints >= 10,
              playCount: miniGameService.getPlayCount('dodge_game'),
              bestScore: miniGameService.getBestScore('dodge_game'),
              onTap: () => _startMiniGame('dodge_game', pointsService),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Fourth row - Advanced puzzle games
        Row(
          children: [
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'number_puzzle'),
                hasEnoughPoints: pointsService.totalPoints >= 12,
                playCount: miniGameService.getPlayCount('number_puzzle'),
                bestScore: miniGameService.getBestScore('number_puzzle'),
                onTap: () => _startMiniGame('number_puzzle', pointsService),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'strategy_battle'),
                hasEnoughPoints: pointsService.totalPoints >= 18,
                playCount: miniGameService.getPlayCount('strategy_battle'),
                bestScore: miniGameService.getBestScore('strategy_battle'),
                onTap: () => _startMiniGame('strategy_battle', pointsService),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Fifth row - Strategy games
        Row(
          children: [
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'water_margin'),
                hasEnoughPoints: pointsService.totalPoints >= 25,
                playCount: miniGameService.getPlayCount('water_margin'),
                bestScore: miniGameService.getBestScore('water_margin'),
                onTap: () => _startMiniGame('water_margin', pointsService),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MiniGameButton(
                miniGame: AvailableMiniGames.all
                    .firstWhere((game) => game.id == 'city_builder'),
                hasEnoughPoints: pointsService.totalPoints >= 20,
                playCount: miniGameService.getPlayCount('city_builder'),
                bestScore: miniGameService.getBestScore('city_builder'),
                onTap: () => _startMiniGame('city_builder', pointsService),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '新機能',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '楽しい学習機能を使ってみましょう！',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        // First row
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                feature: ComingSoonFeatures.all
                    .firstWhere((feature) => feature.id == 'ai_tutor'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AiTutorScreen()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FeatureCard(
                feature: ComingSoonFeatures.all.firstWhere(
                    (feature) => feature.id == 'multiplayer_battle'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MultiplayerBattleScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                feature: ComingSoonFeatures.all
                    .firstWhere((feature) => feature.id == 'story_mode'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StoryModeScreen()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FeatureCard(
                feature: ComingSoonFeatures.all
                    .firstWhere((feature) => feature.id == 'parent_dashboard'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParentDashboardScreen()),
                ),
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

  void _startMiniGame(String gameId, PointsService pointsService) async {
    final game = AvailableMiniGames.findById(gameId);
    if (game == null) return;

    // ポイント消費の確認
    if (pointsService.totalPoints < game.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ポイントが足りません（必要: ${game.pointsCost}P）'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ポイント消費の確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(game.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(game.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(game.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(game.color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(game.color)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Color(game.color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${game.pointsCost}ポイント消費',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(game.color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('開始'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ポイントを消費
    final success = await pointsService.spendPoints(game.pointsCost);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ポイントの消費に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 対応するゲーム画面に遷移
    Widget gameScreen;
    switch (gameId) {
      case 'number_memory':
        gameScreen = const NumberMemoryGameScreen();
        break;
      case 'speed_math':
        gameScreen = const SpeedMathGameScreen();
        break;
      case 'sliding_puzzle':
        gameScreen = const SlidingPuzzleGameScreen();
        break;
      case 'rhythm_tap':
        gameScreen = const RhythmTapGameScreen();
        break;
      case 'dodge_game':
        gameScreen = const DodgeGameScreen();
        break;
      case 'number_puzzle':
        gameScreen = const NumberPuzzleGameScreen();
        break;
      case 'strategy_battle':
        gameScreen = const StrategyBattleGameScreen();
        break;
      case 'water_margin':
        gameScreen = const WaterMarginGameScreen();
        break;
      case 'city_builder':
        gameScreen = const CityBuilderGameScreen();
        break;
      default:
        return;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => gameScreen,
      ),
    );
  }
}
