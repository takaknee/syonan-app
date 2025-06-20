/// ビルド情報を管理するクラス
class BuildInfo {
  // アプリ起動時に一度だけ設定されるビルド時刻
  static final DateTime _buildTime = DateTime.now();

  /// ビルド日時を取得
  static String getBuildDateTime() {
    // GitHub Actionsでビルド時に設定される環境変数から取得
    const buildTime = String.fromEnvironment(
      'BUILD_TIME',
    );

    if (buildTime.isEmpty) {
      // コンパイル時に設定される環境変数から取得
      const compiledTime = String.fromEnvironment(
        'COMPILED_TIME',
      );

      if (compiledTime.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(compiledTime);
          final jstDateTime = dateTime.add(const Duration(hours: 9));
          return '開発ビルド (${jstDateTime.year}年${jstDateTime.month}月${jstDateTime.day}日 '
              '${jstDateTime.hour.toString().padLeft(2, '0')}:'
              '${jstDateTime.minute.toString().padLeft(2, '0')})';
        } catch (e) {
          // パースエラーの場合は固定時刻を使用
        }
      }

      // 環境変数が設定されていない場合は、アプリ起動時の時刻を使用
      return '開発ビルド (${_buildTime.year}年${_buildTime.month}月${_buildTime.day}日 '
          '${_buildTime.hour.toString().padLeft(2, '0')}:'
          '${_buildTime.minute.toString().padLeft(2, '0')})';
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
