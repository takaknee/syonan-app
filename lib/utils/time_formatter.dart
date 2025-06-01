/// 時間のフォーマットを行うユーティリティクラス
class TimeFormatter {
  /// 期間を「○分○秒」の形式でフォーマット
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }

  /// 期間を短縮形「○:○○」の形式でフォーマット
  static String formatDurationShort(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 日付を「○月○日」の形式でフォーマット
  static String formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  /// 日付時刻を「○月○日 ○:○○」の形式でフォーマット
  static String formatDateTime(DateTime date) {
    final formattedDate = formatDate(date);
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$formattedDate $hour:$minute';
  }

  /// 日付時刻を詳細形式「○年○月○日 ○:○○」でフォーマット
  static String formatDateTimeFull(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    return '${year}年${month}月${day}日 $hour:$minute';
  }

  /// 相対時間を表示（例：「3日前」「今日」）
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今日';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}週間前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}ヶ月前';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}年前';
    }
  }

  // Private constructor to prevent instantiation
  TimeFormatter._();
}