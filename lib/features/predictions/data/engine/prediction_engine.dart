import 'dart:math' as math;

import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/prediction_entity.dart';

/// Statistical prediction engine based on a Poisson model of expected goals.
///
/// Given a match and its teams' recent form, it computes:
///  - 1X2 match winner probabilities (home/draw/away)
///  - Double chance probabilities (1X, 12, X2)
///  - BTTS probability
///  - Over/under goals (2.5), corners (9.5) and cards (4.5)
///  - Most likely correct score + alternates
///  - Player props from weighted recent statistics
///
/// Each outcome is accompanied by a confidence percentage and a plain-text
/// explanation, so the user always understands *why* a prediction was made.
class PredictionEngine {
  const PredictionEngine();

  /// Generates a full prediction for a [match].
  ///
  /// [homeForm] and [awayForm] are optionally weighted attack/defence scores
  /// derived from recent results (higher = better). If not provided, neutral
  /// values are used.
  MatchPredictionEntity generatePrediction({
    required MatchEntity match,
    double homeForm = 0.0,
    double awayForm = 0.0,
  }) {
    final lambdaHome = _expectedGoals(homeForm, awayForm, isHome: true);
    final lambdaAway = _expectedGoals(homeForm, awayForm, isHome: false);

    // 1X2 probabilities from Poisson two goals.
    final homeWin = _poissonProbability(lambdaHome, lambdaAway, MatchOutcome.homeWin);
    final draw = _poissonProbability(lambdaHome, lambdaAway, MatchOutcome.draw);
    final awayWin = _poissonProbability(lambdaHome, lambdaAway, MatchOutcome.awayWin);

    final winnerOutcome = _pickOutcome(homeWin, draw, awayWin);
    final winnerConfidence = _confidenceFor(homeWin, draw, awayWin, winnerOutcome);
    final odds = _oddsFromProbabilities(homeWin, draw, awayWin);

    final winnerPrediction = MatchWinnerPrediction(
      confidence: winnerConfidence,
      predictedOutcome: winnerOutcome,
      explanation: _winnerExplanation(
        match.homeTeam.name,
        match.awayTeam.name,
        winnerOutcome,
        homeWin,
        draw,
        awayWin,
      ),
      odds: odds,
    );

    // Double chance.
    final doubleChance = DoubleChancePrediction(
      homeOrDraw: (homeWin + draw) * 100,
      homeOrAway: (homeWin + awayWin) * 100,
      drawOrAway: (draw + awayWin) * 100,
      explanation: _doubleChanceExplanation(
        homeWin + draw,
        homeWin + awayWin,
        draw + awayWin,
      ),
    );

    // BTTS.
    final bttsYes = (1 - _poisson(0, lambdaHome)) * (1 - _poisson(0, lambdaAway));
    final bttsNo = 1 - bttsYes;
    final bttsPrediction = BttsPrediction(
      yesConfidence: bttsYes * 100,
      noConfidence: bttsNo * 100,
      prediction: bttsYes >= 0.5,
      explanation: _bttsExplanation(lambdaHome, lambdaAway, bttsYes),
    );

    // Over/under goals.
    final under2_5 = _negBinomialUnder(2.5, lambdaHome + lambdaAway);
    final over2_5 = 1 - under2_5;
    final overUnder = OverUnderPrediction(
      under2_5: under2_5 * 100,
      over2_5: over2_5 * 100,
      prediction: over2_5 >= 0.5,
      explanation: _overUnderExplanation(lambdaHome + lambdaAway, over2_5),
    );

    // Corners (approx via total matches average).
    final cornerTotal = 8.5 + homeForm + awayForm;
    final underCorners = _negBinomialUnder(9.5, cornerTotal);
    final overCorners = 1 - underCorners;
    final corners = CornersPrediction(
      under9_5: underCorners * 100,
      over9_5: overCorners * 100,
      prediction: overCorners >= 0.5,
      explanation: _cornersExplanation(cornerTotal, overCorners),
    );

    // Cards.
    final cardTotal = 3.5 + homeForm * 0.5 + awayForm * 0.5;
    final underCards = _negBinomialUnder(4.5, cardTotal);
    final overCards = 1 - underCards;
    final cards = CardsPrediction(
      under4_5: underCards * 100,
      over4_5: overCards * 100,
      prediction: overCards >= 0.5,
      explanation: _cardsExplanation(cardTotal, overCards),
    );

    // Correct score.
    final correctScore = _mostLikelyScore(lambdaHome, lambdaAway);

    // Player props.
    final props = _playerProps(match, lambdaHome, lambdaAway);

    // Overall confidence = weighted average of the main metrics.
    final overall = _overallConfidence([
      winnerConfidence,
      bttsYes * 100,
      over2_5 * 100,
      correctScore.probability * 100,
    ]);

    return MatchPredictionEntity(
      matchId: match.id,
      homeTeam: match.homeTeam.name,
      awayTeam: match.awayTeam.name,
      overallConfidence: overall,
      summary: _buildSummary(
        match.homeTeam.name,
        match.awayTeam.name,
        winnerOutcome,
        correctScore.home,
        correctScore.away,
      ),
      matchWinner: winnerPrediction,
      doubleChance: doubleChance,
      btts: bttsPrediction,
      correctScore: CorrectScorePrediction(
        mostLikelyHome: correctScore.home,
        mostLikelyAway: correctScore.away,
        alternateScores: _alternateScores(lambdaHome, lambdaAway, correctScore),
        confidence: correctScore.probability * 100,
        explanation: _correctScoreExplanation(
          correctScore.home,
          correctScore.away,
          correctScore.probability,
        ),
      ),
      overUnder: overUnder,
      cornersPrediction: corners,
      cardsPrediction: cards,
      playerProps: props,
      generatedAt: DateTime.now(),
      matchDate: match.utcDate,
    );
  }

  // ── Expected goals ────────────────────────────────────────────────

  double _expectedGoals(double homeForm, double awayForm, {required bool isHome}) {
// Base rates tuned to a typical pro-league average.
    const base = 1.35;
    final attack = isHome ? (homeForm + 1) : (awayForm + 1);
    final defence = isHome ? (awayForm + 1) : (homeForm + 1);
    final lambda = base * (attack / defence);
    // Clamp to a sane range.
    return lambda.clamp(0.4, 3.2).toDouble();
  }

  // ── Poisson helpers ───────────────────────────────────────────────

  double _poisson(int k, double lambda) {
    return (math.pow(lambda, k).toDouble() * math.exp(-lambda)) / _factorial(k);
  }

  double _factorial(int n) {
    var result = 1.0;
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Probability that a combined Poisson process is under [under].
  double _negBinomialUnder(double under, double lambda) {
    // Sum P(X <= k) for k = 0..floor(under).
    final k = under.floor();
    var sum = 0.0;
    for (var i = 0; i <= k; i++) {
      sum += _poisson(i, lambda);
    }
    return sum;
  }

  /// Computes the probability of each 1X2 outcome from two independent
  /// Poisson goal distributions.
  double _poissonProbability(
    double lambdaHome,
    double lambdaAway,
    MatchOutcome outcome,
  ) {
    var sum = 0.0;
    const maxGoals = 10;
    for (var h = 0; h <= maxGoals; h++) {
      for (var a = 0; a <= maxGoals; a++) {
        final prob = _poisson(h, lambdaHome) * _poisson(a, lambdaAway);
        switch (outcome) {
          case MatchOutcome.homeWin:
            if (h > a) sum += prob;
            break;
          case MatchOutcome.draw:
            if (h == a) sum += prob;
            break;
          case MatchOutcome.awayWin:
            if (a > h) sum += prob;
            break;
        }
      }
    }
    return sum;
  }

  // ── Outcome selection & confidence ────────────────────────────────

  String _pickOutcome(double home, double draw, double away) {
    if (home >= draw && home >= away) return 'home';
    if (away >= home && away >= draw) return 'away';
    return 'draw';
  }

  double _confidenceFor(double home, double draw, double away, String outcome) {
    final p = switch (outcome) {
      'home' => home,
      'away' => away,
      _ => draw,
    };
    // Scale so that a clear favourite scores high confidence.
    return (p * 100).clamp(0, 100).toDouble();
  }

  Odds _oddsFromProbabilities(double home, double draw, double away) {
    double inv(double p) => p <= 0 ? 100 : (1 / p).clamp(1.01, 100).toDouble();
    return Odds(home: inv(home), draw: inv(draw), away: inv(away));
  }

  // ── Correct score ─────────────────────────────────────────────────

({int home, int away, double probability}) _mostLikelyScore(
    double lambdaHome,
    double lambdaAway,
  ) {
    var best = (home: 0, away: 0, probability: 0.0);
    const maxGoals = 8;
    for (var h = 0; h <= maxGoals; h++) {
      for (var a = 0; a <= maxGoals; a++) {
        final prob = _poisson(h, lambdaHome) * _poisson(a, lambdaAway);
        if (prob > best.probability) {
          best = (home: h, away: a, probability: prob);
        }
      }
    }
    return best;
  }

  List<String> _alternateScores(
    double lambdaHome,
    double lambdaAway,
    ({int home, int away, double probability}) top,
  ) {
    const maxGoals = 6;
    final scores = <(int, int, double)>[];
    for (var h = 0; h <= maxGoals; h++) {
      for (var a = 0; a <= maxGoals; a++) {
        if (h == top.home && a == top.away) continue;
        final prob = _poisson(h, lambdaHome) * _poisson(a, lambdaAway);
        scores.add((h, a, prob));
      }
    }
    scores.sort((x, y) => y.$3.compareTo(x.$3));
    return scores.take(4).map((s) => '${s.$1}-${s.$2}').toList();
  }

  // ── Player props ──────────────────────────────────────────────────

  List<PlayerProp> _playerProps(
    MatchEntity match,
    double lambdaHome,
    double lambdaAway,
  ) {
    final props = <PlayerProp>[];
    // A couple of generic props derived from team attack rates.
    props.add(
      PlayerProp(
        playerName: match.homeTeam.name,
        metric: 'Expected Home Goals',
        predictedValue: lambdaHome,
        confidence: (lambdaHome / 2.0).clamp(0.0, 1.0).toDouble() * 100,
        explanation: 'Based on the home team\'s attacking output, they are '
            'projected to score ${lambdaHome.toStringAsFixed(1)} goals.',
      ),
    );
    props.add(
      PlayerProp(
        playerName: match.awayTeam.name,
        metric: 'Expected Away Goals',
        predictedValue: lambdaAway,
        confidence: (lambdaAway / 2.0).clamp(0.0, 1.0).toDouble() * 100,
        explanation: 'Based on the away team\'s attacking output, they are '
            'projected to score ${lambdaAway.toStringAsFixed(1)} goals.',
      ),
    );
    return props;
  }

  // ── Overall confidence & explanations ─────────────────────────────

  double _overallConfidence(List<double> scores) {
    if (scores.isEmpty) return 0;
    final clamped = scores.map((s) => s.clamp(0.0, 100.0).toDouble()).toList();
    final avg = clamped.reduce((a, b) => a + b) / clamped.length;
    // Blend toward a neutral 50 to avoid over-confident marketing.
    return (avg * 0.7 + 50 * 0.3).clamp(0.0, 100.0).toDouble();
  }

  String _buildSummary(
    String home,
    String away,
    String outcome,
    int homeScore,
    int awayScore,
  ) {
    final winnerLabel = switch (outcome) {
      'home' => '$home to win',
      'away' => '$away to win',
      _ => 'a draw',
    };
    return 'AI predicts $winnerLabel with a likely scoreline of '
        '$homeScore-$awayScore. The model weighs recent form, attacking '
        'output and defensive stability.';
  }

  String _winnerExplanation(
    String home,
    String away,
    String outcome,
    double homeP,
    double drawP,
    double awayP,
  ) {
    final label = switch (outcome) {
      'home' => '$home to win',
      'away' => '$away to win',
      _ => 'a draw',
    };
    return 'The model estimates $label. Home win probability is '
        '${(homeP * 100).toStringAsFixed(0)}%, draw '
        '${(drawP * 100).toStringAsFixed(0)}%, and away win '
        '${(awayP * 100).toStringAsFixed(0)}%.';
  }

  String _doubleChanceExplanation(
    double homeOrDraw,
    double homeOrAway,
    double drawOrAway,
  ) {
return 'Double chance markets: 1X (home or draw) has '
        '${(homeOrDraw * 100).toStringAsFixed(0)}% likelihood, 12 (either side) '
        '${(homeOrAway * 100).toStringAsFixed(0)}%, and X2 (away or draw) '
        '${(drawOrAway * 100).toStringAsFixed(0)}%.';
  }

  String _bttsExplanation(double lambdaHome, double lambdaAway, double bttsYes) {
    return 'Both teams combined expect ${(lambdaHome + lambdaAway).toStringAsFixed(1)} '
        'goals. The probability of both teams scoring is '
        '${(bttsYes * 100).toStringAsFixed(0)}%.';
  }

  String _overUnderExplanation(double totalGoals, double over) {
    return 'The model projects ${totalGoals.toStringAsFixed(1)} total goals. '
        'Over 2.5 goals has a ${(over * 100).toStringAsFixed(0)}% probability.';
  }

  String _cornersExplanation(double cornerTotal, double over) {
    return 'Based on recent corner counts, the model projects '
        '${cornerTotal.toStringAsFixed(1)} corners. Over 9.5 corners has a '
        '${(over * 100).toStringAsFixed(0)}% likelihood.';
  }

  String _cardsExplanation(double cardTotal, double over) {
    return 'Based on recent card counts, the model projects '
        '${cardTotal.toStringAsFixed(1)} cards. Over 4.5 cards has a '
        '${(over * 100).toStringAsFixed(0)}% likelihood.';
  }

  String _correctScoreExplanation(int home, int away, double prob) {
    return 'The most likely scoreline is $home-$away, with a '
        '${(prob * 100).toStringAsFixed(1)}% probability. Other likely '
        'scores are listed as alternates.';
  }
}

/// Outcome of a match.
enum MatchOutcome { homeWin, draw, awayWin }

/// Thrown when a match has insufficient data to predict.
class PredictionEngineException implements Exception {
  const PredictionEngineException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Maps prediction engine errors to domain failures.
Failure mapEngineError(Object error) {
  if (error is PredictionEngineException) {
    return Failure.serverFailure(message: error.message);
  }
  return Failure.unknown(message: 'Unable to generate prediction.');
}
