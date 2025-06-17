/// アプリケーション全体で使用する定数
class AppConstants {
  // アプリケーション情報
  static const String appName = '算数れんしゅう';
  static const String appVersion = '1.0.0';

  // 数学問題の設定
  static const int defaultProblemCount = 10;
  static const int maxProblemCount = 50;
  static const int minNumber = 1;
  static const int maxNumber = 99;

  // 九九の範囲
  static const int multiplicationMin = 1;
  static const int multiplicationMax = 9;

  // 難易度レベル
  static const int minDifficultyLevel = 1;
  static const int maxDifficultyLevel = 5;
  static const int expertModeLevel = 5;

  // ポイントシステム
  static const int pointsPerCorrectAnswer = 10;
  static const int bonusPointsPerStreak = 5;
  static const int maxStreakBonus = 50;

  // ミニゲームポイントコスト
  static const int numberMemoryGameCost = 10;
  static const int speedMathGameCost = 15;
  static const int slidingPuzzleGameCost = 8;
  static const int rhythmTapGameCost = 12;
  static const int dodgeGameCost = 10;

  // タイミング設定
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration feedbackDuration = Duration(seconds: 2);
  static const Duration gameTimerDuration = Duration(seconds: 60);

  // UI設定
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;

  // ローカルストレージキー
  static const String scoresKey = 'math_practice_scores';
  static const String pointsKey = 'user_points';
  static const String miniGameScoresKey = 'mini_game_scores';
  static const String achievementsKey = 'user_achievements';

  // エラーメッセージ
  static const String genericErrorMessage = 'エラーが発生しました';
  static const String networkErrorMessage = 'ネットワークエラーが発生しました';
  static const String storageErrorMessage = 'データの保存に失敗しました';
}
