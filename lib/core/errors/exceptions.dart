/// アプリケーション内で使用する例外の基底クラス
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() => 'AppException: $message';
}

/// データ関連の例外
class DataException extends AppException {
  const DataException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'DataException: $message';
}

/// ネットワーク関連の例外
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// バリデーション関連の例外
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// ストレージ関連の例外
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'StorageException: $message';
}

/// ゲーム関連の例外
class GameException extends AppException {
  const GameException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'GameException: $message';
}

/// よく使用される例外のファクトリ
class AppExceptions {
  static DataException dataNotFound([String? message]) {
    return DataException(
      message: message ?? 'データが見つかりません',
      code: 'DATA_NOT_FOUND',
    );
  }

  static DataException dataParseError([String? message]) {
    return DataException(
      message: message ?? 'データの解析に失敗しました',
      code: 'DATA_PARSE_ERROR',
    );
  }

  static StorageException storageError([String? message]) {
    return StorageException(
      message: message ?? 'データの保存・読み込みに失敗しました',
      code: 'STORAGE_ERROR',
    );
  }

  static NetworkException networkError([String? message]) {
    return NetworkException(
      message: message ?? 'ネットワークエラーが発生しました',
      code: 'NETWORK_ERROR',
    );
  }

  static ValidationException invalidInput([String? message]) {
    return ValidationException(
      message: message ?? '入力値が無効です',
      code: 'INVALID_INPUT',
    );
  }

  static GameException gameStateError([String? message]) {
    return GameException(
      message: message ?? 'ゲームの状態が不正です',
      code: 'GAME_STATE_ERROR',
    );
  }
}
