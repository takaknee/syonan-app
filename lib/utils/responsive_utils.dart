import 'package:flutter/material.dart';

/// レスポンシブデザインユーティリティ
/// Xperiaをベースラインとしたモバイルファーストアプローチ
class ResponsiveUtils {
  // Xperia基準の画面サイズ（約360dp幅）
  static const double _baselineWidth = 360.0;
  static const double _baselineHeight = 640.0;
  
  // ブレークポイント
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  /// 画面幅の取得
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 画面高さの取得
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// デバイスタイプの判定
  static DeviceType getDeviceType(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// レスポンシブな水平パディング
  static double getHorizontalPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < mobileBreakpoint) return 16.0;
    if (width < tabletBreakpoint) return 24.0;
    return 32.0;
  }

  /// レスポンシブな垂直パディング
  static double getVerticalPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < mobileBreakpoint) return 12.0;
    if (width < tabletBreakpoint) return 16.0;
    return 20.0;
  }

  /// レスポンシブなスペーシング
  static double getSpacing(BuildContext context, {double factor = 1.0}) {
    final width = getScreenWidth(context);
    double baseSpacing;
    if (width < mobileBreakpoint) {
      baseSpacing = 12.0;
    } else if (width < tabletBreakpoint) {
      baseSpacing = 16.0;
    } else {
      baseSpacing = 20.0;
    }
    return baseSpacing * factor;
  }

  /// レスポンシブなグリッドの列数
  static int getGridColumns(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < mobileBreakpoint) return 2;
    if (width < tabletBreakpoint) return 3;
    return 4;
  }

  /// レスポンシブなカードの最大幅
  static double getCardMaxWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < mobileBreakpoint) return width * 0.9;
    if (width < tabletBreakpoint) return width * 0.8;
    return 400.0;
  }

  /// モバイルかどうかの判定
  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < mobileBreakpoint;
  }

  /// タブレットかどうかの判定
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// デスクトップかどうかの判定
  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= tabletBreakpoint;
  }

  /// レスポンシブな値の取得
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = getScreenWidth(context);
    if (width >= tabletBreakpoint && desktop != null) return desktop;
    if (width >= mobileBreakpoint && tablet != null) return tablet;
    return mobile;
  }

  /// セーフエリアを考慮したパディング
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final horizontalPadding = getHorizontalPadding(context);
    final verticalPadding = getVerticalPadding(context);
    
    return EdgeInsets.only(
      left: horizontalPadding + mediaQuery.padding.left,
      right: horizontalPadding + mediaQuery.padding.right,
      top: verticalPadding + mediaQuery.padding.top,
      bottom: verticalPadding + mediaQuery.padding.bottom,
    );
  }

  /// ミニゲームボタンの幅を計算（モバイル用）
  static double getMiniGameButtonWidth(BuildContext context, {bool isSingle = false}) {
    final width = getScreenWidth(context);
    final horizontalPadding = getHorizontalPadding(context);
    final spacing = getSpacing(context);
    
    if (isSingle) {
      // 単体の場合は画面幅の60%以下に制限
      return (width * 0.6).clamp(150.0, 200.0);
    }
    
    // 2列レイアウトの場合
    return (width - (horizontalPadding * 2) - spacing) / 2;
  }
}

/// デバイスタイプ列挙
enum DeviceType {
  mobile,
  tablet,
  desktop,
}