import '../../domain/entities/score_record_entity.dart';

/// スコア記録のデータモデル
class ScoreRecordModel extends ScoreRecordEntity {
  /// EntityからModelに変換
  factory ScoreRecordModel.fromEntity(ScoreRecordEntity entity) {
    return ScoreRecordModel(
      id: entity.id,
      userId: entity.userId,
      gameType: entity.gameType,
      operation: entity.operation,
      score: entity.score,
      correctCount: entity.correctCount,
      wrongAnswers: entity.wrongAnswers,
      totalCount: entity.totalCount,
      accuracy: entity.accuracy,
      duration: entity.duration,
      difficultyLevel: entity.difficultyLevel,
      timestamp: entity.timestamp,
      answerResults: entity.answerResults,
      pointsEarned: entity.pointsEarned,
      metadata: entity.metadata,
    );
  }
  const ScoreRecordModel({
    required super.id,
    required super.userId,
    required super.gameType,
    required super.operation,
    required super.score,
    required super.correctCount,
    required super.wrongAnswers,
    required super.totalCount,
    required super.accuracy,
    required super.duration,
    required super.difficultyLevel,
    required super.timestamp,
    required super.answerResults,
    required super.pointsEarned,
    super.metadata,
  });

  /// JSONからScoreRecordModelを作成
  factory ScoreRecordModel.fromJson(Map<String, dynamic> json) {
    return ScoreRecordModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      gameType: GameType.values.firstWhere(
        (e) => e.value == json['gameType'],
        orElse: () => GameType.mathPractice,
      ),
      operation: MathOperationType.values.firstWhere(
        (e) => e.value == json['operation'],
        orElse: () => MathOperationType.multiplication,
      ),
      score: json['score'] as int,
      correctCount: json['correctCount'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      totalCount: json['totalCount'] as int,
      accuracy: json['accuracy'] as double,
      duration: Duration(milliseconds: json['duration'] as int),
      difficultyLevel: json['difficultyLevel'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      answerResults: (json['answerResults'] as List).cast<bool>(),
      pointsEarned: json['pointsEarned'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// ScoreRecordModelをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'gameType': gameType.value,
      'operation': operation.value,
      'score': score,
      'correctCount': correctCount,
      'wrongAnswers': wrongAnswers,
      'totalCount': totalCount,
      'accuracy': accuracy,
      'duration': duration.inMilliseconds,
      'difficultyLevel': difficultyLevel,
      'timestamp': timestamp.toIso8601String(),
      'answerResults': answerResults,
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }

  /// ScoreRecordModelをコピーして部分的に変更
  @override
  ScoreRecordModel copyWith({
    String? id,
    String? userId,
    GameType? gameType,
    MathOperationType? operation,
    int? score,
    int? correctCount,
    int? wrongAnswers,
    int? totalCount,
    double? accuracy,
    Duration? duration,
    int? difficultyLevel,
    DateTime? timestamp,
    List<bool>? answerResults,
    int? pointsEarned,
    Map<String, dynamic>? metadata,
  }) {
    return ScoreRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameType: gameType ?? this.gameType,
      operation: operation ?? this.operation,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      totalCount: totalCount ?? this.totalCount,
      accuracy: accuracy ?? this.accuracy,
      duration: duration ?? this.duration,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      timestamp: timestamp ?? this.timestamp,
      answerResults: answerResults ?? this.answerResults,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      metadata: metadata ?? this.metadata,
    );
  }

  /// パフォーマンススコアを計算（時間も考慮）
  double get performanceScore {
    if (totalCount == 0 || duration.inSeconds == 0) return 0.0;
    final speed = totalCount / (duration.inSeconds / 60); // 問題/分
    return (accuracy * 0.7 + (speed / 10) * 0.3) * 100;
  }
}
