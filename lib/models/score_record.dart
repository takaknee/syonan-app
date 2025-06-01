import 'math_problem.dart';

/// スコア記録を表すモデルクラス
class ScoreRecord {

  /// JSONからScoreRecordを作成
  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    return ScoreRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      operation: MathOperationType.values.firstWhere(
        (op) => op.name == json['operation'],
      ),
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      timeSpent: Duration(seconds: json['timeSpentSeconds'] as int),
    );
  }
  const ScoreRecord({
    required this.id,
    required this.date,
    required this.operation,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
  });

  final String id;
  final DateTime date;
  final MathOperationType operation;
  final int correctAnswers;
  final int totalQuestions;
  final Duration timeSpent; // 練習にかかった時間

  /// 正答率を計算（0.0 〜 1.0）
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  /// 正答率をパーセンテージで取得（0 〜 100）
  int get accuracyPercentage {
    return (accuracy * 100).round();
  }

  /// 評価レベルを取得
  ScoreLevel get level {
    final percentage = accuracyPercentage;
    if (percentage >= 90) return ScoreLevel.excellent;
    if (percentage >= 80) return ScoreLevel.good;
    if (percentage >= 70) return ScoreLevel.fair;
    return ScoreLevel.needsPractice;
  }

  /// ScoreRecordをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'operation': operation.name,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSpentSeconds': timeSpent.inSeconds,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoreRecord &&
        other.id == id &&
        other.date == date &&
        other.operation == operation &&
        other.correctAnswers == correctAnswers &&
        other.totalQuestions == totalQuestions &&
        other.timeSpent == timeSpent;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      date,
      operation,
      correctAnswers,
      totalQuestions,
      timeSpent,
    );
  }

  @override
  String toString() {
    return 'ScoreRecord(${operation.displayName}: $correctAnswers/$totalQuestions, $accuracyPercentage%)';
  }
}

/// スコアのレベルを表す列挙型
enum ScoreLevel {
  excellent('すばらしい！', '🌟'),
  good('よくできました！', '⭐'),
  fair('がんばりました！', '👏'),
  needsPractice('もう少しれんしゅうしよう！', '💪');

  const ScoreLevel(this.message, this.emoji);

  final String message;
  final String emoji;
}
