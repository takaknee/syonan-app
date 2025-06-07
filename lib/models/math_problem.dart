/// 算数問題の種類を表す列挙型
enum MathOperationType {
  multiplication('×', '掛け算'),
  division('÷', '割り算');

  const MathOperationType(this.symbol, this.displayName);

  final String symbol;
  final String displayName;
}

/// 算数問題を表すモデルクラス
class MathProblem {
  /// JSONからMathProblemを作成
  factory MathProblem.fromJson(Map<String, dynamic> json) {
    return MathProblem(
      firstNumber: json['firstNumber'] as int,
      secondNumber: json['secondNumber'] as int,
      operation: MathOperationType.values.firstWhere(
        (op) => op.name == json['operation'],
      ),
      correctAnswer: json['correctAnswer'] as int,
    );
  }
  const MathProblem({
    required this.firstNumber,
    required this.secondNumber,
    required this.operation,
    required this.correctAnswer,
  });

  final int firstNumber;
  final int secondNumber;
  final MathOperationType operation;
  final int correctAnswer;

  /// 問題文を文字列として取得
  String get questionText {
    return '$firstNumber ${operation.symbol} $secondNumber = ? ';
  }

  /// 答えが正しいかチェック
  bool isCorrectAnswer(int userAnswer) {
    return userAnswer == correctAnswer;
  }

  /// MathProblemをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'firstNumber': firstNumber,
      'secondNumber': secondNumber,
      'operation': operation.name,
      'correctAnswer': correctAnswer,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MathProblem &&
        other.firstNumber == firstNumber &&
        other.secondNumber == secondNumber &&
        other.operation == operation &&
        other.correctAnswer == correctAnswer;
  }

  @override
  int get hashCode {
    return Object.hash(firstNumber, secondNumber, operation, correctAnswer);
  }

  @override
  String toString() {
    return 'MathProblem($questionText = $correctAnswer)';
  }
}
