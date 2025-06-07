import 'package:flutter/material.dart';
import '../models/math_problem.dart';

/// 算数問題を表示するカードウィジェット
class ProblemCard extends StatelessWidget {
  const ProblemCard({super.key, required this.problem});

  final MathProblem problem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
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
                problem.operation == MathOperationType.multiplication
                    ? Icons.close
                    : Icons.more_horiz,
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
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
