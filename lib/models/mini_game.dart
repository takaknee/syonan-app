/// ミニゲームの種類
enum MiniGameType {
  numberMemory,
  speedMath,
  puzzle,
  rhythm,
  action,
  strategy,
  simulation,
}

/// ミニゲームの難易度
enum MiniGameDifficulty {
  easy,
  normal,
  hard,
}

/// ミニゲームの定義
class MiniGame {
  const MiniGame({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.emoji,
    required this.pointsCost,
    required this.difficulty,
    required this.color,
  });

  factory MiniGame.fromJson(Map<String, dynamic> json) {
    return MiniGame(
      id: json['id'] as String,
      type: MiniGameType.values[json['type'] as int],
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      pointsCost: json['pointsCost'] as int,
      difficulty: MiniGameDifficulty.values[json['difficulty'] as int],
      color: json['color'] as int,
    );
  }

  final String id;
  final MiniGameType type;
  final String name;
  final String description;
  final String emoji;
  final int pointsCost;
  final MiniGameDifficulty difficulty;
  final int color; // Color value as int for serialization

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'name': name,
      'description': description,
      'emoji': emoji,
      'pointsCost': pointsCost,
      'difficulty': difficulty.index,
      'color': color,
    };
  }
}

/// ミニゲームのスコア記録
class MiniGameScore {
  const MiniGameScore({
    required this.id,
    required this.gameId,
    required this.score,
    required this.completedAt,
    required this.difficulty,
  });

  factory MiniGameScore.fromJson(Map<String, dynamic> json) {
    return MiniGameScore(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      score: json['score'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      difficulty: MiniGameDifficulty.values[json['difficulty'] as int],
    );
  }

  final String id;
  final String gameId;
  final int score;
  final DateTime completedAt;
  final MiniGameDifficulty difficulty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
      'difficulty': difficulty.index,
    };
  }
}

/// 利用可能なミニゲーム一覧
class AvailableMiniGames {
  static const List<MiniGame> all = [
    MiniGame(
      id: 'number_memory',
      type: MiniGameType.numberMemory,
      name: '数字おぼえゲーム',
      description: '数字を覚えて入力しよう！',
      emoji: '🧠',
      pointsCost: 10,
      difficulty: MiniGameDifficulty.easy,
      color: 0xFF4CAF50, // Green
    ),
    MiniGame(
      id: 'speed_math',
      type: MiniGameType.speedMath,
      name: 'スピード計算',
      description: '時間内に計算問題を解こう！',
      emoji: '⚡',
      pointsCost: 15,
      difficulty: MiniGameDifficulty.normal,
      color: 0xFFFF9800, // Orange
    ),
    MiniGame(
      id: 'sliding_puzzle',
      type: MiniGameType.puzzle,
      name: 'スライドパズル',
      description: '数字を正しい順番に並べよう！',
      emoji: '🧩',
      pointsCost: 8,
      difficulty: MiniGameDifficulty.easy,
      color: 0xFF9C27B0, // Purple
    ),
    MiniGame(
      id: 'rhythm_tap',
      type: MiniGameType.rhythm,
      name: 'リズムタップ',
      description: 'リズムに合わせてタップしよう！',
      emoji: '🎵',
      pointsCost: 12,
      difficulty: MiniGameDifficulty.normal,
      color: 0xFFE91E63, // Pink
    ),
    MiniGame(
      id: 'dodge_game',
      type: MiniGameType.action,
      name: 'ドッジゲーム',
      description: '落ちてくる障害物を避けよう！',
      emoji: '🎯',
      pointsCost: 10,
      difficulty: MiniGameDifficulty.easy,
      color: 0xFF2196F3, // Blue
    ),
    MiniGame(
      id: 'number_puzzle',
      type: MiniGameType.puzzle,
      name: '数字パズル',
      description: '数字を使った論理パズルに挑戦！',
      emoji: '🔢',
      pointsCost: 12,
      difficulty: MiniGameDifficulty.normal,
      color: 0xFF795548, // Brown
    ),
    MiniGame(
      id: 'strategy_battle',
      type: MiniGameType.strategy,
      name: '戦略バトル',
      description: '敵を倒すための戦略を考えよう！',
      emoji: '⚔️',
      pointsCost: 18,
      difficulty: MiniGameDifficulty.hard,
      color: 0xFF8BC34A, // Light Green
    ),
    MiniGame(
      id: 'water_margin',
      type: MiniGameType.strategy,
      name: '水滸伝 天下統一',
      description: '梁山泊を率いて天下統一を目指そう！',
      emoji: '🏔️',
      pointsCost: 25,
      difficulty: MiniGameDifficulty.hard,
      color: 0xFF3F51B5, // Indigo
    ),
    MiniGame(
      id: 'city_builder',
      type: MiniGameType.simulation,
      name: '街づくり',
      description: '理想の街を建設しよう！',
      emoji: '🏙️',
      pointsCost: 20,
      difficulty: MiniGameDifficulty.hard,
      color: 0xFF607D8B, // Blue Grey
    ),
  ];

  static MiniGame? findById(String id) {
    try {
      return all.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }
}
