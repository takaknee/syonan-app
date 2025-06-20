import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/math_problem.dart';
import '../services/score_service.dart';
import '../services/math_service.dart';
import '../widgets/problem_card.dart';
import 'practice_screen.dart';

/// AI先生画面
/// ユーザーの学習状況を分析し、個別指導を提供する
class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreService = context.watch<ScoreService>();
    final mathService = context.read<MathService>();

    // ユーザーの成績を分析
    final analysisResult = _analyzeUserPerformance(scoreService);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI先生'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(theme),
            const SizedBox(height: 24),
            _buildAnalysisSection(theme, analysisResult),
            const SizedBox(height: 24),
            _buildRecommendationsSection(theme, analysisResult),
            const SizedBox(height: 24),
            _buildPracticeSection(theme, analysisResult, mathService),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '🤖',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            'こんにちは！AI先生です',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'あなたの学習状況を分析して、\n最適な学習方法をアドバイスします！',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(ThemeData theme, _PerformanceAnalysis analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '学習状況分析',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalysisItem(
              theme,
              '総練習回数',
              '${analysis.totalPractices}回',
              Icons.fitness_center,
            ),
            _buildAnalysisItem(
              theme,
              '平均正答率',
              '${analysis.averageAccuracy}%',
              Icons.track_changes,
            ),
            _buildAnalysisItem(
              theme,
              '得意分野',
              analysis.strongSubject,
              Icons.star,
            ),
            _buildAnalysisItem(
              theme,
              '苦手分野',
              analysis.weakSubject,
              Icons.trending_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(
    ThemeData theme,
    _PerformanceAnalysis analysis,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI先生からのアドバイス',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...analysis.recommendations.map((recommendation) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeSection(
    ThemeData theme,
    _PerformanceAnalysis analysis,
    MathService mathService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_arrow,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'おすすめ練習',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'あなたにぴったりの練習問題を用意しました！',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeScreen(
                        operation: analysis.recommendedOperation,
                        difficultyLevel: analysis.recommendedDifficulty,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.school),
                label: Text('${analysis.recommendedOperationName}の練習を始める'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '推奨難易度: ${_getDifficultyName(analysis.recommendedDifficulty)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyName(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'やさしい';
      case 2:
        return 'ふつう';
      case 3:
        return 'むずかしい';
      case 4:
        return 'とてもむずかしい';
      case 5:
        return 'エキスパート';
      default:
        return 'ふつう';
    }
  }

  _PerformanceAnalysis _analyzeUserPerformance(ScoreService scoreService) {
    final allScores = scoreService.getAllScores();

    if (allScores.isEmpty) {
      return const _PerformanceAnalysis(
        totalPractices: 0,
        averageAccuracy: 0,
        strongSubject: '初回練習',
        weakSubject: '練習開始',
        recommendations: [
          '初めての練習を始めましょう！',
          'まずは掛け算から始めることをおすすめします',
          '間違いを恐れずに挑戦してください',
        ],
        recommendedOperation: MathOperationType.multiplication,
        recommendedOperationName: '掛け算',
        recommendedDifficulty: 1,
      );
    }

    // 各計算タイプの成績を計算
    final multiplicationScores =
        allScores.where((score) => score.operationType == MathOperationType.multiplication).toList();
    final divisionScores = allScores.where((score) => score.operationType == MathOperationType.division).toList();
    final additionScores = allScores.where((score) => score.operationType == MathOperationType.addition).toList();
    final subtractionScores = allScores.where((score) => score.operationType == MathOperationType.subtraction).toList();

    // 平均スコアを計算
    final multiplicationAvg = multiplicationScores.isEmpty
        ? 0.0
        : multiplicationScores.map((s) => s.score).reduce((a, b) => a + b) / multiplicationScores.length;
    final divisionAvg = divisionScores.isEmpty
        ? 0.0
        : divisionScores.map((s) => s.score).reduce((a, b) => a + b) / divisionScores.length;
    final additionAvg = additionScores.isEmpty
        ? 0.0
        : additionScores.map((s) => s.score).reduce((a, b) => a + b) / additionScores.length;
    final subtractionAvg = subtractionScores.isEmpty
        ? 0.0
        : subtractionScores.map((s) => s.score).reduce((a, b) => a + b) / subtractionScores.length;

    // 最も得意な分野と苦手な分野を判定
    final averages = {
      '掛け算': multiplicationAvg,
      '割り算': divisionAvg,
      '足し算': additionAvg,
      '引き算': subtractionAvg,
    };

    final sortedByScore = averages.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final strongSubject = sortedByScore.first.key;
    final weakSubject = sortedByScore.last.key;

    // 総合的な平均正答率
    final totalScore = allScores.map((s) => s.score).reduce((a, b) => a + b);
    final averageAccuracy = (totalScore / allScores.length).round();

    // おすすめの操作と難易度を決定
    MathOperationType recommendedOp;
    String recommendedOpName;
    int recommendedDifficulty;

    if (averageAccuracy < 60) {
      // 苦手分野を重点的に
      recommendedOp = _getOperationByName(weakSubject);
      recommendedOpName = weakSubject;
      recommendedDifficulty = 1; // やさしい
    } else if (averageAccuracy < 80) {
      recommendedOp = _getOperationByName(weakSubject);
      recommendedOpName = weakSubject;
      recommendedDifficulty = 2; // ふつう
    } else {
      // 得意分野でより高い難易度に挑戦
      recommendedOp = _getOperationByName(strongSubject);
      recommendedOpName = strongSubject;
      recommendedDifficulty = 3; // むずかしい
    }

    // アドバイスの生成
    final recommendations = _generateRecommendations(
      averageAccuracy,
      strongSubject,
      weakSubject,
      allScores.length,
    );

    return _PerformanceAnalysis(
      totalPractices: allScores.length,
      averageAccuracy: averageAccuracy,
      strongSubject: strongSubject,
      weakSubject: weakSubject,
      recommendations: recommendations,
      recommendedOperation: recommendedOp,
      recommendedOperationName: recommendedOpName,
      recommendedDifficulty: recommendedDifficulty,
    );
  }

  MathOperationType _getOperationByName(String name) {
    switch (name) {
      case '掛け算':
        return MathOperationType.multiplication;
      case '割り算':
        return MathOperationType.division;
      case '足し算':
        return MathOperationType.addition;
      case '引き算':
        return MathOperationType.subtraction;
      default:
        return MathOperationType.multiplication;
    }
  }

  List<String> _generateRecommendations(
    int averageAccuracy,
    String strongSubject,
    String weakSubject,
    int totalPractices,
  ) {
    final recommendations = <String>[];

    if (totalPractices < 5) {
      recommendations.add('まだ練習回数が少ないです。毎日少しずつ続けることが大切です！');
    } else if (totalPractices < 20) {
      recommendations.add('練習を続けて素晴らしいです！この調子で頑張りましょう。');
    } else {
      recommendations.add('たくさん練習していますね！継続は力なりです。');
    }

    if (averageAccuracy < 50) {
      recommendations.add('$weakSubjectの基礎をもう一度復習してみましょう。');
      recommendations.add('間違えても大丈夫！間違いから学ぶことが大切です。');
    } else if (averageAccuracy < 70) {
      recommendations.add('$weakSubjectをもう少し練習すると、さらに上達しますよ！');
      recommendations.add('$strongSubjectは得意なので、自信を持って続けてください。');
    } else if (averageAccuracy < 90) {
      recommendations.add('とても上手です！$weakSubjectも少し練習すれば完璧になりそうです。');
      recommendations.add('時々、より難しい問題にも挑戦してみてください。');
    } else {
      recommendations.add('素晴らしい成績です！全ての分野でとても上手にできています。');
      recommendations.add('さらに難しい問題や、制限時間を短くして挑戦してみましょう。');
    }

    recommendations.add('毎日短時間でも良いので、継続して練習することをおすすめします。');

    return recommendations;
  }
}

class _PerformanceAnalysis {
  const _PerformanceAnalysis({
    required this.totalPractices,
    required this.averageAccuracy,
    required this.strongSubject,
    required this.weakSubject,
    required this.recommendations,
    required this.recommendedOperation,
    required this.recommendedOperationName,
    required this.recommendedDifficulty,
  });

  final int totalPractices;
  final int averageAccuracy;
  final String strongSubject;
  final String weakSubject;
  final List<String> recommendations;
  final MathOperationType recommendedOperation;
  final String recommendedOperationName;
  final int recommendedDifficulty;
}
