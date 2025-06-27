import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mini_game.dart';
import '../../models/strategy_game.dart';
import '../../services/mini_game_service.dart';
import '../../services/strategy_game_service.dart';

/// 戦略ゲームのコントローラー
class StrategyGameController extends ChangeNotifier {
  StrategyGameController({
    required this.gameService,
    required this.context,
  }) {
    _startGame();
    _startTutorialTimer();
  }

  final StrategyGameService gameService;
  final BuildContext context;

  late StrategyGameState _gameState;
  late DateTime _startTime;
  bool _isGameComplete = false;
  bool _showTutorial = true;

  // Getters
  StrategyGameState get gameState => _gameState;
  bool get isGameComplete => _isGameComplete;
  bool get showTutorial => _showTutorial;

  /// ゲームを開始
  void _startGame() {
    _startTime = DateTime.now();
    _gameState = gameService.initializeGame();
    _isGameComplete = false;
    notifyListeners();
  }

  /// チュートリアルタイマーを開始
  void _startTutorialTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_showTutorial) {
        closeTutorial();
      }
    });
  }

  /// チュートリアルを閉じる
  void closeTutorial() {
    _showTutorial = false;
    notifyListeners();
  }

  /// チュートリアルを表示
  void openTutorial() {
    _showTutorial = true;
    notifyListeners();
  }

  /// ゲームを再開始
  void restartGame() {
    _isGameComplete = false;
    _showTutorial = true;
    _startGame();
  }

  /// 領土を選択
  void selectTerritory(String territoryId) {
    _gameState = _gameState.copyWith(
      selectedTerritoryId: _gameState.selectedTerritoryId == territoryId ? null : territoryId,
    );
    notifyListeners();
  }

  /// 領土を攻撃
  void attackTerritory(String attackerTerritoryId, String defenderTerritoryId) {
    final attacker = _gameState.getTerritoryById(attackerTerritoryId);
    final defender = _gameState.getTerritoryById(defenderTerritoryId);

    if (attacker == null || defender == null) return;

    _gameState = gameService.attackTerritory(
      _gameState,
      attackerTerritoryId,
      defenderTerritoryId,
    );
    notifyListeners();

    // 戦闘結果を表示
    final conqueredTerritory = _gameState.getTerritoryById(defenderTerritoryId);
    final wasConquered = conqueredTerritory?.owner == Owner.player;

    _showBattleResult(defender.name, wasConquered);

    // ゲーム終了チェック
    if (_gameState.gameStatus != GameStatus.playing) {
      _completeGame();
    }
  }

  /// 兵士を募集
  void recruitTroops(String territoryId, int amount) {
    _gameState = gameService.recruitTroops(_gameState, territoryId, amount);
    notifyListeners();
  }

  /// ターンを終了
  void endTurn() {
    _gameState = gameService.endTurn(_gameState);
    notifyListeners();

    // ゲーム終了チェック
    if (_gameState.gameStatus != GameStatus.playing) {
      _completeGame();
    }
  }

  /// ゲームを完了
  void _completeGame() {
    if (_isGameComplete) return;

    _isGameComplete = true;
    notifyListeners();

    final duration = DateTime.now().difference(_startTime);
    final finalScore = gameService.calculateFinalScore(_gameState, duration);

    // スコアを記録
    final miniGameService = Provider.of<MiniGameService>(context, listen: false);
    miniGameService.recordScore('strategy_battle', finalScore, MiniGameDifficulty.hard);

    _triggerGameCompleteDialog(finalScore);
  }

  /// 戦闘結果を表示
  void _showBattleResult(String territoryName, bool victory) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          victory ? '🎉 $territoryNameを占領しました！' : '😓 $territoryNameの攻略に失敗...',
        ),
        backgroundColor: victory ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ゲーム完了ダイアログを表示
  void _triggerGameCompleteDialog(int finalScore) {
    final isVictory = _gameState.gameStatus == GameStatus.victory;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isVictory ? '🏆 勝利！' : '😢 敗北...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('最終スコア: $finalScore点'),
            const SizedBox(height: 8),
            Text('支配領土: ${_gameState.playerTerritoryCount}'),
            const SizedBox(height: 4),
            Text('ターン数: ${_gameState.currentTurn}'),
            if (isVictory) ...[
              const SizedBox(height: 8),
              const Text('🎉 敵の首都を占領しました！'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ホームに戻る'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              restartGame();
            },
            child: const Text('再戦'),
          ),
        ],
      ),
    );
  }
}
