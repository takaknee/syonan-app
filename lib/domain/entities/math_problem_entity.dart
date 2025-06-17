/// 算数の操作タイプを表すenum
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

/// 算数問題のエンティティ
class MathProblemEntity {
  final int firstNumber;
  final int secondNumber;
  final MathOperationType operation;
  final int correctAnswer;
  final int? difficultyLevel;
  final DateTime createdAt;

  MathProblemEntity({
    required this.firstNumber,
    required this.secondNumber,
    required this.operation,
    required this.correctAnswer,
    this.difficultyLevel,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 問題を文字列として表現
  String get problemText => '$firstNumber ${operation.symbol} $secondNumber';

  /// 答えが正しいかどうかを確認
  bool isCorrectAnswer(int userAnswer) => userAnswer == correctAnswer;

  /// 難易度レベルの説明を取得
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

  /// エキスパートモードかどうか
  bool get isExpertMode => difficultyLevel == 5;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MathProblemEntity &&
          runtimeType == other.runtimeType &&
          firstNumber == other.firstNumber &&
          secondNumber == other.secondNumber &&
          operation == other.operation &&
          correctAnswer == other.correctAnswer;

  @override
  int get hashCode => firstNumber.hashCode ^ secondNumber.hashCode ^ operation.hashCode ^ correctAnswer.hashCode;

  @override
  String toString() => 'MathProblemEntity(${problemText} = $correctAnswer, difficulty: $difficultyLevel)';

  /// エンティティをコピーして新しいインスタンスを作成
  MathProblemEntity copyWith({
    int? firstNumber,
    int? secondNumber,
    MathOperationType? operation,
    int? correctAnswer,
    int? difficultyLevel,
    DateTime? createdAt,
  }) {
    return MathProblemEntity(
      firstNumber: firstNumber ?? this.firstNumber,
      secondNumber: secondNumber ?? this.secondNumber,
      operation: operation ?? this.operation,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
