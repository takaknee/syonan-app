/// 水滸伝ゲームのイベントシステム
/// フェーズ2: イベント基盤、英雄との出会い、歴史的イベント
library;

import '../models/water_margin_strategy_game.dart' hide Hero;

/// イベントの種類
enum EventType {
  heroEncounter, // 英雄との出会い
  historical, // 歴史的イベント
  random, // ランダムイベント
  battle, // 戦闘イベント
  diplomatic, // 外交イベント
}

/// イベントの選択肢
class EventChoice {
  const EventChoice({
    required this.id,
    required this.text,
    required this.effects,
    this.requirements,
  });

  final String id;
  final String text;
  final List<EventEffect> effects;
  final EventRequirements? requirements;

  /// 選択肢が利用可能かチェック
  bool isAvailable(WaterMarginGameState gameState) {
    if (requirements == null) return true;
    return requirements!.isMet(gameState);
  }
}

/// イベントの効果
class EventEffect {
  const EventEffect({
    required this.type,
    required this.value,
    this.targetId,
  });

  final EventEffectType type;
  final int value;
  final String? targetId; // 対象のID（英雄、州など）

  static const EventEffect gainGold100 = EventEffect(
    type: EventEffectType.goldChange,
    value: 100,
  );

  static const EventEffect loseGold50 = EventEffect(
    type: EventEffectType.goldChange,
    value: -50,
  );

  static const EventEffect gainTroops500 = EventEffect(
    type: EventEffectType.troopsChange,
    value: 500,
  );
}

/// イベント効果の種類
enum EventEffectType {
  goldChange, // 資金変動
  troopsChange, // 兵力変動
  heroRecruitment, // 英雄登用
  provinceControl, // 州の支配権変更
  loyaltyChange, // 民心変動
  relationshipChange, // 関係値変動
}

/// イベントの発生条件
class EventRequirements {
  const EventRequirements({
    this.minTurn,
    this.maxTurn,
    this.requiredProvinces,
    this.requiredHeroes,
    this.minGold,
    this.controlledProvince,
  });

  final int? minTurn;
  final int? maxTurn;
  final List<String>? requiredProvinces;
  final List<String>? requiredHeroes;
  final int? minGold;
  final String? controlledProvince;

  bool isMet(WaterMarginGameState gameState) {
    if (minTurn != null && gameState.currentTurn < minTurn!) return false;
    if (maxTurn != null && gameState.currentTurn > maxTurn!) return false;
    if (minGold != null && gameState.playerGold < minGold!) return false;

    if (requiredProvinces != null) {
      final controlledProvinces = gameState.provinces
          .where((p) => p.controller == Faction.liangshan)
          .map((p) => p.id)
          .toSet();
      if (!requiredProvinces!.every(controlledProvinces.contains)) return false;
    }

    if (requiredHeroes != null) {
      final recruitedHeroes =
          gameState.heroes.where((h) => h.isRecruited).map((h) => h.id).toSet();
      if (!requiredHeroes!.every(recruitedHeroes.contains)) return false;
    }

    if (controlledProvince != null) {
      final province = gameState.getProvinceById(controlledProvince!);
      if (province?.controller != Faction.liangshan) return false;
    }

    return true;
  }
}

/// ゲームイベント
class GameEvent {
  const GameEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.choices,
    this.requirements,
    this.imagePath,
    this.isRepeatable = false,
  });

  final String id;
  final EventType type;
  final String title;
  final String description;
  final List<EventChoice> choices;
  final EventRequirements? requirements;
  final String? imagePath;
  final bool isRepeatable;

  /// イベントが発生可能かチェック
  bool canTrigger(WaterMarginGameState gameState, Set<String> triggeredEvents) {
    if (!isRepeatable && triggeredEvents.contains(id)) return false;
    if (requirements != null && !requirements!.isMet(gameState)) return false;
    return true;
  }
}

/// 水滸伝イベントデータベース
class WaterMarginEvents {
  /// 利用可能なイベントリスト
  static List<GameEvent> get allEvents => [
        // 英雄との出会いイベント
        _luJunyiEncounter,
        _wuSongEncounter,
        _huaRongEncounter,
        _yangZhiEncounter,

        // 歴史的イベント
        _liangShanExpansion,
        _imperialRaid,
        _merchantCaravan,

        // ランダムイベント
        _banditsRaid,
        _goodHarvest,
        _scholarVisit,
        _mysteriousStranger,
      ];

  // === 英雄との出会いイベント ===

  /// 盧俊義との出会い
  static const GameEvent _luJunyiEncounter = GameEvent(
    id: 'lu_junyi_encounter',
    type: EventType.heroEncounter,
    title: '玉麒麟との出会い',
    description: '大名府で盧俊義（玉麒麟）という武芸に秀でた豪商と出会いました。'
        '彼は義賊の志に共感しているようですが、まだ迷いがあるようです。',
    choices: [
      EventChoice(
        id: 'persuade',
        text: '義の道を説いて説得する',
        effects: [
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'lu_junyi',
          ),
        ],
        requirements: EventRequirements(
          requiredHeroes: ['song_jiang'], // 宋江が必要
        ),
      ),
      EventChoice(
        id: 'offer_gold',
        text: '資金援助を申し出る（500両）',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -500),
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'lu_junyi',
          ),
        ],
        requirements: EventRequirements(minGold: 500),
      ),
      EventChoice(
        id: 'leave',
        text: '今は去る',
        effects: [],
      ),
    ],
    requirements: EventRequirements(
      minTurn: 3,
      controlledProvince: 'daming',
    ),
  );

  /// 武松との出会い
  static const GameEvent _wuSongEncounter = GameEvent(
    id: 'wu_song_encounter',
    title: '行者との運命',
    description: '景陽岡で虎を退治したという武松（行者）と出会いました。'
        '彼は兄の仇を討ち、今は流浪の身です。',
    type: EventType.heroEncounter,
    choices: [
      EventChoice(
        id: 'challenge_duel',
        text: '一騎討ちで実力を試す',
        effects: [
          EventEffect(type: EventEffectType.troopsChange, value: -200),
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'wu_song',
          ),
        ],
        requirements: EventRequirements(
          requiredHeroes: ['lin_chong'], // 林冲が必要
        ),
      ),
      EventChoice(
        id: 'offer_brotherhood',
        text: '義兄弟の契りを結ぶ',
        effects: [
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'wu_song',
          ),
        ],
      ),
      EventChoice(
        id: 'respectful_retreat',
        text: '敬意を表して立ち去る',
        effects: [EventEffect.gainGold100],
      ),
    ],
    requirements: EventRequirements(minTurn: 5),
  );

  /// 花栄との出会い
  static const GameEvent _huaRongEncounter = GameEvent(
    id: 'hua_rong_encounter',
    title: '小李広の弓術',
    description: '青州府で花栄（小李広）という弓の名手と出会いました。'
        '彼は朝廷に仕えていますが、腐敗に心を痛めています。',
    type: EventType.heroEncounter,
    choices: [
      EventChoice(
        id: 'archery_contest',
        text: '弓術大会を開催する',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -300),
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'hua_rong',
          ),
        ],
        requirements: EventRequirements(minGold: 300),
      ),
      EventChoice(
        id: 'discuss_justice',
        text: '正義について語り合う',
        effects: [
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'hua_rong',
          ),
        ],
        requirements: EventRequirements(
          requiredHeroes: ['song_jiang', 'wu_yong'],
        ),
      ),
      EventChoice(
        id: 'wait_for_time',
        text: '時を待つ',
        effects: [],
      ),
    ],
    requirements: EventRequirements(
      controlledProvince: 'qingzhou',
      minTurn: 4,
    ),
  );

  /// 楊志との出会い
  static const GameEvent _yangZhiEncounter = GameEvent(
    id: 'yang_zhi_encounter',
    title: '青面獣の苦悩',
    description: '楊志（青面獣）は朝廷軍の将校でしたが、生辰綱を奪われ困窮しています。'
        '彼は名誉を重んじる武人です。',
    type: EventType.heroEncounter,
    choices: [
      EventChoice(
        id: 'restore_honor',
        text: '名誉回復の機会を与える',
        effects: [
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'yang_zhi',
          ),
          EventEffect(type: EventEffectType.troopsChange, value: 800),
        ],
        requirements: EventRequirements(
          requiredProvinces: ['kaifeng'], // 開封府が必要
        ),
      ),
      EventChoice(
        id: 'offer_money',
        text: '金銭的援助を申し出る',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -400),
          EventEffect(
            type: EventEffectType.heroRecruitment,
            value: 1,
            targetId: 'yang_zhi',
          ),
        ],
        requirements: EventRequirements(minGold: 400),
      ),
      EventChoice(
        id: 'leave_alone',
        text: 'そっとしておく',
        effects: [EventEffect.gainGold100],
      ),
    ],
    requirements: EventRequirements(minTurn: 6),
  );

  // === 歴史的イベント ===

  /// 梁山泊拡張
  static const GameEvent _liangShanExpansion = GameEvent(
    id: 'liangshan_expansion',
    title: '梁山泊の大拡張',
    description: '梁山泊の勢力が拡大し、より多くの義士が集まってきています。'
        '本格的な要塞建設を行う時が来ました。',
    type: EventType.historical,
    choices: [
      EventChoice(
        id: 'build_fortress',
        text: '大要塞を建設する（1000両）',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -1000),
          EventEffect(type: EventEffectType.troopsChange, value: 2000),
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: 20,
            targetId: 'liangshan',
          ),
        ],
        requirements: EventRequirements(minGold: 1000),
      ),
      EventChoice(
        id: 'gradual_expansion',
        text: '段階的に拡張する（500両）',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -500),
          EventEffect(type: EventEffectType.troopsChange, value: 1000),
        ],
        requirements: EventRequirements(minGold: 500),
      ),
      EventChoice(
        id: 'maintain_status',
        text: '現状維持',
        effects: [EventEffect.gainGold100],
      ),
    ],
    requirements: EventRequirements(
      minTurn: 10,
      requiredProvinces: ['liangshan', 'jizhou'],
    ),
  );

  /// 朝廷の討伐軍
  static const GameEvent _imperialRaid = GameEvent(
    id: 'imperial_raid',
    title: '朝廷討伐軍の来襲',
    description: '朝廷が大軍を派遣して梁山泊を討伐しようとしています。'
        'どのように対応しますか？',
    type: EventType.historical,
    choices: [
      EventChoice(
        id: 'direct_battle',
        text: '正面から迎え撃つ',
        effects: [
          EventEffect(type: EventEffectType.troopsChange, value: -1000),
          EventEffect(type: EventEffectType.goldChange, value: 800),
        ],
        requirements: EventRequirements(
          requiredHeroes: ['song_jiang', 'lin_chong'],
        ),
      ),
      EventChoice(
        id: 'guerrilla_tactics',
        text: 'ゲリラ戦術で対応',
        effects: [
          EventEffect(type: EventEffectType.troopsChange, value: -500),
          EventEffect(type: EventEffectType.goldChange, value: 400),
        ],
        requirements: EventRequirements(
          requiredHeroes: ['wu_yong'],
        ),
      ),
      EventChoice(
        id: 'diplomatic_solution',
        text: '外交的解決を図る',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -600),
        ],
        requirements: EventRequirements(
          requiredHeroes: ['song_jiang'],
          minGold: 600,
        ),
      ),
    ],
    requirements: EventRequirements(
      minTurn: 8,
      controlledProvince: 'liangshan',
    ),
  );

  // === ランダムイベント ===

  /// 商人キャラバン
  static const GameEvent _merchantCaravan = GameEvent(
    id: 'merchant_caravan',
    title: '商人キャラバン',
    description: '裕福な商人のキャラバンが領内を通過しようとしています。',
    type: EventType.random,
    choices: [
      EventChoice(
        id: 'tax_collection',
        text: '通行税を徴収する',
        effects: [EventEffect.gainGold100],
      ),
      EventChoice(
        id: 'escort_service',
        text: '護衛サービスを提供する',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: 200),
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: 10,
          ),
        ],
        requirements: EventRequirements(minGold: 50),
      ),
      EventChoice(
        id: 'rob_caravan',
        text: 'キャラバンを襲う',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: 500),
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: -20,
          ),
        ],
      ),
      EventChoice(
        id: 'let_pass',
        text: 'そのまま通す',
        effects: [
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: 5,
          ),
        ],
      ),
    ],
    requirements: EventRequirements(minTurn: 2),
    isRepeatable: true,
  );

  /// 盗賊の襲撃
  static const GameEvent _banditsRaid = GameEvent(
    id: 'bandits_raid',
    title: '盗賊団の襲撃',
    description: '小規模な盗賊団が領内の村を襲撃しています。',
    type: EventType.random,
    choices: [
      EventChoice(
        id: 'fight_bandits',
        text: '盗賊団を討伐する',
        effects: [
          EventEffect(type: EventEffectType.troopsChange, value: -100),
          EventEffect(type: EventEffectType.goldChange, value: 150),
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: 15,
          ),
        ],
      ),
      EventChoice(
        id: 'recruit_bandits',
        text: '盗賊を仲間に勧誘する',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -200),
          EventEffect(type: EventEffectType.troopsChange, value: 300),
        ],
        requirements: EventRequirements(minGold: 200),
      ),
      EventChoice(
        id: 'ignore_raid',
        text: '見て見ぬふりをする',
        effects: [
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: -10,
          ),
        ],
      ),
    ],
    isRepeatable: true,
  );

  /// 豊作
  static const GameEvent _goodHarvest = GameEvent(
    id: 'good_harvest',
    title: '豊作の恵み',
    description: '今年は豊作で、民は喜んでいます。余剰分をどうしますか？',
    type: EventType.random,
    choices: [
      EventChoice(
        id: 'sell_surplus',
        text: '余剰分を売却する',
        effects: [EventEffect(type: EventEffectType.goldChange, value: 300)],
      ),
      EventChoice(
        id: 'store_grain',
        text: '備蓄として保管する',
        effects: [
          EventEffect(type: EventEffectType.troopsChange, value: 200),
        ],
      ),
      EventChoice(
        id: 'distribute_free',
        text: '貧しい人々に配布する',
        effects: [
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: 25,
          ),
        ],
      ),
    ],
    isRepeatable: true,
  );

  /// 学者の訪問
  static const GameEvent _scholarVisit = GameEvent(
    id: 'scholar_visit',
    title: '学者の来訪',
    description: '高名な学者が梁山泊を訪れ、義賊の理念について議論したいと申し出ています。',
    type: EventType.random,
    choices: [
      EventChoice(
        id: 'welcome_scholar',
        text: '歓迎して議論する',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -100),
          EventEffect(
            type: EventEffectType.loyaltyChange,
            value: 15,
          ),
        ],
        requirements: EventRequirements(minGold: 100),
      ),
      EventChoice(
        id: 'polite_decline',
        text: '丁重にお断りする',
        effects: [],
      ),
    ],
    requirements: EventRequirements(
      requiredHeroes: ['song_jiang'],
      minTurn: 5,
    ),
  );

  /// 謎の来訪者
  static const GameEvent _mysteriousStranger = GameEvent(
    id: 'mysterious_stranger',
    title: '謎の来訪者',
    description: '正体不明の武芸者が梁山泊に現れました。何か重要な情報を持っているようです。',
    type: EventType.random,
    choices: [
      EventChoice(
        id: 'listen_information',
        text: '情報を聞く（200両）',
        effects: [
          EventEffect(type: EventEffectType.goldChange, value: -200),
          EventEffect(type: EventEffectType.goldChange, value: 500), // 結果的に得
        ],
        requirements: EventRequirements(minGold: 200),
      ),
      EventChoice(
        id: 'challenge_stranger',
        text: '武芸で試す',
        effects: [
          EventEffect(type: EventEffectType.troopsChange, value: -50),
          EventEffect(type: EventEffectType.troopsChange, value: 300),
        ],
        requirements: EventRequirements(
          requiredHeroes: ['lin_chong'],
        ),
      ),
      EventChoice(
        id: 'send_away',
        text: '立ち去らせる',
        effects: [],
      ),
    ],
    requirements: EventRequirements(minTurn: 7),
  );

  /// イベントIDから取得
  static GameEvent? findById(String id) {
    try {
      return allEvents.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 発生可能なイベントを取得
  static List<GameEvent> getAvailableEvents(
    WaterMarginGameState gameState,
    Set<String> triggeredEvents,
  ) {
    return allEvents
        .where((event) => event.canTrigger(gameState, triggeredEvents))
        .toList();
  }

  /// ランダムイベントを1つ選択
  static GameEvent? getRandomEvent(
    WaterMarginGameState gameState,
    Set<String> triggeredEvents,
  ) {
    final availableEvents = getAvailableEvents(gameState, triggeredEvents);
    if (availableEvents.isEmpty) return null;

    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % availableEvents.length;
    return availableEvents[randomIndex];
  }
}
