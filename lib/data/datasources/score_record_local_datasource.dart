import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/score_record_entity.dart';
import '../models/score_record_model.dart';

/// スコア記録のローカルデータソース
class ScoreRecordLocalDataSource {
  final SharedPreferences _prefs;

  static const String _scoresKey = 'score_records';
  static const String _statsKey = 'score_statistics';

  ScoreRecordLocalDataSource(this._prefs);

  /// スコア記録を保存
  Future<void> saveScoreRecord(ScoreRecordModel scoreRecord) async {
    try {
      final scores = await getAllScoreRecords();
      scores.add(scoreRecord);

      final jsonList = scores.map((score) => score.toJson()).toList();
      await _prefs.setString(_scoresKey, jsonEncode(jsonList));

      // 統計も更新
      await _updateStatistics(scoreRecord);
    } catch (e) {
      throw DataException(
        message: 'スコア記録の保存中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 全スコア記録を取得
  Future<List<ScoreRecordModel>> getAllScoreRecords() async {
    try {
      final jsonString = _prefs.getString(_scoresKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map(
              (json) => ScoreRecordModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DataException(
        message: 'スコア記録の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// ユーザー別のスコア記録を取得
  Future<List<ScoreRecordModel>> getScoreRecordsByUser(String userId) async {
    try {
      final all = await getAllScoreRecords();
      return all.where((score) => score.userId == userId).toList();
    } catch (e) {
      throw DataException(
        message: 'ユーザー別スコア記録の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// ゲームタイプ別のスコア記録を取得
  Future<List<ScoreRecordModel>> getScoreRecordsByGameType(
    GameType gameType, {
    String? userId,
  }) async {
    try {
      final all = await getAllScoreRecords();
      return all.where((score) {
        final matchesGameType = score.gameType == gameType;
        final matchesUser = userId == null || score.userId == userId;
        return matchesGameType && matchesUser;
      }).toList();
    } catch (e) {
      throw DataException(
        message: 'ゲームタイプ別スコア記録の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 操作タイプ別のスコア記録を取得
  Future<List<ScoreRecordModel>> getScoreRecordsByOperation(
    MathOperationType operation, {
    String? userId,
  }) async {
    try {
      final all = await getAllScoreRecords();
      return all.where((score) {
        final matchesOperation = score.operation == operation;
        final matchesUser = userId == null || score.userId == userId;
        return matchesOperation && matchesUser;
      }).toList();
    } catch (e) {
      throw DataException(
        message: '操作タイプ別スコア記録の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 最新のスコア記録を取得
  Future<List<ScoreRecordModel>> getRecentScoreRecords({
    int limit = 10,
    String? userId,
  }) async {
    try {
      final all = await getAllScoreRecords();
      final filtered = userId != null
          ? all.where((score) => score.userId == userId).toList()
          : all;

      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filtered.take(limit).toList();
    } catch (e) {
      throw DataException(
        message: '最新スコア記録の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// ベストスコアを取得
  Future<ScoreRecordModel?> getBestScore({
    GameType? gameType,
    MathOperationType? operation,
    String? userId,
  }) async {
    try {
      final all = await getAllScoreRecords();
      final filtered = all.where((score) {
        final matchesGameType = gameType == null || score.gameType == gameType;
        final matchesOperation =
            operation == null || score.operation == operation;
        final matchesUser = userId == null || score.userId == userId;
        return matchesGameType && matchesOperation && matchesUser;
      }).toList();

      if (filtered.isEmpty) return null;

      filtered.sort((a, b) => b.score.compareTo(a.score));
      return filtered.first;
    } catch (e) {
      throw DataException(
        message: 'ベストスコアの取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// スコア統計を取得
  Future<Map<String, dynamic>> getScoreStatistics({String? userId}) async {
    try {
      final scores = userId != null
          ? await getScoreRecordsByUser(userId)
          : await getAllScoreRecords();

      if (scores.isEmpty) {
        return {
          'totalGames': 0,
          'averageScore': 0.0,
          'averageAccuracy': 0.0,
          'totalTimeSpent': 0,
          'bestScore': 0,
          'gameTypeStats': <String, dynamic>{},
          'operationStats': <String, dynamic>{},
        };
      }

      final totalGames = scores.length;
      final averageScore =
          scores.map((s) => s.score).fold(0, (a, b) => a + b) / totalGames;
      final averageAccuracy =
          scores.map((s) => s.accuracy).fold(0.0, (a, b) => a + b) / totalGames;
      final totalTimeSpent =
          scores.map((s) => s.duration.inSeconds).fold(0, (a, b) => a + b);
      final bestScore =
          scores.map((s) => s.score).fold(0, (a, b) => a > b ? a : b);

      return {
        'totalGames': totalGames,
        'averageScore': averageScore,
        'averageAccuracy': averageAccuracy,
        'totalTimeSpent': totalTimeSpent,
        'bestScore': bestScore,
        'gameTypeStats': _calculateGameTypeStats(scores),
        'operationStats': _calculateOperationStats(scores),
      };
    } catch (e) {
      throw DataException(
        message: 'スコア統計の取得中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// スコア記録を削除
  Future<void> deleteScoreRecord(String id) async {
    try {
      final scores = await getAllScoreRecords();
      scores.removeWhere((score) => score.id == id);

      final jsonList = scores.map((score) => score.toJson()).toList();
      await _prefs.setString(_scoresKey, jsonEncode(jsonList));
    } catch (e) {
      throw DataException(
        message: 'スコア記録の削除中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 全スコア記録をクリア
  Future<void> clearAllScoreRecords() async {
    try {
      await _prefs.remove(_scoresKey);
      await _prefs.remove(_statsKey);
    } catch (e) {
      throw DataException(
        message: 'スコア記録のクリア中にエラーが発生しました',
        originalError: e,
      );
    }
  }

  /// 統計を更新（内部用）
  Future<void> _updateStatistics(ScoreRecordModel newRecord) async {
    try {
      final stats = _prefs.getString(_statsKey);
      Map<String, dynamic> currentStats =
          stats != null ? jsonDecode(stats) as Map<String, dynamic> : {};

      // 基本統計を更新
      currentStats['totalRecords'] = (currentStats['totalRecords'] ?? 0) + 1;
      currentStats['lastRecordedAt'] = DateTime.now().toIso8601String();

      // ゲームタイプ別統計
      final gameTypeKey = 'gameType_${newRecord.gameType.value}';
      currentStats[gameTypeKey] = (currentStats[gameTypeKey] ?? 0) + 1;

      // 操作タイプ別統計
      final operationKey = 'operation_${newRecord.operation.value}';
      currentStats[operationKey] = (currentStats[operationKey] ?? 0) + 1;

      await _prefs.setString(_statsKey, jsonEncode(currentStats));
    } catch (e) {
      // 統計更新エラーは致命的ではないのでログのみ
      print('統計更新エラー: $e');
    }
  }

  /// ゲームタイプ別統計を計算
  Map<String, dynamic> _calculateGameTypeStats(List<ScoreRecordModel> scores) {
    final stats = <String, dynamic>{};

    for (final gameType in GameType.values) {
      final gameScores = scores.where((s) => s.gameType == gameType).toList();
      if (gameScores.isNotEmpty) {
        stats[gameType.value] = {
          'count': gameScores.length,
          'averageScore':
              gameScores.map((s) => s.score).fold(0, (a, b) => a + b) /
                  gameScores.length,
          'bestScore':
              gameScores.map((s) => s.score).fold(0, (a, b) => a > b ? a : b),
          'averageAccuracy':
              gameScores.map((s) => s.accuracy).fold(0.0, (a, b) => a + b) /
                  gameScores.length,
        };
      }
    }

    return stats;
  }

  /// 操作タイプ別統計を計算
  Map<String, dynamic> _calculateOperationStats(List<ScoreRecordModel> scores) {
    final stats = <String, dynamic>{};

    for (final operation in MathOperationType.values) {
      final operationScores =
          scores.where((s) => s.operation == operation).toList();
      if (operationScores.isNotEmpty) {
        stats[operation.value] = {
          'count': operationScores.length,
          'averageScore':
              operationScores.map((s) => s.score).fold(0, (a, b) => a + b) /
                  operationScores.length,
          'bestScore': operationScores
              .map((s) => s.score)
              .fold(0, (a, b) => a > b ? a : b),
          'averageAccuracy': operationScores
                  .map((s) => s.accuracy)
                  .fold(0.0, (a, b) => a + b) /
              operationScores.length,
        };
      }
    }

    return stats;
  }
}
