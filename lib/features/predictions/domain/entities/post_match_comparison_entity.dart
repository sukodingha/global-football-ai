import 'package:equatable/equatable.dart';

import 'prediction_entity.dart';

/// Result of comparing an AI prediction against the actual match result.
class PostMatchComparisonEntity extends Equatable {
  const PostMatchComparisonEntity({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.actualHomeScore,
    required this.actualAwayScore,
    required this.prediction,
    required this.matchWinnerCorrect,
    required this.doubleChanceCorrect,
    required this.bttsCorrect,
    required this.correctScoreCorrect,
    required this.overUnderCorrect,
    this.cornersCorrect,
    this.cardsCorrect,
    required this.correctPredictions,
    required this.totalPredictions,
    required this.overallAccuracy,
    required this.comparisonDate,
  });

  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final int actualHomeScore;
  final int actualAwayScore;
  final MatchPredictionEntity prediction;

  final bool matchWinnerCorrect;
  final bool doubleChanceCorrect;
  final bool bttsCorrect;
  final bool correctScoreCorrect;
  final bool overUnderCorrect;
  final bool? cornersCorrect;
  final bool? cardsCorrect;

  final int correctPredictions;
  final int totalPredictions;

  /// Overall accuracy percentage 0-100.
  final double overallAccuracy;

  final DateTime comparisonDate;

  /// Text description of the comparison result.
  String get summary {
    return 'AI got $correctPredictions of $totalPredictions predictions correct '
        '(${overallAccuracy.toStringAsFixed(1)}% accuracy).';
  }

  @override
  List<Object?> get props => [
        matchId,
        homeTeam,
        awayTeam,
        actualHomeScore,
        actualAwayScore,
        prediction,
        matchWinnerCorrect,
        doubleChanceCorrect,
        bttsCorrect,
        correctScoreCorrect,
        overUnderCorrect,
        cornersCorrect,
        cardsCorrect,
        correctPredictions,
        totalPredictions,
        overallAccuracy,
        comparisonDate,
      ];
}
