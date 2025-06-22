import 'package:flutter/material.dart';
import '../models/math_problem.dart';
import '../utils/responsive_utils.dart';

/// 算数問題を表示するカードウィジェット
class ProblemCard extends StatelessWidget {
  const ProblemCard({super.key, required this.problem});

  final MathProblem problem;

  /// 操作タイプに応じたアイコンを取得
  IconData _getOperationIcon(MathOperationType operation) {
    switch (operation) {
      case MathOperationType.multiplication:
        return Icons.close;
      case MathOperationType.division:
        return Icons.more_horiz;
      case MathOperationType.addition:
        return Icons.add;
      case MathOperationType.subtraction:
        return Icons.remove;
    }
  }

  /// 視覚的補助が必要かどうかを判定
  bool _shouldShowVisualAid(MathProblem problem) {
    // 小さい数（10以下）の足し算と引き算のみ視覚的補助を表示
    return (problem.operation == MathOperationType.addition || problem.operation == MathOperationType.subtraction) &&
        problem.firstNumber <= 10 &&
        problem.secondNumber <= 10;
  }

  /// 視覚的補助を構築
  Widget _buildVisualAid(MathProblem problem, ThemeData theme) {
    const String itemEmoji = '🟦'; // 青い四角を使用

    List<Widget> visual = [];

    if (problem.operation == MathOperationType.addition) {
      // 足し算の視覚的表現
      visual.add(
        Text(
          itemEmoji * problem.firstNumber,
          style: const TextStyle(fontSize: 16),
        ),
      );
      visual.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '+',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
      visual.add(
        Text(
          itemEmoji * problem.secondNumber,
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else if (problem.operation == MathOperationType.subtraction) {
      // 引き算の視覚的表現
      final remaining = problem.firstNumber - problem.secondNumber;
      visual.add(
        Text(
          itemEmoji * remaining + '❌' * problem.secondNumber,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: visual,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ResponsiveUtils.getVerticalPadding(context) * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 操作タイプのアイコン
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getOperationIcon(problem.operation),
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(height: 24),

            // 問題文
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 第一数値
                Text(
                  '${problem.firstNumber}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 16),

                // 演算子
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    problem.operation.symbol,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 第二数値
                Text(
                  '${problem.secondNumber}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 16),

                // 等号
                Text(
                  '=',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 16),

                // クエスチョンマーク
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '?',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: ResponsiveUtils.isMobile(context) ? 36 : 48,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // Visual aid for small numbers
            if (_shouldShowVisualAid(problem))
              Column(
                children: [
                  SizedBox(height: ResponsiveUtils.getSpacing(context)),
                  _buildVisualAid(problem, theme),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
