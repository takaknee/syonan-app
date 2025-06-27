/// 水滸伝ゲームのマップウィジェット
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/water_margin_game_controller.dart';
import '../../models/water_margin_strategy_game.dart';

/// メインマップ表示ウィジェット
class WaterMarginMap extends StatelessWidget {
  const WaterMarginMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.shade100,
            Colors.green.shade100,
          ],
        ),
      ),
      child: Consumer<WaterMarginGameController>(
        builder: (context, controller, child) {
          return Stack(
            children: [
              // 背景
              const _MapBackground(),
              // 州の表示
              ..._buildProvinceWidgets(context, controller),
              // マップタイトル
              const _MapTitle(),
              // ターン進行ボタン
              _NextTurnButton(controller: controller),
            ],
          );
        },
      ),
    );
  }

  /// 州ウィジェットのリストを生成
  List<Widget> _buildProvinceWidgets(
    BuildContext context,
    WaterMarginGameController controller,
  ) {
    return controller.gameState.provinces.map((province) {
      return _ProvinceWidget(
        province: province,
        isSelected: province.id == controller.gameState.selectedProvinceId,
        onTap: () => controller.selectProvince(province.id),
      );
    }).toList();
  }
}

/// マップの背景
class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/map_background.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
      ),
    );
  }
}

/// マップタイトル
class _MapTitle extends StatelessWidget {
  const _MapTitle();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '北宋天下図',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '水滸伝の世界',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ターン進行ボタン
class _NextTurnButton extends StatelessWidget {
  const _NextTurnButton({required this.controller});

  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton.extended(
        onPressed: () => controller.nextTurn(),
        icon: const Icon(Icons.skip_next),
        label: const Text('次のターン'),
        heroTag: 'nextTurn',
      ),
    );
  }
}

/// 個別の州ウィジェット
class _ProvinceWidget extends StatefulWidget {
  const _ProvinceWidget({
    required this.province,
    required this.isSelected,
    required this.onTap,
  });

  final Province province;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ProvinceWidget> createState() => _ProvinceWidgetState();
}

class _ProvinceWidgetState extends State<_ProvinceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_ProvinceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.province.position.dx * MediaQuery.of(context).size.width * 0.4 + 100,
      top: widget.province.position.dy * MediaQuery.of(context).size.height * 0.6 + 50,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.province.factionColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isSelected ? Colors.white : Colors.black26,
                    width: widget.isSelected ? 3 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.province.provinceIcon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.province.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.province.currentTroops}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
