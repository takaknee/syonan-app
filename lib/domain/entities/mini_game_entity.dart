/// ミニゲームのタイプを表すenum
enum MiniGameType {
  memory('memory', 'メモリー'),
  speedMath('speed_math', 'スピード計算'),
  puzzle('puzzle', 'パズル'),
  rhythm('rhythm', 'リズム'),
  action('action', 'アクション');

  const MiniGameType(this.value, this.displayName);

  final String value;
  final String displayName;

  @override
  String toString() => value;
}

/// ミニゲームの難易度を表すenum
enum MiniGameDifficulty {
  easy('easy', '簡単'),
  normal('normal', '普通'),
  hard('hard', '難しい'),
  expert('expert', 'エキスパート');

  const MiniGameDifficulty(this.value, this.displayName);

  final String value;
  final String displayName;

  @override
  String toString() => value;
}

/// ミニゲームのエンティティ
class MiniGameEntity {
  const MiniGameEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.emoji,
    required this.pointsCost,
    required this.difficulty,
    required this.color,
  });
  final String id;
  final MiniGameType type;
  final String name;
  final String description;
  final String emoji;
  final int pointsCost;
  final MiniGameDifficulty difficulty;
  final int color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MiniGameEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MiniGameEntity(id: $id, name: $name)';

  /// エンティティをコピーして新しいインスタンスを作成
  MiniGameEntity copyWith({
    String? id,
    MiniGameType? type,
    String? name,
    String? description,
    String? emoji,
    int? pointsCost,
    MiniGameDifficulty? difficulty,
    int? color,
  }) {
    return MiniGameEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      pointsCost: pointsCost ?? this.pointsCost,
      difficulty: difficulty ?? this.difficulty,
      color: color ?? this.color,
    );
  }
}

/// ミニゲームスコアのエンティティ
class MiniGameScoreEntity {
  const MiniGameScoreEntity({
    required this.id,
    required this.gameId,
    required this.score,
    required this.difficulty,
    required this.duration,
    required this.timestamp,
  });
  final String id;
  final String gameId;
  final int score;
  final MiniGameDifficulty difficulty;
  final Duration duration;
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MiniGameScoreEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MiniGameScoreEntity(id: $id, gameId: $gameId, score: $score)';

  /// エンティティをコピーして新しいインスタンスを作成
  MiniGameScoreEntity copyWith({
    String? id,
    String? gameId,
    int? score,
    MiniGameDifficulty? difficulty,
    Duration? duration,
    DateTime? timestamp,
  }) {
    return MiniGameScoreEntity(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      score: score ?? this.score,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
