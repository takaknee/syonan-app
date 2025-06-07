/// ビルド情報を管理するクラス
class BuildInfo {
  /// ビルド日時を取得
  static String getBuildDateTime() {
    // GitHub Actionsでビルド時に設定される環境変数から取得
    const buildTime = String.fromEnvironment(
      'BUILD_TIME',
    );

    if (buildTime.isEmpty) {
      // 開発環境では現在時刻を表示
      final now = DateTime.now();
      return '開発ビルド (${now.year}年${now.month}月${now.day}日 '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')})';
    }

    try {
      // ISO 8601形式からパース
      final dateTime = DateTime.parse(buildTime);
      // 日本時間に変換（UTC+9）
      final jstDateTime = dateTime.add(const Duration(hours: 9));
      return '${jstDateTime.year}年${jstDateTime.month}月${jstDateTime.day}日 '
          '${jstDateTime.hour.toString().padLeft(2, '0')}:'
          '${jstDateTime.minute.toString().padLeft(2, '0')} (JST)';
    } catch (e) {
      return buildTime;
    }
  }

  /// ビルド番号を取得
  static String getBuildNumber() {
    const buildNumber = String.fromEnvironment(
      'BUILD_NUMBER',
    );

    if (buildNumber.isEmpty) {
      return 'dev-${DateTime.now().millisecondsSinceEpoch}';
    }

    return buildNumber;
  }

  /// GitHubのコミットハッシュを取得
  static String getCommitHash() {
    const commitHash = String.fromEnvironment(
      'COMMIT_HASH',
    );

    if (commitHash.isEmpty) {
      return 'local-dev';
    }

    // ハッシュの最初の7文字を表示
    return commitHash.length > 7 ? commitHash.substring(0, 7) : commitHash;
  }

  /// デバッグ情報として全ての情報を取得
  static Map<String, String> getAllInfo() {
    return {
      'buildDateTime': getBuildDateTime(),
      'buildNumber': getBuildNumber(),
      'commitHash': getCommitHash(),
    };
  }
}
