import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syonan_app/data/datasources/score_record_local_datasource.dart';
import 'package:syonan_app/data/models/score_record_model.dart';
import 'package:syonan_app/domain/entities/score_record_entity.dart';

void main() {
  group('ScoreRecordLocalDataSource Tests', () {
    late ScoreRecordLocalDataSource dataSource;
    late SharedPreferences mockPrefs;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      dataSource = ScoreRecordLocalDataSource(mockPrefs);
    });

    tearDown(() async {
      await dataSource.clearAllScoreRecords();
    });

    group('saveScoreRecord', () {
      test('should save score record successfully', () async {
        // Arrange
        final scoreRecord = ScoreRecordModel(
          id: 'test-id-1',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 85,
          correctCount: 17,
          wrongAnswers: 3,
          totalCount: 20,
          accuracy: 0.85,
          duration: const Duration(minutes: 5),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          answerResults: [true, true, false, true, true],
          pointsEarned: 170,
        );

        // Act
        await dataSource.saveScoreRecord(scoreRecord);

        // Assert
        final savedRecords = await dataSource.getAllScoreRecords();
        expect(savedRecords, hasLength(1));
        expect(savedRecords.first.id, 'test-id-1');
        expect(savedRecords.first.score, 85);
      });

      test('should save multiple score records', () async {
        // Arrange
        final record1 = ScoreRecordModel(
          id: 'test-id-1',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 85,
          correctCount: 17,
          wrongAnswers: 3,
          totalCount: 20,
          accuracy: 0.85,
          duration: const Duration(minutes: 5),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          answerResults: [true, true, false, true, true],
          pointsEarned: 170,
        );

        final record2 = ScoreRecordModel(
          id: 'test-id-2',
          userId: 'user-2',
          gameType: GameType.speedMath,
          operation: MathOperationType.addition,
          score: 90,
          correctCount: 18,
          wrongAnswers: 2,
          totalCount: 20,
          accuracy: 0.90,
          duration: const Duration(minutes: 3),
          difficultyLevel: 1,
          timestamp: DateTime(2024, 1, 1, 11, 0),
          answerResults: [true, true, true, false, true],
          pointsEarned: 180,
        );

        // Act
        await dataSource.saveScoreRecord(record1);
        await dataSource.saveScoreRecord(record2);

        // Assert
        final savedRecords = await dataSource.getAllScoreRecords();
        expect(savedRecords, hasLength(2));
      });
    });

    group('getScoreRecordsByUser', () {
      test('should return scores for specific user', () async {
        // Arrange
        final record1 = ScoreRecordModel(
          id: 'test-id-1',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 85,
          correctCount: 17,
          wrongAnswers: 3,
          totalCount: 20,
          accuracy: 0.85,
          duration: const Duration(minutes: 5),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          answerResults: [true, true, false, true, true],
          pointsEarned: 170,
        );

        final record2 = ScoreRecordModel(
          id: 'test-id-2',
          userId: 'user-2',
          gameType: GameType.speedMath,
          operation: MathOperationType.addition,
          score: 90,
          correctCount: 18,
          wrongAnswers: 2,
          totalCount: 20,
          accuracy: 0.90,
          duration: const Duration(minutes: 3),
          difficultyLevel: 1,
          timestamp: DateTime(2024, 1, 1, 11, 0),
          answerResults: [true, true, true, false, true],
          pointsEarned: 180,
        );

        await dataSource.saveScoreRecord(record1);
        await dataSource.saveScoreRecord(record2);

        // Act
        final userScores = await dataSource.getScoreRecordsByUser('user-1');

        // Assert
        expect(userScores, hasLength(1));
        expect(userScores.first.userId, 'user-1');
        expect(userScores.first.score, 85);
      });
    });

    group('getScoreRecordsByGameType', () {
      test('should return scores for specific game type', () async {
        // Arrange
        final record1 = ScoreRecordModel(
          id: 'test-id-1',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 85,
          correctCount: 17,
          wrongAnswers: 3,
          totalCount: 20,
          accuracy: 0.85,
          duration: const Duration(minutes: 5),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          answerResults: [true, true, false, true, true],
          pointsEarned: 170,
        );

        final record2 = ScoreRecordModel(
          id: 'test-id-2',
          userId: 'user-1',
          gameType: GameType.speedMath,
          operation: MathOperationType.addition,
          score: 90,
          correctCount: 18,
          wrongAnswers: 2,
          totalCount: 20,
          accuracy: 0.90,
          duration: const Duration(minutes: 3),
          difficultyLevel: 1,
          timestamp: DateTime(2024, 1, 1, 11, 0),
          answerResults: [true, true, true, false, true],
          pointsEarned: 180,
        );

        await dataSource.saveScoreRecord(record1);
        await dataSource.saveScoreRecord(record2);

        // Act
        final mathPracticeScores = await dataSource.getScoreRecordsByGameType(
          GameType.mathPractice,
        );

        // Assert
        expect(mathPracticeScores, hasLength(1));
        expect(mathPracticeScores.first.gameType, GameType.mathPractice);
        expect(mathPracticeScores.first.score, 85);
      });
    });

    group('getBestScore', () {
      test('should return highest score', () async {
        // Arrange
        final record1 = ScoreRecordModel(
          id: 'test-id-1',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 85,
          correctCount: 17,
          wrongAnswers: 3,
          totalCount: 20,
          accuracy: 0.85,
          duration: const Duration(minutes: 5),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          answerResults: [true, true, false, true, true],
          pointsEarned: 170,
        );

        final record2 = ScoreRecordModel(
          id: 'test-id-2',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 95,
          correctCount: 19,
          wrongAnswers: 1,
          totalCount: 20,
          accuracy: 0.95,
          duration: const Duration(minutes: 4),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 11, 0),
          answerResults: [true, true, true, false, true],
          pointsEarned: 190,
        );

        await dataSource.saveScoreRecord(record1);
        await dataSource.saveScoreRecord(record2);

        // Act
        final bestScore = await dataSource.getBestScore(
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
        );

        // Assert
        expect(bestScore, isNotNull);
        expect(bestScore!.score, 95);
        expect(bestScore.id, 'test-id-2');
      });

      test('should return null when no scores exist', () async {
        // Act
        final bestScore = await dataSource.getBestScore(
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
        );

        // Assert
        expect(bestScore, isNull);
      });
    });

    group('getScoreStatistics', () {
      test('should return correct statistics', () async {
        // Arrange
        final record1 = ScoreRecordModel(
          id: 'test-id-1',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 80,
          correctCount: 16,
          wrongAnswers: 4,
          totalCount: 20,
          accuracy: 0.80,
          duration: const Duration(minutes: 5),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          answerResults: [true, true, false, true, true],
          pointsEarned: 160,
        );

        final record2 = ScoreRecordModel(
          id: 'test-id-2',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 90,
          correctCount: 18,
          wrongAnswers: 2,
          totalCount: 20,
          accuracy: 0.90,
          duration: const Duration(minutes: 4),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 11, 0),
          answerResults: [true, true, true, false, true],
          pointsEarned: 180,
        );

        await dataSource.saveScoreRecord(record1);
        await dataSource.saveScoreRecord(record2);

        // Act
        final stats = await dataSource.getScoreStatistics();

        // Assert
        expect(stats['totalGames'], 2);
        expect(stats['averageScore'], 85.0);
        expect(stats['averageAccuracy'], closeTo(0.85, 0.001));
        expect(stats['bestScore'], 90);
      });

      test('should return empty statistics when no scores exist', () async {
        // Act
        final stats = await dataSource.getScoreStatistics();

        // Assert
        expect(stats['totalGames'], 0);
        expect(stats['averageScore'], 0.0);
        expect(stats['averageAccuracy'], 0.0);
        expect(stats['bestScore'], 0);
      });
    });

    group('deleteScoreRecord', () {
      test('should delete specific score record', () async {
        // Arrange
        final record = ScoreRecordModel(
          id: 'test-id-1',
          userId: 'user-1',
          gameType: GameType.mathPractice,
          operation: MathOperationType.multiplication,
          score: 85,
          correctCount: 17,
          wrongAnswers: 3,
          totalCount: 20,
          accuracy: 0.85,
          duration: const Duration(minutes: 5),
          difficultyLevel: 2,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          answerResults: [true, true, false, true, true],
          pointsEarned: 170,
        );

        await dataSource.saveScoreRecord(record);

        // Act
        await dataSource.deleteScoreRecord('test-id-1');

        // Assert
        final records = await dataSource.getAllScoreRecords();
        expect(records, isEmpty);
      });
    });
  });
}
