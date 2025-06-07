import 'package:flutter/material.dart';
import '../models/score_record.dart';
import '../services/score_service.dart';

/// 励ましのダイアログウィジェット
class EncouragementDialog extends StatelessWidget {
  const EncouragementDialog({
    super.key,
    required this.scoreRecord,
    required this.improvement,
  });

  final ScoreRecord scoreRecord;
  final ScoreImprovement improvement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコンとアニメーション
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getColorForImprovement(improvement),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      improvement.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // タイトル
            Text(
              improvement.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // スコア情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${scoreRecord.operation.displayName}の結果',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${scoreRecord.correctAnswers}問正解 / '
                    '${scoreRecord.totalQuestions}問',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    '正答率: ${scoreRecord.accuracyPercentage}%',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getColorForScore(scoreRecord.accuracyPercentage),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 励ましのメッセージ
            Text(
              improvement.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // ホーム画面に戻る
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('ホームに戻る'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForImprovement(ScoreImprovement improvement) {
    switch (improvement) {
      case ScoreImprovement.improved:
        return Colors.green;
      case ScoreImprovement.same:
        return Colors.blue;
      case ScoreImprovement.declined:
        return Colors.orange;
      case ScoreImprovement.noData:
        return Colors.grey;
    }
  }

  Color _getColorForScore(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.blue;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }
}
