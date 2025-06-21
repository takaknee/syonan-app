/// ゲームタイプを表すenum
enum GameType {
  mathPractice('mathPractice', '算数練習'),
  speedMath('speedMath', 'スピード算数'),
  dodgeGame('dodgeGame', '回避ゲーム'),
  numberMemory('numberMemory', '数字記憶'),
  rhythmTap('rhythmTap', 'リズムタップ'),
  slidingPuzzle('slidingPuzzle', 'スライドパズル');

  const GameType(this.value, this.displayName);

  final String value;
  final String displayName;

  @override
  String toString() => value;
}

/// スコア改善状況を表すenum
enum ScoreImprovement {
  improved('improved', '向上'),
  same('same', '同じ'),
  declined('declined', '低下'),
  noData('noData', 'データなし');

  const ScoreImprovement(this.value, this.displayName);

  final String value;
  final String displayName;

  @override
  String toString() => value;
}

/// スコア記録のエンティティ
class ScoreRecordEntity {
  const ScoreRecordEntity({
    required this.id,
    required this.userId,
    required this.gameType,
    required this.operation,
    required this.score,
    required this.correctCount,
    required this.wrongAnswers,
    required this.totalCount,
    required this.accuracy,
    required this.duration,
    this.difficultyLevel,
    required this.timestamp,
    required this.answerResults,
    required this.pointsEarned,
    this.metadata,
  });
  final String id;
  final String userId;
  final GameType gameType;
  final MathOperationType operation;
  final int score;
  final int correctCount;
  final int wrongAnswers;
  final int totalCount;
  final double accuracy;
  final Duration duration;
  final int? difficultyLevel;
  final DateTime timestamp;
  final List<bool> answerResults;
  final int pointsEarned;
  final Map<String, dynamic>? metadata;

  // Getterを追加してbackward compatibility維持
  int get correctAnswers => correctCount;
  int get totalQuestions => totalCount;
  Duration get timeSpent => duration;
  DateTime get createdAt => timestamp;

  /// 合格ライン（80%以上）をクリアしているかどうか
  bool get isPassing => accuracy >= 0.8;

  /// 満点かどうか
  bool get isPerfect => correctCount == totalCount;

  /// エキスパートモードかどうか
  bool get isExpertMode => difficultyLevel == 5;

  /// 難易度の説明を取得
  String get difficultyDescription {
    switch (difficultyLevel) {
      case 1:
        return '初級';
      case 2:
        return '中級';
      case 3:
        return '上級';
      case 4:
        return '挑戦';
      case 5:
        return 'エキスパート';
      default:
        return '標準';
    }
  }

  /// スコアの改善状況を計算
  ScoreImprovement calculateImprovement(ScoreRecordEntity? previousRecord) {
    if (previousRecord == null) return ScoreImprovement.noData;

    if (accuracy > previousRecord.accuracy) {
      return ScoreImprovement.improved;
    } else if (accuracy == previousRecord.accuracy) {
      return ScoreImprovement.same;
    } else {
      return ScoreImprovement.declined;
    }
  }

  /// パーセンテージ表示用の正答率
  int get accuracyPercentage => (accuracy * 100).round();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ScoreRecordEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ScoreRecordEntity(id: $id, operation: $operation, accuracy: $accuracyPercentage%, difficulty: $difficultyLevel)';

  /// エンティティをコピーして新しいインスタンスを作成
  ScoreRecordEntity copyWith({
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
    return ScoreRecordEntity(
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
}

/// 算数操作タイプを表すenum（ScoreRecordEntityで使用）
enum MathOperationType {
  multiplication('multiplication', '掛け算', '×'),
  division('division', '割り算', '÷'),
  addition('addition', '足し算', '+'),
  subtraction('subtraction', '引き算', '-');

  const MathOperationType(this.value, this.displayName, this.symbol);

  final String value;
  final String displayName;
  final String symbol;

  @override
  String toString() => value;
}
