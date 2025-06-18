/// エラー状態を表現する抽象クラス
abstract class Failure {
  const Failure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && runtimeType == other.runtimeType && message == other.message && code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => '$runtimeType: $message';
}

/// データ関連のエラー
class DataFailure extends Failure {
  const DataFailure(super.message, {super.code});
}

/// ネットワーク関連のエラー
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// ストレージ関連のエラー
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});
}

/// バリデーション関連のエラー
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// ゲーム関連のエラー
class GameFailure extends Failure {
  const GameFailure(super.message, {super.code});
}

/// 一般的なエラー
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '不明なエラーが発生しました']);
}
