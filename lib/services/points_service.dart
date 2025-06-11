import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';
import '../models/score_record.dart';

/// ポイントシステム管理サービス
/// 学習ポイントの獲得、使用、実績の解除を管理する
class PointsService extends ChangeNotifier {
  static const String _pointsKey = 'learning_points';
  static const String _userAchievementsKey = 'user_achievements';

  int _totalPoints = 0;
  List<UserAchievement> _userAchievements = [];
  bool _isLoading = false;

  int get totalPoints => _totalPoints;
  List<UserAchievement> get userAchievements =>
      List.unmodifiable(_userAchievements);
  bool get isLoading => _isLoading;

  /// サービス初期化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadPoints();
      await _loadUserAchievements();
    } catch (e) {
      debugPrint('ポイントサービスの初期化に失敗しました: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// スコア記録からポイントを計算して追加
  Future<int> addPointsFromScore(ScoreRecord score) async {
    final points = _calculatePointsFromScore(score);
    await addPoints(points);
    return points;
  }

  /// ポイントを追加
  Future<void> addPoints(int points) async {
    _totalPoints += points;
    await _savePoints();
    notifyListeners();
  }

  /// ポイントを消費（実績解除時）
  Future<bool> spendPoints(int points) async {
    if (_totalPoints < points) {
      return false; // ポイント不足
    }

    _totalPoints -= points;
    await _savePoints();
    notifyListeners();
    return true;
  }

  /// 実績を解除
  Future<bool> unlockAchievement(String achievementId) async {
    // 既に解除済みかチェック
    if (hasAchievement(achievementId)) {
      return false;
    }

    final achievement = AvailableAchievements.findById(achievementId);
    if (achievement == null) {
      return false;
    }

    // ポイントを消費
    final success = await spendPoints(achievement.pointsCost);
    if (!success) {
      return false;
    }

    // 実績を追加
    final userAchievement = UserAchievement(
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
    );

    _userAchievements.add(userAchievement);
    await _saveUserAchievements();
    notifyListeners();

    return true;
  }

  /// ユーザーが特定の実績を持っているかチェック
  bool hasAchievement(String achievementId) {
    return _userAchievements.any(
      (userAchievement) => userAchievement.achievementId == achievementId,
    );
  }

  /// ユーザーの実績をAchievementオブジェクトのリストで取得
  List<Achievement> getUserAchievementDetails() {
    return _userAchievements
        .map((userAchievement) =>
            AvailableAchievements.findById(userAchievement.achievementId))
        .where((achievement) => achievement != null)
        .cast<Achievement>()
        .toList();
  }

  /// 購入可能な実績を取得（まだ持っていない実績）
  List<Achievement> getAvailableAchievements() {
    return AvailableAchievements.all
        .where((achievement) => !hasAchievement(achievement.id))
        .toList();
  }

  /// 特定のカテゴリーの購入可能な実績を取得
  List<Achievement> getAvailableAchievementsByCategory(
      AchievementCategory category) {
    return getAvailableAchievements()
        .where((achievement) => achievement.category == category)
        .toList();
  }

  /// スコア記録からポイントを計算
  int _calculatePointsFromScore(ScoreRecord score) {
    int basePoints = 10; // 基本ポイント

    // 正答率に基づくボーナス
    final accuracyBonus =
        (score.accuracyPercentage / 10).floor(); // 10%ごとに1ポイント

    // レベルに基づくボーナス
    int levelBonus = 0;
    switch (score.level) {
      case ScoreLevel.excellent:
        levelBonus = 15;
        break;
      case ScoreLevel.good:
        levelBonus = 10;
        break;
      case ScoreLevel.fair:
        levelBonus = 5;
        break;
      case ScoreLevel.needsPractice:
        levelBonus = 0;
        break;
    }

    // パーフェクトスコアボーナス
    int perfectBonus = 0;
    if (score.accuracyPercentage == 100) {
      perfectBonus = 20;
    }

    return basePoints + accuracyBonus + levelBonus + perfectBonus;
  }

  /// ポイントをローカルストレージから読み込み
  Future<void> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _totalPoints = prefs.getInt(_pointsKey) ?? 0;
  }

  /// ポイントをローカルストレージに保存
  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalPoints);
  }

  /// ユーザー実績をローカルストレージから読み込み
  Future<void> _loadUserAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_userAchievementsKey);

    if (achievementsJson != null) {
      final achievementsList = jsonDecode(achievementsJson) as List;
      _userAchievements = achievementsList
          .map(
            (json) => UserAchievement.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }
  }

  /// ユーザー実績をローカルストレージに保存
  Future<void> _saveUserAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = jsonEncode(
      _userAchievements.map((achievement) => achievement.toJson()).toList(),
    );
    await prefs.setString(_userAchievementsKey, achievementsJson);
  }

  /// 全てのデータをクリア（デバッグ用）
  Future<void> clearAllData() async {
    _totalPoints = 0;
    _userAchievements.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pointsKey);
    await prefs.remove(_userAchievementsKey);

    notifyListeners();
  }
}
