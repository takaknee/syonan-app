/// 水滸伝の108星英雄データ
/// 主要な英雄のデータを定義（フェーズ1では代表的な英雄のみ）
library;

import '../models/water_margin_strategy_game.dart';

/// 水滸伝英雄データベース
class WaterMarginHeroes {
  /// 代表的な水滸伝英雄リスト（フェーズ1用）
  static List<Hero> get initialHeroes => [
        // 天罡星（主要な英雄たち）
        _songJiang,
        _luJunyi,
        _wuYong,
        _gongsunSheng,
        _linChong,
        _qinMing,
        _huYanzhuo,
        _huaShan,
        _chaiJin,
        _liYing,
        _zhiShen,
        _wuSong,
        _yangZhi,
        _xuNing,
        _suoChao,

        // 地煞星（一部）
        _liKui,
        _yanchun,
        _luda,
        _yanQing,
        _liJun,
      ];

  // === 天罡星（36星）の主要英雄 ===

  /// 1. 天魁星 及時雨 宋江
  static const Hero _songJiang = Hero(
    id: 'song_jiang',
    name: '宋江',
    nickname: '及時雨',
    stats: HeroStats(
      force: 25,
      intelligence: 85,
      charisma: 95,
      leadership: 95,
      loyalty: 100,
    ),
    skill: HeroSkill.diplomat,
    faction: Faction.liangshan,
    isRecruited: true, // 最初から仲間
  );

  /// 2. 天罡星 玉麒麟 盧俊義
  static const Hero _luJunyi = Hero(
    id: 'lu_junyi',
    name: '盧俊義',
    nickname: '玉麒麟',
    stats: HeroStats(
      force: 98,
      intelligence: 75,
      charisma: 80,
      leadership: 90,
      loyalty: 85,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 3. 天機星 智多星 呉用
  static const Hero _wuYong = Hero(
    id: 'wu_yong',
    name: '呉用',
    nickname: '智多星',
    stats: HeroStats(
      force: 15,
      intelligence: 98,
      charisma: 85,
      leadership: 80,
      loyalty: 95,
    ),
    skill: HeroSkill.strategist,
    faction: Faction.liangshan,
    isRecruited: true, // 最初から仲間
  );

  /// 4. 天閑星 入雲龍 公孫勝
  static const Hero _gongsunSheng = Hero(
    id: 'gongsun_sheng',
    name: '公孫勝',
    nickname: '入雲龍',
    stats: HeroStats(
      force: 70,
      intelligence: 90,
      charisma: 70,
      leadership: 75,
      loyalty: 80,
    ),
    skill: HeroSkill.strategist,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 5. 天雄星 豹子頭 林冲
  static const Hero _linChong = Hero(
    id: 'lin_chong',
    name: '林冲',
    nickname: '豹子頭',
    stats: HeroStats(
      force: 95,
      intelligence: 80,
      charisma: 75,
      leadership: 85,
      loyalty: 90,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true, // 最初から仲間
  );

  /// 6. 天猛星 霹靂火 秦明
  static const Hero _qinMing = Hero(
    id: 'qin_ming',
    name: '秦明',
    nickname: '霹靂火',
    stats: HeroStats(
      force: 90,
      intelligence: 60,
      charisma: 70,
      leadership: 80,
      loyalty: 85,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
  );

  /// 7. 天威星 双鞭 呼延灼
  static const Hero _huYanzhuo = Hero(
    id: 'hu_yanzhuo',
    name: '呼延灼',
    nickname: '双鞭',
    stats: HeroStats(
      force: 92,
      intelligence: 75,
      charisma: 80,
      leadership: 85,
      loyalty: 80,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
  );

  /// 8. 天英星 小李廣 花栄
  static const Hero _huaShan = Hero(
    id: 'hua_rong',
    name: '花栄',
    nickname: '小李廣',
    stats: HeroStats(
      force: 85,
      intelligence: 75,
      charisma: 85,
      leadership: 80,
      loyalty: 90,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 9. 天貴星 小旋風 柴進
  static const Hero _chaiJin = Hero(
    id: 'chai_jin',
    name: '柴進',
    nickname: '小旋風',
    stats: HeroStats(
      force: 50,
      intelligence: 85,
      charisma: 95,
      leadership: 80,
      loyalty: 85,
    ),
    skill: HeroSkill.diplomat,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 10. 天富星 撲天鵰 李應
  static const Hero _liYing = Hero(
    id: 'li_ying',
    name: '李應',
    nickname: '撲天鵰',
    stats: HeroStats(
      force: 80,
      intelligence: 80,
      charisma: 85,
      leadership: 85,
      loyalty: 85,
    ),
    skill: HeroSkill.administrator,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 13. 天孤星 花和尚 魯智深
  static const Hero _zhiShen = Hero(
    id: 'lu_zhishen',
    name: '魯智深',
    nickname: '花和尚',
    stats: HeroStats(
      force: 95,
      intelligence: 60,
      charisma: 80,
      leadership: 75,
      loyalty: 95,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true, // 最初から仲間
  );

  /// 14. 天傷星 行者 武松
  static const Hero _wuSong = Hero(
    id: 'wu_song',
    name: '武松',
    nickname: '行者',
    stats: HeroStats(
      force: 98,
      intelligence: 70,
      charisma: 75,
      leadership: 70,
      loyalty: 90,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 17. 天暗星 青面獣 楊志
  static const Hero _yangZhi = Hero(
    id: 'yang_zhi',
    name: '楊志',
    nickname: '青面獣',
    stats: HeroStats(
      force: 88,
      intelligence: 75,
      charisma: 60,
      leadership: 80,
      loyalty: 80,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
  );

  /// 18. 天祐星 金槍手 徐寧
  static const Hero _xuNing = Hero(
    id: 'xu_ning',
    name: '徐寧',
    nickname: '金槍手',
    stats: HeroStats(
      force: 85,
      intelligence: 80,
      charisma: 75,
      leadership: 85,
      loyalty: 85,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
  );

  /// 19. 天空星 急先鋒 索超
  static const Hero _suoChao = Hero(
    id: 'suo_chao',
    name: '索超',
    nickname: '急先鋒',
    stats: HeroStats(
      force: 90,
      intelligence: 55,
      charisma: 70,
      leadership: 75,
      loyalty: 85,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
  );

  // === 地煞星（72星）の一部 ===

  /// 地殺星 黑旋風 李逵
  static const Hero _liKui = Hero(
    id: 'li_kui',
    name: '李逵',
    nickname: '黑旋風',
    stats: HeroStats(
      force: 95,
      intelligence: 25,
      charisma: 40,
      leadership: 50,
      loyalty: 100,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true, // 最初から仲間
  );

  /// 地階星 神機軍師 朱武
  static const Hero _yanchun = Hero(
    id: 'yan_chun',
    name: '燕順',
    nickname: '錦毛虎',
    stats: HeroStats(
      force: 80,
      intelligence: 65,
      charisma: 70,
      leadership: 75,
      loyalty: 85,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.bandit,
    isRecruited: false,
  );

  /// 地勇星 病關索 楊雄
  static const Hero _luda = Hero(
    id: 'lu_da',
    name: '魯達',
    nickname: '鎮關西',
    stats: HeroStats(
      force: 85,
      intelligence: 50,
      charisma: 75,
      leadership: 70,
      loyalty: 90,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 地俊星 鐵面孔目 裴宣
  static const Hero _yanQing = Hero(
    id: 'yan_qing',
    name: '燕青',
    nickname: '浪子',
    stats: HeroStats(
      force: 75,
      intelligence: 85,
      charisma: 90,
      leadership: 70,
      loyalty: 95,
    ),
    skill: HeroSkill.scout,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 地雄星 井木犴 郝思文
  static const Hero _liJun = Hero(
    id: 'li_jun',
    name: '李俊',
    nickname: '混江龍',
    stats: HeroStats(
      force: 80,
      intelligence: 75,
      charisma: 80,
      leadership: 85,
      loyalty: 85,
    ),
    skill: HeroSkill.administrator,
    faction: Faction.neutral,
    isRecruited: false,
  );

  /// 名前から英雄を検索
  static Hero? findByName(String name) {
    try {
      return initialHeroes
          .firstWhere((hero) => hero.name == name || hero.nickname == name);
    } catch (e) {
      return null;
    }
  }

  /// 技能から英雄をフィルタ
  static List<Hero> getHeroesBySkill(HeroSkill skill) {
    return initialHeroes.where((hero) => hero.skill == skill).toList();
  }

  /// 勢力から英雄をフィルタ
  static List<Hero> getHeroesByFaction(Faction faction) {
    return initialHeroes.where((hero) => hero.faction == faction).toList();
  }

  /// 仲間になっている英雄のみ
  static List<Hero> get recruitedHeroes {
    return initialHeroes.where((hero) => hero.isRecruited).toList();
  }

  /// まだ仲間になっていない英雄のみ
  static List<Hero> get availableHeroes {
    return initialHeroes.where((hero) => !hero.isRecruited).toList();
  }
}
