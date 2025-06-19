import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/mini_game.dart';
import '../models/city_building_game.dart';
import '../services/mini_game_service.dart';
import '../services/city_building_game_service.dart';

/// 街づくりゲーム画面
class CityBuilderGameScreen extends StatefulWidget {
  const CityBuilderGameScreen({super.key});

  @override
  State<CityBuilderGameScreen> createState() => _CityBuilderGameScreenState();
}

class _CityBuilderGameScreenState extends State<CityBuilderGameScreen> {
  final CityBuildingGameService _gameService = CityBuildingGameService();
  late CityGameState _gameState;
  Timer? _gameTimer;
  bool _isGameComplete = false;
  String? _lastEventMessage;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameState = _gameService.initializeGame();
      _isGameComplete = false;
      _lastEventMessage = null;
    });
    
    // チュートリアルを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial();
    });
    
    // ゲームタイマーを開始（1秒ごとに時間チェック）
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _gameState.gameStatus == GameStatus.playing) {
        // 時間切れチェックのみ行う
        if (_gameState.isTimeUp) {
          setState(() {
            _gameState = _gameState.copyWith(gameStatus: GameStatus.timeUp);
          });
          _completeGame();
        } else {
          // UIの時間表示を更新
          setState(() {});
        }
      }
    });
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏙️ 街づくりゲーム'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('10分以内に理想の街を作ろう！'),
            const SizedBox(height: 12),
            Text(_gameService.getVictoryConditionsText()),
            const SizedBox(height: 12),
            const Text('・建物を建設して資源を生産\n・ターン終了で資源が更新\n・ランダムイベントに注意！'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('開始！'),
          ),
        ],
      ),
    );
  }

  void _completeGame() {
    if (_isGameComplete) return;

    _gameTimer?.cancel();
    setState(() {
      _isGameComplete = true;
    });

    final finalScore = _gameService.calculateFinalScore(_gameState);

    // スコアを記録
    final miniGameService =
        Provider.of<MiniGameService>(context, listen: false);
    miniGameService.recordScore(
        'city_builder', finalScore, MiniGameDifficulty.hard);

    _showGameCompleteDialog(finalScore);
  }

  void _buildBuilding(BuildingType buildingType) {
    if (_isGameComplete) return;

    setState(() {
      _gameState = _gameService.buildBuilding(_gameState, buildingType);
    });
  }

  void _endTurn() {
    if (_isGameComplete) return;

    final oldResources = Map<ResourceType, int>.from(_gameState.resources);
    
    final turnResult = _gameService.endTurn(_gameState);
    
    setState(() {
      _gameState = turnResult.gameState;
      
      // ゲーム終了チェック
      if (_gameState.gameStatus != GameStatus.playing) {
        _completeGame();
      }
    });

    // イベントが発生した場合は表示
    if (turnResult.triggeredEvent != null) {
      _showEvent(turnResult.triggeredEvent!);
    }

    // リソース変化を表示
    _showTurnSummary(oldResources, _gameState.resources);
  }

  void _showEvent(RandomEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(event.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(event.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(event.description),
            const SizedBox(height: 12),
            ...event.effects.entries.map((entry) {
              final emoji = _getResourceEmoji(entry.key);
              final sign = entry.value > 0 ? '+' : '';
              return Text(
                '$emoji $sign${entry.value}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: entry.value > 0 ? Colors.green : Colors.red,
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTurnSummary(Map<ResourceType, int> oldResources, Map<ResourceType, int> newResources) {
    final changes = <String>[];
    
    for (final resourceType in ResourceType.values) {
      final oldValue = oldResources[resourceType] ?? 0;
      final newValue = newResources[resourceType] ?? 0;
      final change = newValue - oldValue;
      
      if (change != 0) {
        final emoji = _getResourceEmoji(resourceType);
        final sign = change > 0 ? '+' : '';
        changes.add('$emoji$sign$change');
      }
    }
    
    if (changes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ターン結果: ${changes.join(' ')}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showGameCompleteDialog(int finalScore) {
    String title;
    String message;
    
    switch (_gameState.gameStatus) {
      case GameStatus.victory:
        title = '🏆 街づくり大成功！';
        message = '素晴らしい街を作り上げました！';
        break;
      case GameStatus.defeat:
        title = '😢 街づくり失敗...';
        message = '街が維持できませんでした...';
        break;
      case GameStatus.timeUp:
        title = '⏰ 時間切れ！';
        message = '10分間お疲れ様でした！';
        break;
      default:
        title = '🏆 街づくり完了！';
        message = 'ゲームが終了しました！';
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text('最終スコア: $finalScore点'),
            const SizedBox(height: 8),
            Text('人口: ${_gameState.totalPopulation}人'),
            const SizedBox(height: 4),
            Text('建物数: ${_gameState.totalBuildings}棟'),
            const SizedBox(height: 4),
            Text('街のサイズ: ${_gameState.citySize}'),
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
            child: const Text('新しい街づくり'),
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

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('街づくり'),
        backgroundColor: const Color(0xFF607D8B),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _formatTime(_gameState.remainingTime),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 資源表示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF607D8B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResourceDisplay('👥', '人口', _gameState.totalPopulation),
                      _buildResourceDisplay('🍞', '食料', _gameState.resources[ResourceType.food] ?? 0),
                      _buildResourceDisplay('🧱', '材料', _gameState.resources[ResourceType.materials] ?? 0),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResourceDisplay('⚡', 'エネルギー', _gameState.resources[ResourceType.energy] ?? 0),
                      _buildResourceDisplay('💰', 'お金', _gameState.resources[ResourceType.money] ?? 0),
                      _buildResourceDisplay('🏢', '建物', _gameState.totalBuildings),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 街の情報
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ターン: ${_gameState.currentTurn}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '街のサイズ: ${_gameState.citySize}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '建設可能: ${_gameState.citySize - _gameState.totalBuildings}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 建物選択
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '建物を選択してください：',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _gameService.getAvailableBuildingOptions(_gameState).length,
                      itemBuilder: (context, index) {
                        final buildingType = _gameService.getAvailableBuildingOptions(_gameState)[index];
                        return _buildBuildingCard(buildingType);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGameComplete ? null : _endTurn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF607D8B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('ターン終了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceDisplay(String emoji, String name, int value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(
          name,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBuildingCard(BuildingType buildingType) {
    final template = _getBuildingTemplate(buildingType);
    if (template == null) return const SizedBox.shrink();
    
    final existingBuilding = _gameState.buildings[buildingType];
    final canBuild = _gameState.hasEnoughResources(template.buildCost) && 
                    (_gameState.totalBuildings < _gameState.citySize || existingBuilding != null);
    final isUpgrade = existingBuilding != null;
    
    return Card(
      color: canBuild ? null : Colors.grey[100],
      child: InkWell(
        onTap: canBuild ? () => _buildBuilding(buildingType) : null,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(template.emoji, style: const TextStyle(fontSize: 20)),
              Text(
                isUpgrade ? '${template.name} Lv.${existingBuilding!.level + 1}' : template.name,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              // 建設コスト
              Wrap(
                alignment: WrapAlignment.center,
                children: template.buildCost.entries.map((entry) {
                  final resourceEmoji = _getResourceEmoji(entry.key);
                  final hasEnough = (_gameState.resources[entry.key] ?? 0) >= entry.value;
                  return Text(
                    '$resourceEmoji${entry.value}',
                    style: TextStyle(
                      fontSize: 8,
                      color: hasEnough ? Colors.green : Colors.red,
                    ),
                  );
                }).toList(),
              ),
              // 生産・効果
              if (template.production.isNotEmpty) 
                Wrap(
                  alignment: WrapAlignment.center,
                  children: template.production.entries.map((entry) {
                    final resourceEmoji = _getResourceEmoji(entry.key);
                    return Text(
                      '+$resourceEmoji${entry.value}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              if (template.populationProvided > 0)
                Text(
                  '+👥${template.populationProvided}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (isUpgrade)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'UP',
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Building? _getBuildingTemplate(BuildingType type) {
    // 既存の建物があればそのレベルアップ版を返す
    final existing = _gameState.buildings[type];
    if (existing != null && existing.canUpgrade()) {
      return existing.upgraded();
    }
    
    // 新規建物のテンプレートを取得
    switch (type) {
      case BuildingType.house:
        return const Building(
          type: BuildingType.house,
          name: '家',
          emoji: '🏠',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 10, ResourceType.money: 20},
          production: {},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 4,
          unlockRequirements: {},
        );
      case BuildingType.apartment:
        return const Building(
          type: BuildingType.apartment,
          name: 'アパート',
          emoji: '🏢',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 25, ResourceType.money: 50},
          production: {},
          upkeep: {ResourceType.energy: 2},
          populationProvided: 12,
          unlockRequirements: {ResourceType.population: 20},
        );
      case BuildingType.mansion:
        return const Building(
          type: BuildingType.mansion,
          name: 'マンション',
          emoji: '🏬',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.materials: 50, ResourceType.money: 100},
          production: {},
          upkeep: {ResourceType.energy: 4},
          populationProvided: 30,
          unlockRequirements: {ResourceType.population: 50},
        );
      case BuildingType.farm:
        return const Building(
          type: BuildingType.farm,
          name: '農場',
          emoji: '🚜',
          level: 1,
          maxLevel: 4,
          buildCost: {ResourceType.materials: 15, ResourceType.money: 30},
          production: {ResourceType.food: 8},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 0,
          unlockRequirements: {},
        );
      case BuildingType.factory:
        return const Building(
          type: BuildingType.factory,
          name: '工場',
          emoji: '🏭',
          level: 1,
          maxLevel: 4,
          buildCost: {ResourceType.materials: 30, ResourceType.money: 60},
          production: {ResourceType.materials: 6, ResourceType.money: 10},
          upkeep: {ResourceType.energy: 3, ResourceType.food: 2},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 15},
        );
      case BuildingType.powerPlant:
        return const Building(
          type: BuildingType.powerPlant,
          name: '発電所',
          emoji: '⚡',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 40, ResourceType.money: 80},
          production: {ResourceType.energy: 12},
          upkeep: {ResourceType.materials: 2},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 25},
        );
      case BuildingType.mine:
        return const Building(
          type: BuildingType.mine,
          name: '鉱山',
          emoji: '⛏️',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.money: 70},
          production: {ResourceType.materials: 10},
          upkeep: {ResourceType.energy: 2, ResourceType.food: 1},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 20},
        );
      case BuildingType.shop:
        return const Building(
          type: BuildingType.shop,
          name: '商店',
          emoji: '🏪',
          level: 1,
          maxLevel: 3,
          buildCost: {ResourceType.materials: 20, ResourceType.money: 40},
          production: {ResourceType.money: 15},
          upkeep: {ResourceType.energy: 1},
          populationProvided: 0,
          unlockRequirements: {ResourceType.population: 30},
        );
      case BuildingType.hospital:
        return const Building(
          type: BuildingType.hospital,
          name: '病院',
          emoji: '🏥',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.materials: 35, ResourceType.money: 100},
          production: {},
          upkeep: {ResourceType.energy: 3, ResourceType.money: 10},
          populationProvided: 5,
          unlockRequirements: {ResourceType.population: 40},
        );
      case BuildingType.school:
        return const Building(
          type: BuildingType.school,
          name: '学校',
          emoji: '🏫',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.materials: 30, ResourceType.money: 80},
          production: {},
          upkeep: {ResourceType.energy: 2, ResourceType.money: 5},
          populationProvided: 8,
          unlockRequirements: {ResourceType.population: 35},
        );
      case BuildingType.park:
        return const Building(
          type: BuildingType.park,
          name: '公園',
          emoji: '🌳',
          level: 1,
          maxLevel: 2,
          buildCost: {ResourceType.money: 25},
          production: {},
          upkeep: {ResourceType.money: 2},
          populationProvided: 3,
          unlockRequirements: {ResourceType.population: 25},
        );
    }
  }

  String _getResourceEmoji(ResourceType type) {
    switch (type) {
      case ResourceType.population:
        return '👥';
      case ResourceType.food:
        return '🍞';
      case ResourceType.materials:
        return '🧱';
      case ResourceType.energy:
        return '⚡';
      case ResourceType.money:
        return '💰';
    }
  }
}
