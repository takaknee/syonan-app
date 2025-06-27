import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/achievement.dart';
import '../services/points_service.dart';

/// 実績・バッジ画面
/// ユーザーの実績表示とポイントでの実績解除ができる画面
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pointsService = context.watch<PointsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('バッジコレクション'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'もっているバッジ'),
            Tab(text: 'かえるバッジ'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ポイント表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${pointsService.totalPoints} ポイント',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // タブビュー
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOwnedAchievements(pointsService),
                _buildAvailableAchievements(pointsService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedAchievements(PointsService pointsService) {
    final ownedAchievements = pointsService.getUserAchievementDetails();

    if (ownedAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'まだバッジがありません',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'れんしゅうしてポイントをためて\nバッジをかいましょう！',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: ownedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = ownedAchievements[index];
        return _buildAchievementCard(achievement, owned: true);
      },
    );
  }

  Widget _buildAvailableAchievements(PointsService pointsService) {
    final availableAchievements = pointsService.getAvailableAchievements();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: availableAchievements.length,
      itemBuilder: (context, index) {
        final achievement = availableAchievements[index];
        final canAfford = pointsService.totalPoints >= achievement.pointsCost;

        return _buildAchievementCard(
          achievement,
          owned: false,
          canAfford: canAfford,
          onPurchase: () => _purchaseAchievement(achievement),
        );
      },
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement, {
    required bool owned,
    bool canAfford = false,
    VoidCallback? onPurchase,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: owned ? null : (canAfford ? onPurchase : null),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // バッジの絵文字
              Text(
                achievement.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),

              // バッジの名前
              Text(
                achievement.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // バッジの説明
              Text(
                achievement.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (!owned) ...[
                const SizedBox(height: 8),
                // ポイントコストとボタン
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canAfford ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: canAfford ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${achievement.pointsCost}P',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: canAfford ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                // 取得済みマーク
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GET!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchaseAchievement(Achievement achievement) async {
    final pointsService = context.read<PointsService>();
    final theme = Theme.of(context);

    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('バッジをかいますか？'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${achievement.pointsCost} ポイントをつかいます',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('やめる'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('かう'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await pointsService.unlockAchievement(achievement.id);

      if (success) {
        // 成功メッセージを表示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${achievement.title} をかいました！'),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        }
      } else {
        // エラーメッセージを表示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('バッジをかえませんでした'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
