import 'package:flutter/material.dart';

/// アプリのテーマを管理するクラス
class AppTheme {
  static const Color _primaryColor = Colors.blue;

  /// ライトテーマ
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  /// ダークテーマ（将来の拡張用）
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  /// テキストテーマ（子供向けに大きめのフォント）
  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    bodySmall: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  );

  /// ボタンテーマ（子供向けに大きめのタッチターゲット）
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(120, 56),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  /// カードテーマ（角を丸くして子供向けの優しいデザイン）
  static const CardTheme _cardTheme = CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  /// AppBarテーマ
  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );

  /// 入力フィールドテーマ
  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  );

  /// ミニゲーム用のカラーパレット
  static const Map<String, Color> miniGameColors = {
    'number_memory': Color(0xFF4CAF50), // Green
    'speed_math': Color(0xFFFF9800), // Orange
    'sliding_puzzle': Color(0xFF9C27B0), // Purple
    'rhythm_tap': Color(0xFFE91E63), // Pink
    'dodge_game': Color(0xFFF44336), // Red
  };

  /// 算数操作タイプ用のカラーパレット
  static const Map<String, Color> operationColors = {
    'addition': Colors.orange,
    'subtraction': Colors.purple,
    'multiplication': Colors.blue,
    'division': Colors.green,
  };

  /// グラデーション
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_primaryColor, Color(0xFF1565C0)],
      );

  /// シャドウスタイル
  static List<BoxShadow> get defaultShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
