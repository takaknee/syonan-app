import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/models/score_record.dart';
import 'package:syonan_app/models/math_problem.dart';

void main() {
  group('ScoreRecord', () {
    test('should calculate accuracy correctly', () {
      final scoreRecord = ScoreRecord(
        id: '1',
        date: DateTime.now(),
        operation: MathOperationType.multiplication,
        correctAnswers: 8,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      expect(scoreRecord.accuracy, 0.8);
      expect(scoreRecord.accuracyPercentage, 80);
    });

    test('should handle zero questions correctly', () {
      final scoreRecord = ScoreRecord(
        id: '1',
        date: DateTime.now(),
        operation: MathOperationType.multiplication,
        correctAnswers: 0,
        totalQuestions: 0,
        timeSpent: const Duration(minutes: 5),
      );

      expect(scoreRecord.accuracy, 0.0);
      expect(scoreRecord.accuracyPercentage, 0);
    });

    test('should determine correct score level', () {
      final excellentScore = ScoreRecord(
        id: '1',
        date: DateTime.now(),
        operation: MathOperationType.multiplication,
        correctAnswers: 9,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      final goodScore = ScoreRecord(
        id: '2',
        date: DateTime.now(),
        operation: MathOperationType.multiplication,
        correctAnswers: 8,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      final fairScore = ScoreRecord(
        id: '3',
        date: DateTime.now(),
        operation: MathOperationType.multiplication,
        correctAnswers: 7,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      final needsPracticeScore = ScoreRecord(
        id: '4',
        date: DateTime.now(),
        operation: MathOperationType.multiplication,
        correctAnswers: 6,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      expect(excellentScore.level, ScoreLevel.excellent);
      expect(goodScore.level, ScoreLevel.good);
      expect(fairScore.level, ScoreLevel.fair);
      expect(needsPracticeScore.level, ScoreLevel.needsPractice);
    });

    test('should convert to and from JSON', () {
      final originalScore = ScoreRecord(
        id: 'test_123',
        date: DateTime(2024, 1, 15, 10, 30),
        operation: MathOperationType.division,
        correctAnswers: 7,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 3, seconds: 45),
      );

      final json = originalScore.toJson();
      final recreatedScore = ScoreRecord.fromJson(json);

      expect(recreatedScore.id, originalScore.id);
      expect(recreatedScore.date, originalScore.date);
      expect(recreatedScore.operation, originalScore.operation);
      expect(recreatedScore.correctAnswers, originalScore.correctAnswers);
      expect(recreatedScore.totalQuestions, originalScore.totalQuestions);
      expect(recreatedScore.timeSpent, originalScore.timeSpent);
    });

    test('should implement equality correctly', () {
      final score1 = ScoreRecord(
        id: '1',
        date: DateTime(2024, 1, 1),
        operation: MathOperationType.multiplication,
        correctAnswers: 8,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      final score2 = ScoreRecord(
        id: '1',
        date: DateTime(2024, 1, 1),
        operation: MathOperationType.multiplication,
        correctAnswers: 8,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      final score3 = ScoreRecord(
        id: '2',
        date: DateTime(2024, 1, 1),
        operation: MathOperationType.multiplication,
        correctAnswers: 8,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
      );

      expect(score1, score2);
      expect(score1, isNot(score3));
    });
  });

  group('ScoreLevel', () {
    test('should have correct messages and emojis', () {
      expect(ScoreLevel.excellent.message, 'すばらしい！');
      expect(ScoreLevel.excellent.emoji, '🌟');
      
      expect(ScoreLevel.good.message, 'よくできました！');
      expect(ScoreLevel.good.emoji, '⭐');
      
      expect(ScoreLevel.fair.message, 'がんばりました！');
      expect(ScoreLevel.fair.emoji, '👏');
      
      expect(ScoreLevel.needsPractice.message, 'もう少しれんしゅうしよう！');
      expect(ScoreLevel.needsPractice.emoji, '💪');
    });
  });
}