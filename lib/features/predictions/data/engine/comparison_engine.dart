import '../../domain/entities/post_match_comparison_entity.dart';
import '../../domain/entities/prediction_entity.dart';

/// Compares an AI prediction against the actual match result.
///
/// Each sub-market is evaluated independently and flagged as correct or
/// incorrect. The overall accuracy is the fraction of correct markets.
///
/// Corners and cards markets are evaluated only when the corresponding
/// actual data is supplied (`actualCorners`, `actualCards`). When absent,
/// they are excluded from the running total.
class ComparisonEngine {
  const ComparisonEngine();

  /// Compares [prediction] against the actual [actualHomeScore] and
  /// [actualAwayScore] and returns a detailed breakdown.
  ///
  /// [actualCorners] and [actualCards] are optional; when either is given
  /// the corresponding market is evaluated against the actual totals.
  PostMatchComparisonEntity compare({
    required MatchPredictionEntity prediction,
    required int actualHomeScore,
    required int actualAwayScore,
    int? actualCorners,
    int? actualCards,
  }) {
    // Determine the actual winner.
    final actualOutcome = _outcomeOf(actualHomeScore, actualAwayScore);

    // 1. Match winner.
    final matchWinnerCorrect = prediction.matchWinner != null &&
        _winnerMatches(prediction.matchWinner!.predictedOutcome, actualOutcome);

    // 2. Double chance.
    final doubleChanceCorrect = prediction.doubleChance != null &&
        _doubleChanceMatches(
          prediction.doubleChance!.homeOrDraw,
          prediction.doubleChance!.homeOrAway,
          prediction.doubleChance!.drawOrAway,
          actualOutcome,
        );

    // 3. BTTS.
    final bttsCorrect = prediction.btts != null &&
        _bttsMatches(
          prediction.btts!.prediction,
          actualHomeScore,
          actualAwayScore,
        );

    // 4. Correct score.
    final correctScoreCorrect = prediction.correctScore != null &&
        prediction.correctScore!.mostLikelyHome == actualHomeScore &&
        prediction.correctScore!.mostLikelyAway == actualAwayScore;

    // 5. Over/Under 2.5 goals.
    final overUnderCorrect = prediction.overUnder != null &&
        _overUnderMatches(
          prediction.overUnder!.prediction,
          actualHomeScore + actualAwayScore,
        );

    // 6. Corners (evaluated only when actual corners are supplied).
    final bool? cornersCorrect;
    if (prediction.cornersPrediction != null && actualCorners != null) {
      cornersCorrect = prediction.cornersPrediction!.prediction
          ? actualCorners > 9
          : actualCorners <= 9;
    } else {
      cornersCorrect = null;
    }

    // 7. Cards (evaluated only when actual cards are supplied).
    final bool? cardsCorrect;
    if (prediction.cardsPrediction != null && actualCards != null) {
      cardsCorrect = prediction.cardsPrediction!.prediction
          ? actualCards > 4
          : actualCards <= 4;
    } else {
      cardsCorrect = null;
    }

    // Count only the markets that were evaluated.
    final evaluated = <bool>[
      matchWinnerCorrect,
      doubleChanceCorrect,
      bttsCorrect,
      correctScoreCorrect,
      overUnderCorrect,
      if (cornersCorrect != null) cornersCorrect,
      if (cardsCorrect != null) cardsCorrect,
    ];
    final correctCount = evaluated.where((b) => b).length;
    final totalCount = evaluated.length;
    final accuracy = totalCount == 0 ? 0.0 : (correctCount / totalCount) * 100;

    return PostMatchComparisonEntity(
      matchId: prediction.matchId,
      homeTeam: prediction.homeTeam,
      awayTeam: prediction.awayTeam,
      actualHomeScore: actualHomeScore,
      actualAwayScore: actualAwayScore,
      prediction: prediction,
      matchWinnerCorrect: matchWinnerCorrect,
      doubleChanceCorrect: doubleChanceCorrect,
      bttsCorrect: bttsCorrect,
      correctScoreCorrect: correctScoreCorrect,
      overUnderCorrect: overUnderCorrect,
      cornersCorrect: cornersCorrect,
      cardsCorrect: cardsCorrect,
      correctPredictions: correctCount,
      totalPredictions: totalCount,
      overallAccuracy: accuracy,
      comparisonDate: DateTime.now(),
    );
  }

  String _outcomeOf(int home, int away) {
    if (home > away) return 'home';
    if (away > home) return 'away';
    return 'draw';
  }

  bool _winnerMatches(String predicted, String actual) {
    return predicted == actual;
  }

  bool _doubleChanceMatches(
    double homeOrDraw,
    double homeOrAway,
    double drawOrAway,
    String actual,
  ) {
    // The AI's top double-chance market is the one with the highest
    // probability. It is considered correct if it covers the actual outcome.
    final topMarket = _topDoubleChance(homeOrDraw, homeOrAway, drawOrAway);
    return topMarket.contains(actualOutcomeLetter(actual));
  }

  String _topDoubleChance(
    double homeOrDraw,
    double homeOrAway,
    double drawOrAway,
  ) {
    if (homeOrDraw >= homeOrAway && homeOrDraw >= drawOrAway) return '1X';
    if (homeOrAway >= homeOrDraw && homeOrAway >= drawOrAway) return '12';
    return 'X2';
  }

  String actualOutcomeLetter(String outcome) {
    switch (outcome) {
      case 'home':
        return '1';
      case 'away':
        return '2';
      default:
        return 'X';
    }
  }

  bool _bttsMatches(bool predictedYes, int home, int away) {
    final bothScored = home > 0 && away > 0;
    return predictedYes == bothScored;
  }

  bool _overUnderMatches(bool predictedOver, int totalGoals) {
    final over = totalGoals > 2;
    return predictedOver == over;
  }
}
