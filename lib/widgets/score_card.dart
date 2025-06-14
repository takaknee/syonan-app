import 'package:flutter/material.dart';

import '../models/math_problem.dart';
import '../models/score_record.dart';

/// スコア記録を表示するカードウィジェット
class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.scoreRecord,
    this.isBest = false,
    this.showImprovement = false,
    this.previousScore,
    this.isCompact = false,
  });

  final ScoreRecord scoreRecord;
  final bool isBest;
  final bool showImprovement;
  final ScoreRecord? previousScore;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isBest ? 8 : 2,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isBest
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.withValues(alpha: 0.1),
                    Colors.amber.withValues(alpha: 0.05),
                  ],
                )
              : null,
        ),
        child: isCompact ? _buildCompactContent(theme) : _buildFullContent(theme),
      ),
    );
  }

  Widget _buildCompactContent(ThemeData theme) {
    return Row(
      children: [
        // 操作アイコン
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getOperationColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            scoreRecord.operation == MathOperationType.multiplication ? Icons.close : Icons.more_horiz,
            color: _getOperationColor(),
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        // スコア情報
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scoreRecord.operation.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${scoreRecord.accuracyPercentage}% '
                '(${scoreRecord.correctAnswers}/${scoreRecord.totalQuestions})',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),

        // 日付
        Text(
          _formatDate(scoreRecord.date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヘッダー行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 操作タイプと日付
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      scoreRecord.operation == MathOperationType.multiplication ? Icons.close : Icons.more_horiz,
                      color: _getOperationColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      scoreRecord.operation.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  ],
                ),
                Text(
                  _formatDateTime(scoreRecord.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            // レベルバッジ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getLevelColor(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scoreRecord.level.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    scoreRecord.level.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // スコア詳細
        Row(
          children: [
            Expanded(
              child: _buildScoreDetail(
                theme,
                '正答率',
                '${scoreRecord.accuracyPercentage}%',
                _getAccuracyColor(scoreRecord.accuracyPercentage),
              ),
            ),
            Expanded(
              child: _buildScoreDetail(
                theme,
                '正解数',
                '${scoreRecord.correctAnswers}/${scoreRecord.totalQuestions}',
                theme.colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildScoreDetail(
                theme,
                '所要時間',
                _formatDuration(scoreRecord.timeSpent),
                theme.colorScheme.secondary,
              ),
            ),
          ],
        ),

        // 改善度表示
        if (showImprovement && previousScore != null) ...[
          const SizedBox(height: 8),
          _buildImprovementIndicator(theme),
        ],
      ],
    );
  }

  Widget _buildScoreDetail(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementIndicator(ThemeData theme) {
    if (previousScore == null) return const SizedBox.shrink();

    final currentPercentage = scoreRecord.accuracyPercentage;
    final previousPercentage = previousScore!.accuracyPercentage;
    final difference = currentPercentage - previousPercentage;

    final IconData icon;
    final Color color;
    final String text;

    if (difference > 0) {
      icon = Icons.arrow_upward;
      color = Colors.green;
      text = '+$difference%';
    } else if (difference < 0) {
      icon = Icons.arrow_downward;
      color = Colors.red;
      text = '$difference%';
    } else {
      icon = Icons.arrow_forward;
      color = Colors.grey;
      text = '変化なし';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getOperationColor() {
    return scoreRecord.operation == MathOperationType.multiplication ? Colors.blue : Colors.green;
  }

  Color _getLevelColor() {
    switch (scoreRecord.level) {
      case ScoreLevel.excellent:
        return Colors.green;
      case ScoreLevel.good:
        return Colors.blue;
      case ScoreLevel.fair:
        return Colors.orange;
      case ScoreLevel.needsPractice:
        return Colors.red;
    }
  }

  Color _getAccuracyColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.blue;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}/${date.month}/${date.day} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes分$seconds秒';
    } else {
      return '$seconds秒';
    }
  }
}
