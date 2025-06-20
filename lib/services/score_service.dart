import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/math_problem.dart';
import '../models/score_record.dart';

/// スコア管理サービス
/// スコアの保存、読み込み、統計情報の提供を行う
class ScoreService extends ChangeNotifier {
  static const String _scoresKey = 'score_records';
  static const String _lastScoreKey = 'last_score';

  List<ScoreRecord> _scores = [];
  ScoreRecord? _lastScore;
  bool _isLoading = false;

  List<ScoreRecord> get scores => List.unmodifiable(_scores);
  ScoreRecord? get lastScore => _lastScore;
  bool get isLoading => _isLoading;

  /// サービス初期化（アプリ起動時に呼び出す）
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadScores();
      await _loadLastScore();
    } catch (e) {
      debugPrint('スコアの初期化に失敗しました : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 新しいスコアを保存
  Future<void> saveScore(ScoreRecord score) async {
    try {
      _scores.add(score);
      _scores.sort((a, b) => b.date.compareTo(a.date)); // 新しい順にソート

      await _saveScores();
      await _saveLastScore(score);

      _lastScore = score;
      notifyListeners();
    } catch (e) {
      debugPrint('スコアの保存に失敗しました: $e');
      rethrow;
    }
  }

  /// スコアを追加（saveScoreのエイリアス）
  Future<void> addScore(
    MathOperationType operation,
    int correctAnswers,
    int totalQuestions,
    Duration timeSpent,
  ) async {
    final score = ScoreRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      operation: operation,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      timeSpent: timeSpent,
    );
    await saveScore(score);
  }

  /// 特定の操作タイプのスコア履歴を取得
  List<ScoreRecord> getScoresByOperation(MathOperationType operation) {
    return _scores.where((score) => score.operation == operation).toList();
  }

  /// 全スコアを取得（scoresのエイリアス）
  List<ScoreRecord> getAllScores() => scores;

  /// 最新のスコアと前回のスコアを比較して改善度を取得
  ScoreImprovement getImprovement(MathOperationType operation) {
    final operationScores = getScoresByOperation(operation);

    if (operationScores.length < 2) {
      return ScoreImprovement.noData;
    }

    final latest = operationScores.first;
    final previous = operationScores[1];

    final latestPercentage = latest.accuracyPercentage;
    final previousPercentage = previous.accuracyPercentage;

    if (latestPercentage > previousPercentage) {
      return ScoreImprovement.improved;
    } else if (latestPercentage == previousPercentage) {
      return ScoreImprovement.same;
    } else {
      return ScoreImprovement.declined;
    }
  }

  /// 操作タイプ別の平均スコアを取得
  double getAverageScore(MathOperationType operation) {
    final operationScores = getScoresByOperation(operation);

    if (operationScores.isEmpty) return 0.0;

    final totalAccuracy = operationScores.map((score) => score.accuracy).reduce((a, b) => a + b);

    return totalAccuracy / operationScores.length;
  }

  /// 最高スコアを取得
  ScoreRecord? getBestScore(MathOperationType operation) {
    final operationScores = getScoresByOperation(operation);

    if (operationScores.isEmpty) return null;

    return operationScores.reduce(
      (a, b) => a.accuracyPercentage > b.accuracyPercentage ? a : b,
    );
  }

  /// 今週の練習回数を取得
  int getWeeklyPracticeCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    return _scores.where((score) => score.date.isAfter(weekStartDate)).length;
  }

  /// 連続練習日数を取得
  int getStreakDays() {
    if (_scores.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var streakDays = 0;
    var checkDate = today;

    final uniqueDates = _scores
        .map(
          (score) => DateTime(
            score.date.year,
            score.date.month,
            score.date.day,
          ),
        )
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // 新しい順

    for (final scoreDate in uniqueDates) {
      if (scoreDate.isAtSameMomentAs(checkDate)) {
        streakDays++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streakDays;
  }

  /// スコアをローカルストレージから読み込み
  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = prefs.getString(_scoresKey);

    if (scoresJson != null) {
      final scoresList = jsonDecode(scoresJson) as List;
      _scores = scoresList
          .map(
            (json) => ScoreRecord.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      _scores.sort((a, b) => b.date.compareTo(a.date)); // 新しい順にソート
    }
  }

  /// スコアをローカルストレージに保存
  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = jsonEncode(
      _scores.map((score) => score.toJson()).toList(),
    );
    await prefs.setString(_scoresKey, scoresJson);
  }

  /// 最後のスコアを読み込み
  Future<void> _loadLastScore() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScoreJson = prefs.getString(_lastScoreKey);

    if (lastScoreJson != null) {
      final json = jsonDecode(lastScoreJson) as Map<String, dynamic>;
      _lastScore = ScoreRecord.fromJson(json);
    }
  }

  /// 最後のスコアを保存
  Future<void> _saveLastScore(ScoreRecord score) async {
    final prefs = await SharedPreferences.getInstance();
    final scoreJson = jsonEncode(score.toJson());
    await prefs.setString(_lastScoreKey, scoreJson);
  }

  /// 全てのスコアをクリア（デバッグ用）
  Future<void> clearAllScores() async {
    _scores.clear();
    _lastScore = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoresKey);
    await prefs.remove(_lastScoreKey);

    notifyListeners();
  }
}

/// スコア改善度を表す列挙型
enum ScoreImprovement {
  improved('よくなりました！', '📈', '前回より良くなりました！頑張っていますね！'),
  same('前回と同じです', '➡️', '安定した成績です。この調子で続けましょう！'),
  declined('もう少し頑張りましょう', '📉', '大丈夫です！練習すれば必ず上達します！'),
  noData('データがありません', '❓', '最初の記録です。頑張りましょう！');

  const ScoreImprovement(this.title, this.emoji, this.message);

  final String title;
  final String emoji;
  final String message;
}
