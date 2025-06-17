import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/bindings/app_bindings.dart';
import 'presentation/controllers/math_practice_controller.dart';
import 'screens/home_screen.dart';
import 'services/math_service.dart';
import 'services/mini_game_service.dart';
import 'services/points_service.dart';
import 'services/score_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 依存性注入を初期化
  await AppBindings.init();
  
  runApp(const SyonanApp());
}

/// メインアプリケーションクラス
/// Clean Architecture + MVVMパターンを採用した小学三年生向けの算数学習アプリ
class SyonanApp extends StatelessWidget {
  const SyonanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Clean Architectureベースの新しいコントローラー
        ChangeNotifierProvider<MathPracticeController>(
          create: (_) => AppBindings.mathPracticeController,
        ),
        
        // 既存のサービス（段階的に移行するため残しておく）
        Provider<MathService>(create: (_) => MathService()),
        ChangeNotifierProvider<ScoreService>(create: (_) => ScoreService()),
        ChangeNotifierProvider<PointsService>(create: (_) => PointsService()),
        ChangeNotifierProvider<MiniGameService>(create: (_) => MiniGameService()),
      ],
      child: MaterialApp(
        title: '算数れんしゅう',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
