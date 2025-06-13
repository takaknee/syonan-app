import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/math_service.dart';
import 'services/points_service.dart';
import 'services/score_service.dart';

void main() {
  runApp(const SyonanApp());
}

/// メインアプリケーションクラス
/// 小学三年生向けの算数学習アプリのエントリーポイント
class SyonanApp extends StatelessWidget {
  const SyonanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 算数問題生成サービス
        Provider<MathService>(create: (context) => MathService()),
        // スコア管理サービス
        ChangeNotifierProvider<ScoreService>(
          create: (context) => ScoreService(),
        ),
        // ポイントシステム管理サービス
        ChangeNotifierProvider<PointsService>(
          create: (context) => PointsService(),
        ),
      ],
      child: MaterialApp(
        title: '算数れんしゅう',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Material Design 3を使用した子供向けのカラフルなテーマ
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
          // 子供向けの大きめのフォントサイズ
          textTheme: const TextTheme(
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
          ),
          // 子供向けのボタンスタイル（大きめのタッチターゲット）
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              // 大きめのタッチターゲット
              minimumSize: const Size(120, 56),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // カードの角を丸くして子供向けの優しいデザイン
          cardTheme: const CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
