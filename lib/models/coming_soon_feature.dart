/// 近日公開予定の機能
class ComingSoonFeature {
  const ComingSoonFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    this.expectedRelease,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final int color; // Color value as int for serialization
  final String? expectedRelease;
}

/// 近日公開予定の機能一覧
class ComingSoonFeatures {
  static const List<ComingSoonFeature> all = [
    ComingSoonFeature(
      id: 'ai_tutor',
      name: 'AI先生',
      description: '個別指導でより効率的な学習を！',
      emoji: '🤖',
      color: 0xFF4A90E2, // Blue
      expectedRelease: '2024年夏',
    ),
    ComingSoonFeature(
      id: 'multiplayer_battle',
      name: 'みんなでバトル',
      description: '友達と一緒に算数バトルを楽しもう！',
      emoji: '⚔️',
      color: 0xFFFF6B6B, // Red
      expectedRelease: '2024年秋',
    ),
    ComingSoonFeature(
      id: 'story_mode',
      name: 'ストーリーモード',
      description: '冒険しながら算数を学ぼう！',
      emoji: '📚',
      color: 0xFF7ED321, // Green
      expectedRelease: '2024年冬',
    ),
    ComingSoonFeature(
      id: 'parent_dashboard',
      name: '保護者ダッシュボード',
      description: 'お子さんの学習進捗を詳しく確認',
      emoji: '📊',
      color: 0xFF9013FE, // Purple
      expectedRelease: '2025年春',
    ),
  ];

  static ComingSoonFeature? findById(String id) {
    try {
      return all.firstWhere((feature) => feature.id == id);
    } catch (e) {
      return null;
    }
  }
}
