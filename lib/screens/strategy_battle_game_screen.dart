import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mini_game.dart';
import '../models/strategy_game.dart';
import '../services/mini_game_service.dart';
import '../services/strategy_game_service.dart';

/// 戦略バトルゲーム画面
class StrategyBattleGameScreen extends StatefulWidget {
  const StrategyBattleGameScreen({super.key});

  @override
  State<StrategyBattleGameScreen> createState() =>
      _StrategyBattleGameScreenState();
}

class _StrategyBattleGameScreenState extends State<StrategyBattleGameScreen> {
  final StrategyGameService _gameService = StrategyGameService();
  late StrategyGameState _gameState;
  late DateTime _startTime;
  bool _isGameComplete = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _startTime = DateTime.now();
      _gameState = _gameService.initializeGame();
      _isGameComplete = false;
    });
  }

  void _completeGame() {
    if (_isGameComplete) return;

    setState(() {
      _isGameComplete = true;
    });

    final duration = DateTime.now().difference(_startTime);
    final finalScore = _gameService.calculateFinalScore(_gameState, duration);

    // スコアを記録
    final miniGameService =
        Provider.of<MiniGameService>(context, listen: false);
    miniGameService.recordScore(
        'strategy_battle', finalScore, MiniGameDifficulty.hard);

    _showGameCompleteDialog(finalScore);
  }

  void _showGameCompleteDialog(int finalScore) {
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
              _restartGame();
            },
            child: const Text('再戦'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _isGameComplete = false;
    });
    _startGame();
  }

  void _selectTerritory(String territoryId) {
    setState(() {
      _gameState = _gameState.copyWith(
        selectedTerritoryId: _gameState.selectedTerritoryId == territoryId 
            ? null 
            : territoryId,
      );
    });
  }

  void _attackTerritory(String attackerTerritoryId, String defenderTerritoryId) {
    setState(() {
      _gameState = _gameService.attackTerritory(
        _gameState,
        attackerTerritoryId,
        defenderTerritoryId,
      );
    });

    // ゲーム終了チェック
    if (_gameState.gameStatus != GameStatus.playing) {
      _completeGame();
    }
  }

  void _recruitTroops(String territoryId, int amount) {
    setState(() {
      _gameState = _gameService.recruitTroops(_gameState, territoryId, amount);
    });
  }

  void _endTurn() {
    setState(() {
      _gameState = _gameService.endTurn(_gameState);
    });

    // ゲーム終了チェック
    if (_gameState.gameStatus != GameStatus.playing) {
      _completeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水滸伝 - 国盗り戦略'),
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restartGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // ゲーム情報パネル
          _buildGameInfoPanel(),
          // マップ表示
          Expanded(
            flex: 3,
            child: _buildGameMap(),
          ),
          // アクションパネル
          Expanded(
            flex: 1,
            child: _buildActionPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8BC34A).withValues(alpha: 0.1),
        border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('💰', '${_gameState.playerGold}', '金'),
          _buildInfoItem('⚔️', '${_gameState.playerTroops}', '兵力'),
          _buildInfoItem('🏰', '${_gameState.playerTerritoryCount}', '領土'),
          _buildInfoItem('📅', '${_gameState.currentTurn}', 'ターン'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGameMap() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: StrategyGameService.mapWidth,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _gameState.territories.length,
        itemBuilder: (context, index) {
          final territory = _gameState.territories[index];
          return _buildTerritoryTile(territory);
        },
      ),
    );
  }

  Widget _buildTerritoryTile(Territory territory) {
    final isSelected = _gameState.selectedTerritoryId == territory.id;
    final isPlayerTerritory = territory.owner == Owner.player;
    final isEnemyTerritory = territory.owner == Owner.enemy;
    
    Color backgroundColor;
    Color borderColor;
    
    if (isPlayerTerritory) {
      backgroundColor = const Color(0xFF4CAF50);
      borderColor = isSelected ? Colors.blue : Colors.green;
    } else if (isEnemyTerritory) {
      backgroundColor = const Color(0xFFF44336);
      borderColor = isSelected ? Colors.blue : Colors.red;
    } else {
      backgroundColor = const Color(0xFF9E9E9E);
      borderColor = isSelected ? Colors.blue : Colors.grey;
    }

    return GestureDetector(
      onTap: () => _selectTerritory(territory.id),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.8),
          border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (territory.isCapital)
              const Text('👑', style: TextStyle(fontSize: 16)),
            Text(
              territory.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '⚔️${territory.troops}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel() {
    final selectedTerritory = _gameState.selectedTerritory;
    
    if (selectedTerritory == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            '領土をタップして選択してください',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '選択中: ${selectedTerritory.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (selectedTerritory.owner == Owner.player) ...[
            _buildPlayerTerritoryActions(selectedTerritory),
          ] else ...[
            _buildEnemyTerritoryActions(selectedTerritory),
          ],
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _endTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8BC34A),
              foregroundColor: Colors.white,
            ),
            child: const Text('ターン終了'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTerritoryActions(Territory territory) {
    final canRecruit = _gameState.playerGold >= StrategyGameService.troopCost &&
                      territory.troops < territory.maxTroops;
    
    return Column(
      children: [
        Row(
          children: [
            Text('兵力: ${territory.troops}/${territory.maxTroops}'),
            const Spacer(),
            Text('資源: ${territory.resources}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: canRecruit ? () => _recruitTroops(territory.id, 1) : null,
                child: Text('兵士募集 (${StrategyGameService.troopCost}金)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ..._buildAttackButtons(territory),
      ],
    );
  }

  Widget _buildEnemyTerritoryActions(Territory territory) {
    return Column(
      children: [
        Text('敵領土 - 兵力: ${territory.troops}'),
        if (territory.isCapital)
          const Text('👑 敵の首都！', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<Widget> _buildAttackButtons(Territory territory) {
    final attackableTargets = _gameService.getAttackableTargets(_gameState, territory.id);
    
    if (attackableTargets.isEmpty || territory.troops <= 1) {
      return [const Text('攻撃可能な敵がいません', style: TextStyle(color: Colors.grey))];
    }

    return attackableTargets.map((target) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: ElevatedButton(
          onPressed: () => _attackTerritory(territory.id, target.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('${target.name}を攻撃 (兵力${target.troops})'),
        ),
      );
    }).toList();
  }
}
