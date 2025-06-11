/// 達成可能なバッジ/実績を表すモデルクラス
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.pointsCost,
    required this.category,
  });

  /// JSONからAchievementを作成
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      pointsCost: json['pointsCost'] as int,
      category: AchievementCategory.values.firstWhere(
        (category) => category.name == json['category'],
      ),
    );
  }

  final String id;
  final String title;
  final String description;
  final String emoji;
  final int pointsCost;
  final AchievementCategory category;

  /// AchievementをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'pointsCost': pointsCost,
      'category': category.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.emoji == emoji &&
        other.pointsCost == pointsCost &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      emoji,
      pointsCost,
      category,
    );
  }

  @override
  String toString() {
    return 'Achievement($title: $pointsCost points)';
  }
}

/// ユーザーが獲得した実績を表すクラス
class UserAchievement {
  const UserAchievement({
    required this.achievementId,
    required this.unlockedAt,
  });

  /// JSONからUserAchievementを作成
  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      achievementId: json['achievementId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }

  final String achievementId;
  final DateTime unlockedAt;

  /// UserAchievementをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAchievement &&
        other.achievementId == achievementId &&
        other.unlockedAt == unlockedAt;
  }

  @override
  int get hashCode {
    return Object.hash(achievementId, unlockedAt);
  }
}

/// 実績のカテゴリーを表す列挙型
enum AchievementCategory {
  practice('練習'),
  streak('連続'),
  accuracy('正確性'),
  fun('楽しさ');

  const AchievementCategory(this.displayName);

  final String displayName;
}

/// 利用可能な実績のリスト
class AvailableAchievements {
  static const List<Achievement> all = [
    // 練習関連の実績
    Achievement(
      id: 'practice_badge_bronze',
      title: 'れんしゅうビギナー',
      description: '5回練習しました！',
      emoji: '🥉',
      pointsCost: 50,
      category: AchievementCategory.practice,
    ),
    Achievement(
      id: 'practice_badge_silver',
      title: 'れんしゅうエキスパート',
      description: '20回練習しました！',
      emoji: '🥈',
      pointsCost: 100,
      category: AchievementCategory.practice,
    ),
    Achievement(
      id: 'practice_badge_gold',
      title: 'れんしゅうマスター',
      description: '50回練習しました！',
      emoji: '🥇',
      pointsCost: 200,
      category: AchievementCategory.practice,
    ),

    // 連続練習関連の実績
    Achievement(
      id: 'streak_badge_3',
      title: '3日連続',
      description: '3日連続で練習しました！',
      emoji: '🔥',
      pointsCost: 30,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_badge_7',
      title: '1週間連続',
      description: '7日連続で練習しました！',
      emoji: '⚡',
      pointsCost: 70,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_badge_30',
      title: '1ヶ月連続',
      description: '30日連続で練習しました！',
      emoji: '💫',
      pointsCost: 300,
      category: AchievementCategory.streak,
    ),

    // 正確性関連の実績
    Achievement(
      id: 'accuracy_badge_90',
      title: 'パーフェクト90',
      description: '90%以上の正答率を達成！',
      emoji: '🎯',
      pointsCost: 80,
      category: AchievementCategory.accuracy,
    ),
    Achievement(
      id: 'accuracy_badge_100',
      title: 'パーフェクト100',
      description: '100%の正答率を達成！',
      emoji: '🌟',
      pointsCost: 150,
      category: AchievementCategory.accuracy,
    ),

    // 楽しさ関連の実績
    Achievement(
      id: 'fun_badge_rainbow',
      title: 'にじいろバッジ',
      description: 'とてもきれいなバッジです！',
      emoji: '🌈',
      pointsCost: 25,
      category: AchievementCategory.fun,
    ),
    Achievement(
      id: 'fun_badge_star',
      title: 'きらきらバッジ',
      description: 'きらきら光るバッジです！',
      emoji: '✨',
      pointsCost: 40,
      category: AchievementCategory.fun,
    ),
    Achievement(
      id: 'fun_badge_crown',
      title: 'おうかんバッジ',
      description: 'おうさまのおうかんです！',
      emoji: '👑',
      pointsCost: 120,
      category: AchievementCategory.fun,
    ),
  ];

  /// IDで実績を検索
  static Achievement? findById(String id) {
    try {
      return all.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  /// カテゴリー別に実績を取得
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all
        .where((achievement) => achievement.category == category)
        .toList();
  }
}
