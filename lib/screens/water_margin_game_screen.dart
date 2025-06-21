/// 水滸伝戦略ゲーム メイン画面
/// フェーズ1: 基本的なマップ表示とUI
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../models/water_margin_strategy_game.dart';
import 'widgets/game_info_panel.dart';
import 'widgets/hero_list_panel.dart';
import 'widgets/province_detail_panel.dart';
import 'widgets/water_margin_map.dart';

/// 水滸伝戦略ゲームのメイン画面
class WaterMarginGameScreen extends StatelessWidget {
  const WaterMarginGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WaterMarginGameController()..initializeGame(),
      child: const _WaterMarginGameView(),
    );
  }
}

class _WaterMarginGameView extends StatelessWidget {
  const _WaterMarginGameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水滸伝 天下統一'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Row(
                children: [
                  Icon(Icons.monetization_on, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.gameState.playerGold}両',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.gameState.currentTurn}年',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<WaterMarginGameController>(
        builder: (context, controller, child) {
          if (controller.gameState.gameStatus == GameStatus.victory) {
            return const _VictoryScreen();
          }
          if (controller.gameState.gameStatus == GameStatus.defeat) {
            return const _DefeatScreen();
          }

          return const _GamePlayView();
        },
      ),
    );
  }
}

class _GamePlayView extends StatelessWidget {
  const _GamePlayView();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左サイドパネル
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          child: const Column(
            children: [
              // ゲーム情報パネル
              GameInfoPanel(),
              Divider(height: 1),
              // 選択された州の詳細
              Expanded(child: ProvinceDetailPanel()),
            ],
          ),
        ),
        // メインマップエリア
        const Expanded(
          flex: 2,
          child: WaterMarginMap(),
        ),
        // 右サイドパネル
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          child: const HeroListPanel(),
        ),
      ],
    );
  }
}

class _VictoryScreen extends StatelessWidget {
  const _VictoryScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 120,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              Text(
                '🎉 勝利！ 🎉',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '梁山泊の英雄たちが天下を統一しました！',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '義賊たちの正義が世を照らし、\n新たな平和な時代の幕開けです。',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<WaterMarginGameController>().initializeGame();
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('もう一度プレイ'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('ホームに戻る'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefeatScreen extends StatelessWidget {
  const _DefeatScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_very_dissatisfied,
                size: 120,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                '💔 敗北... 💔',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '梁山泊が陥落しました...',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '英雄たちは散り散りとなり、\n義賊の夢は潰えました。\nしかし、諦めずに再び立ち上がりましょう！',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<WaterMarginGameController>().initializeGame();
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('再挑戦'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('ホームに戻る'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
