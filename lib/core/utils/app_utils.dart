/// 共通のユーティリティ関数を提供するクラス
class AppUtils {
  /// 数値を日本語の文字列に変換（例：1 → "一"）
  static String numberToJapanese(int number) {
    const Map<int, String> japaneseNumbers = {
      0: '零',
      1: '一',
      2: '二',
      3: '三',
      4: '四',
      5: '五',
      6: '六',
      7: '七',
      8: '八',
      9: '九',
      10: '十',
    };

    return japaneseNumbers[number] ?? number.toString();
  }

  /// 時間を読みやすい形式に変換
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}時間${minutes}分${seconds}秒';
    } else if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }

  /// パーセンテージを表示用に変換
  static String formatPercentage(double value) {
    return '${(value * 100).round()}%';
  }

  /// 大きな数値を読みやすい形式に変換
  static String formatNumber(int number) {
    if (number >= 10000) {
      final man = number ~/ 10000;
      final remainder = number % 10000;
      if (remainder == 0) {
        return '${man}万';
      } else if (remainder >= 1000) {
        return '${man}万${remainder ~/ 1000}千';
      } else {
        return '${man}万${remainder}';
      }
    } else if (number >= 1000) {
      return '${number ~/ 1000}千${number % 1000}';
    }
    return number.toString();
  }

  /// 日付を読みやすい形式に変換
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return '今日';
    } else if (difference == 1) {
      return '昨日';
    } else if (difference < 7) {
      return '${difference}日前';
    } else if (difference < 30) {
      return '${difference ~/ 7}週間前';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  /// リストを指定されたサイズでチャンクに分割
  static List<List<T>> chunk<T>(List<T> list, int chunkSize) {
    final List<List<T>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    return chunks;
  }

  /// 値が範囲内にあるかどうかを確認
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  /// 値を指定された範囲内にクランプ
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// 配列をシャッフル
  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }

  /// 配列から重複を除去
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  /// nullまたは空文字列かどうかを確認
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  /// 空白文字のみかどうかを確認
  static bool isNullOrWhitespace(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// デバッグモードかどうかを確認
  static bool get isDebugMode {
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }

  /// 安全に整数に変換
  static int? safeParseInt(String? value) {
    if (isNullOrEmpty(value)) return null;
    return int.tryParse(value!);
  }

  /// 安全に浮動小数点数に変換
  static double? safeParseDouble(String? value) {
    if (isNullOrEmpty(value)) return null;
    return double.tryParse(value!);
  }
}
