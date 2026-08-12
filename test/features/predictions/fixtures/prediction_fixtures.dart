import 'package:global_ai_prediction/features/home/domain/entities/match_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/post_match_comparison_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/prediction_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/prediction_history_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/user_vote_entity.dart';

/// Shared test fixtures for the Predictions feature entities.

Odds buildOdds({
  double home = 2.1,
  double draw = 3.4,
  double away = 3.2,
}) {
  return Odds(home: home, draw: draw, away: away);
}

/// A prediction that predicts a home win with 2-1 correct score,
/// BTTS Yes, Over 2.5 goals, Over 9.5 corners, and Under 4.5 cards.
MatchPredictionEntity buildPrediction({
  int matchId = 1,
  String homeTeam = 'Home FC',
  String awayTeam = 'Away FC',
  double overallConfidence = 78.0,
  String predictedOutcome = 'home',
  bool bttsPrediction = true,
  bool overUnderPrediction = true,
  bool cornersPrediction = true,
  bool cardsPrediction = false,
  int predictedHome = 2,
  int predictedAway = 1,
}) {
  return MatchPredictionEntity(
    matchId: matchId,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    overallConfidence: overallConfidence,
    summary: 'Home FC expected to edge a tight contest.',
    matchWinner: MatchWinnerPrediction(
      confidence: overallConfidence,
      predictedOutcome: predictedOutcome,
      explanation: 'Home FC has stronger form.',
      odds: buildOdds(),
    ),
    doubleChance: DoubleChancePrediction(
      homeOrDraw: 0.72,
      homeOrAway: 0.81,
      drawOrAway: 0.55,
      explanation: 'Home double chance is the strongest market.',
    ),
    btts: BttsPrediction(
      yesConfidence: 0.62,
      noConfidence: 0.38,
      prediction: bttsPrediction,
      explanation: 'Both teams expected to score.',
    ),
    correctScore: CorrectScorePrediction(
      mostLikelyHome: predictedHome,
      mostLikelyAway: predictedAway,
      alternateScores: ['2-0', '1-1', '3-1'],
      confidence: 0.24,
      explanation: 'Most likely scoreline.',
    ),
    overUnder: OverUnderPrediction(
      under2_5: 0.41,
      over2_5: 0.59,
      prediction: overUnderPrediction,
      explanation: 'Goals expected.',
    ),
    cornersPrediction: CornersPrediction(
      under9_5: 0.45,
      over9_5: 0.55,
      prediction: cornersPrediction,
      explanation: 'Corners expected.',
    ),
    cardsPrediction: CardsPrediction(
      under4_5: 0.6,
      over4_5: 0.4,
      prediction: cardsPrediction,
      explanation: 'Cards expected.',
    ),
    playerProps: [
      PlayerProp(
        playerName: 'Star Striker',
        metric: 'Goals',
        predictedValue: 1.2,
        confidence: 0.7,
        explanation: 'Expected to be involved.',
      ),
    ],
    generatedAt: DateTime(2024, 1, 1, 12),
    matchDate: DateTime(2024, 1, 2),
  );
}

PredictionHistoryEntity buildHistory({
  String id = 'h1',
  int matchId = 1,
  PredictionStatus status = PredictionStatus.pending,
  bool? isCorrect,
}) {
  return PredictionHistoryEntity(
    id: id,
    matchId: matchId,
    homeTeam: 'Home FC',
    awayTeam: 'Away FC',
    prediction: buildPrediction(matchId: matchId),
    createdAt: DateTime(2024, 1, 1),
    matchDate: DateTime(2024, 1, 2),
    status: status,
    isCorrect: isCorrect,
  );
}

PostMatchComparisonEntity buildComparison({
  int matchId = 1,
  int actualHomeScore = 2,
  int actualAwayScore = 1,
  bool matchWinnerCorrect = true,
  bool doubleChanceCorrect = true,
  bool bttsCorrect = true,
  bool correctScoreCorrect = true,
  bool overUnderCorrect = true,
  bool? cornersCorrect = true,
  bool? cardsCorrect = true,
  int? correctPredictions,
  int? totalPredictions,
}) {
  final prediction = buildPrediction(matchId: matchId);
  final correct = correctPredictions ??
      [
        matchWinnerCorrect,
        doubleChanceCorrect,
        bttsCorrect,
        correctScoreCorrect,
        overUnderCorrect,
        if (cornersCorrect != null) cornersCorrect,
        if (cardsCorrect != null) cardsCorrect,
      ].where((b) => b).length;
  final total = totalPredictions ??
      5 +
          (cornersCorrect != null ? 1 : 0) +
          (cardsCorrect != null ? 1 : 0);
  final accuracy = total == 0 ? 0.0 : (correct / total) * 100;

  return PostMatchComparisonEntity(
    matchId: matchId,
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
    correctPredictions: correct,
    totalPredictions: total,
    overallAccuracy: accuracy,
    comparisonDate: DateTime(2024, 1, 3),
  );
}

VoteCountsEntity buildVoteCounts({
  int upvotes = 10,
  int downvotes = 2,
}) {
  return VoteCountsEntity(
    upvotes: upvotes,
    downvotes: downvotes,
    totalVotes: upvotes + downvotes,
  );
}

AccuracyStatsEntity buildAccuracyStats({
  int total = 10,
  int correct = 7,
  int incorrect = 2,
  int voided = 1,
}) {
  return AccuracyStatsEntity(
    totalPredictions: total,
    correctPredictions: correct,
    incorrectPredictions: incorrect,
    voidedPredictions: voided,
  );
}

/// Builds a fully loaded upcoming match entity for the prediction picker.
List<MatchEntity> buildPredictionUpcomingMatches() => [
      buildPredictionMatch(id: 20, homeName: 'Alpha FC', awayName: 'Beta FC'),
      buildPredictionMatch(id: 21, homeName: 'Gamma FC', awayName: 'Delta FC'),
    ];

MatchEntity buildPredictionMatch({
  int id = 20,
  String homeName = 'Alpha FC',
  String awayName = 'Beta FC',
}) {
  return MatchEntity(
    id: id,
    status: MatchStatus.scheduled,
    utcDate: DateTime(2024, 2, 1),
    homeTeam: TeamMini(id: id, name: homeName),
    awayTeam: TeamMini(id: id + 100, name: awayName),
    homeScore: null,
    awayScore: null,
    competitionName: 'Premier League',
  );
}
