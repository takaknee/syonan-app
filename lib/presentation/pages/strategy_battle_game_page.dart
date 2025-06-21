import 'package:flutter/material.dart';

import '../controllers/strategy_game_controller.dart';
import '../../services/strategy_game_service.dart';
import '../widgets/strategy_game/action_panel.dart';
import '../widgets/strategy_game/game_dialogs.dart';
import '../widgets/strategy_game/game_info_panel.dart';
import '../widgets/strategy_game/game_map.dart';

/// リファクタリングされた戦略バトルゲーム画面
class StrategyBattleGameScreen extends StatefulWidget {
  const StrategyBattleGameScreen({super.key});

  @override
  State<StrategyBattleGameScreen> createState() => _StrategyBattleGameScreenState();
}

class _StrategyBattleGameScreenState extends State<StrategyBattleGameScreen> {
  late StrategyGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StrategyGameController(
      gameService: StrategyGameService(),
      context: context,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('水滸伝 - 国盗り戦略'),
      backgroundColor: const Color(0xFF8BC34A),
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: _controller.openTutorial,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _controller.restartGame,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            // ゲーム情報パネル
            GameInfoPanel(gameState: _controller.gameState),
            // マップ表示
            Expanded(
              flex: 3,
              child: GameMap(
                gameState: _controller.gameState,
                gameService: _controller.gameService,
                onTerritorySelected: _controller.selectTerritory,
              ),
            ),
            // アクションパネル（AndroidのホームボタンバーによるUI隠れを防ぐ）
            SafeArea(
              top: false,
              child: Expanded(
                child: ActionPanel(
                  gameState: _controller.gameState,
                  gameService: _controller.gameService,
                  onRecruitTroops: _controller.recruitTroops,
                  onAttackTerritory: _controller.attackTerritory,
                  onEndTurn: _controller.endTurn,
                ),
              ),
            ),
          ],
        ),
        if (_controller.showTutorial) TutorialOverlay(onClose: _controller.closeTutorial),
      ],
    );
  }
}
