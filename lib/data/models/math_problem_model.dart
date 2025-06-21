import '../../domain/entities/math_problem_entity.dart';

/// 算数問題のデータモデル（JSON変換用）
class MathProblemModel extends MathProblemEntity {
  /// EntityからModelを作成
  factory MathProblemModel.fromEntity(MathProblemEntity entity) {
    return MathProblemModel(
      firstNumber: entity.firstNumber,
      secondNumber: entity.secondNumber,
      operation: entity.operation,
      correctAnswer: entity.correctAnswer,
      difficultyLevel: entity.difficultyLevel,
      createdAt: entity.createdAt,
    );
  }
  MathProblemModel({
    required super.firstNumber,
    required super.secondNumber,
    required super.operation,
    required super.correctAnswer,
    super.difficultyLevel,
    required super.createdAt,
  });

  /// JSONからMathProblemModelを作成
  factory MathProblemModel.fromJson(Map<String, dynamic> json) {
    return MathProblemModel(
      firstNumber: json['firstNumber'] as int,
      secondNumber: json['secondNumber'] as int,
      operation: MathOperationType.values.firstWhere(
        (e) => e.value == json['operation'],
      ),
      correctAnswer: json['correctAnswer'] as int,
      difficultyLevel: json['difficultyLevel'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// MathProblemModelをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'firstNumber': firstNumber,
      'secondNumber': secondNumber,
      'operation': operation.value,
      'correctAnswer': correctAnswer,
      'difficultyLevel': difficultyLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// ModelからEntityに変換
  MathProblemEntity toEntity() {
    return MathProblemEntity(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: operation,
      correctAnswer: correctAnswer,
      difficultyLevel: difficultyLevel,
      createdAt: createdAt,
    );
  }

  /// コピーして新しいインスタンスを作成
  @override
  MathProblemModel copyWith({
    int? firstNumber,
    int? secondNumber,
    MathOperationType? operation,
    int? correctAnswer,
    int? difficultyLevel,
    DateTime? createdAt,
  }) {
    return MathProblemModel(
      firstNumber: firstNumber ?? this.firstNumber,
      secondNumber: secondNumber ?? this.secondNumber,
      operation: operation ?? this.operation,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
