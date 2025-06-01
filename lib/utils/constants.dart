import 'package:flutter/material.dart';

/// アプリ全体で使用する定数を定義
class AppConstants {
  // アプリ情報
  static const String appName = '算数れんしゅう';
  static const String appVersion = '1.0.0';

  // 問題設定
  static const int defaultProblemCount = 10;
  static const int maxProblemCount = 20;
  static const int minProblemCount = 5;

  // 小学三年生向けの数値範囲
  static const int minNumber = 1;
  static const int maxNumber = 9;
  static const int easyMaxNumber = 5;
  static const int hardMaxNumber = 12;

  // タイムアウト設定
  static const Duration maxPracticeTime = Duration(minutes: 30);
  static const Duration encouragementDelay = Duration(milliseconds: 1500);

  // アニメーション設定
  static const Duration fastAnimation = Duration(milliseconds: 300);
  static const Duration normalAnimation = Duration(milliseconds: 500);
  static const Duration slowAnimation = Duration(milliseconds: 1000);

  // UI設定
  static const double minTouchTarget = 44.0; // アクセシビリティのための最小タッチターゲット
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // カラーパレット（子供向け）
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  // ローカルストレージキー
  static const String scoresKey = 'score_records';
  static const String lastScoreKey = 'last_score';
  static const String settingsKey = 'app_settings';

  // Private constructor to prevent instantiation
  AppConstants._();
}

/// アプリで使用する文字列定数
class AppStrings {
  // アプリ名とタイトル
  static const String appTitle = '算数れんしゅう';
  static const String homeTitle = 'ホーム';
  static const String practiceTitle = '練習';
  static const String historyTitle = 'スコア履歴';

  // 操作タイプ
  static const String multiplication = '掛け算';
  static const String division = '割り算';

  // ボタンテキスト
  static const String startPractice = '練習を始める';
  static const String retry = 'もう一度';
  static const String goHome = 'ホームに戻る';
  static const String close = '閉じる';
  static const String answer = 'こたえる';
  static const String hint = 'ヒント';

  // メッセージ
  static const String welcomeMessage = '今日も楽しく勉強しましょう！';
  static const String goodJobMessage = 'お疲れ様でした！';
  static const String correctAnswer = 'せいかい！';
  static const String wrongAnswer = '答えは %d です';
  static const String enterAnswer = '答えを入力してください';
  static const String enterValidNumber = '正しい数字を入力してください';
  static const String enterPositiveNumber = '正の数を入力してください';

  // 統計ラベル
  static const String streakDays = '連続練習';
  static const String weeklyPractice = '今週の練習';
  static const String totalPractice = '総練習回数';
  static const String averageScore = '平均スコア';
  static const String bestScore = '最高記録';
  static const String accuracy = '正答率';
  static const String correctAnswers = '正解数';
  static const String timeSpent = '所要時間';

  // エラーメッセージ
  static const String loadError = 'データの読み込みに失敗しました';
  static const String saveError = 'データの保存に失敗しました';
  static const String unknownError = '予期しないエラーが発生しました';

  // Private constructor to prevent instantiation
  AppStrings._();
}

/// アプリで使用するスタイル定数
class AppStyles {
  // テキストスタイル
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
  );

  // パディング
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: 16.0);

  // ボーダー半径
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(16.0));

  // シャドウ
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Private constructor to prevent instantiation
  AppStyles._();
}
