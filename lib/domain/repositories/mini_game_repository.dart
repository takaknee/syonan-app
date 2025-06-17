import '../entities/mini_game_entity.dart';
import 'math_problem_repository.dart'; // Resultクラスを使用

/// ミニゲームリポジトリの抽象クラス
abstract class MiniGameRepository {
  /// 利用可能なすべてのミニゲームを取得
  Future<Result<List<MiniGameEntity>>> getAllMiniGames();

  /// IDでミニゲームを取得
  Future<Result<MiniGameEntity?>> getMiniGameById(String id);

  /// タイプ別のミニゲームを取得
  Future<Result<List<MiniGameEntity>>> getMiniGamesByType(MiniGameType type);

  /// ミニゲームスコアを保存
  Future<Result<void>> saveScore(MiniGameScoreEntity score);

  /// ミニゲームのすべてのスコアを取得
  Future<Result<List<MiniGameScoreEntity>>> getAllScores();

  /// ゲーム別のスコアを取得
  Future<Result<List<MiniGameScoreEntity>>> getScoresByGameId(String gameId);

  /// ゲームの最高スコアを取得
  Future<Result<int>> getBestScore(String gameId);

  /// ゲームのプレイ回数を取得
  Future<Result<int>> getPlayCount(String gameId);

  /// ゲームの平均スコアを取得
  Future<Result<double>> getAverageScore(String gameId);

  /// 最新のスコアを取得
  Future<Result<MiniGameScoreEntity?>> getLatestScore(String gameId);

  /// スコアを削除
  Future<Result<void>> deleteScore(String scoreId);

  /// ゲーム別のスコアをすべて削除
  Future<Result<void>> clearScoresByGameId(String gameId);

  /// すべてのスコアを削除
  Future<Result<void>> clearAllScores();

  /// ミニゲーム統計を取得
  Future<Result<Map<String, dynamic>>> getStatistics();
}
