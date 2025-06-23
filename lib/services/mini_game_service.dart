import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mini_game.dart';

/// ミニゲーム管理サービス
/// ミニゲームのプレイ記録と管理を行う
class MiniGameService extends ChangeNotifier {
  static const String _scoresKey = 'mini_game_scores';
  static const String _playCountKey = 'mini_game_play_count';

  List<MiniGameScore> _scores = [];
  Map<String, int> _playCount = {};
  bool _isLoading = false;

  List<MiniGameScore> get scores => List.unmodifiable(_scores);
  Map<String, int> get playCount => Map.unmodifiable(_playCount);
  bool get isLoading => _isLoading;

  /// サービス初期化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadScores();
      await _loadPlayCount();
    } catch (e) {
      debugPrint('ミニゲームサービスの初期化に失敗しました: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 特定のゲームのプレイ回数を取得
  int getPlayCount(String gameId) {
    return _playCount[gameId] ?? 0;
  }

  /// 特定のゲームの最高スコアを取得
  int getBestScore(String gameId) {
    final gameScores = _scores.where((score) => score.gameId == gameId);
    if (gameScores.isEmpty) return 0;
    return gameScores
        .map((score) => score.score)
        .reduce((a, b) => a > b ? a : b);
  }

  /// 特定のゲームの平均スコアを取得
  double getAverageScore(String gameId) {
    final gameScores = _scores.where((score) => score.gameId == gameId);
    if (gameScores.isEmpty) return 0.0;
    final totalScore =
        gameScores.map((score) => score.score).reduce((a, b) => a + b);
    return totalScore / gameScores.length;
  }

  /// スコアを記録
  Future<void> recordScore(
      String gameId, int score, MiniGameDifficulty difficulty) async {
    final newScore = MiniGameScore(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: gameId,
      score: score,
      completedAt: DateTime.now(),
      difficulty: difficulty,
    );

    _scores.add(newScore);

    // プレイ回数を増加
    _playCount[gameId] = (_playCount[gameId] ?? 0) + 1;

    await _saveScores();
    await _savePlayCount();
    notifyListeners();
  }

  /// 特定のゲームの最新スコア5件を取得
  List<MiniGameScore> getRecentScores(String gameId, {int limit = 5}) {
    final gameScores = _scores.where((score) => score.gameId == gameId).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return gameScores.take(limit).toList();
  }

  /// 全体の統計情報を取得
  Map<String, dynamic> getOverallStats() {
    final totalGamesPlayed =
        _playCount.values.fold(0, (sum, count) => sum + count);
    final totalScore = _scores
        .map((score) => score.score)
        .fold(0, (sum, score) => sum + score);
    final averageScore = _scores.isNotEmpty ? totalScore / _scores.length : 0.0;

    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'averageScore': averageScore,
      'gamesUnlocked': AvailableMiniGames.all.length,
    };
  }

  /// スコアをローカルストレージから読み込み
  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = prefs.getString(_scoresKey);

    if (scoresJson != null) {
      final scoresList = jsonDecode(scoresJson) as List;
      _scores = scoresList
          .map((json) => MiniGameScore.fromJson(json as Map<String, dynamic>))
          .toList();
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

  /// プレイ回数をローカルストレージから読み込み
  Future<void> _loadPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final playCountJson = prefs.getString(_playCountKey);

    if (playCountJson != null) {
      final playCountMap = jsonDecode(playCountJson) as Map<String, dynamic>;
      _playCount =
          playCountMap.map((key, value) => MapEntry(key, value as int));
    }
  }

  /// プレイ回数をローカルストレージに保存
  Future<void> _savePlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final playCountJson = jsonEncode(_playCount);
    await prefs.setString(_playCountKey, playCountJson);
  }

  /// 全てのデータをクリア（デバッグ用）
  Future<void> clearAllData() async {
    _scores.clear();
    _playCount.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoresKey);
    await prefs.remove(_playCountKey);

    notifyListeners();
  }
}
