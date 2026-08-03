import 'package:equatable/equatable.dart';

/// Odds for a prediction outcome.
class Odds extends Equatable {
  const Odds({
    required this.home,
    required this.draw,
    required this.away,
  });

  final double home;
  final double draw;
  final double away;

  @override
  List<Object?> get props => [home, draw, away];
}

/// Match winner prediction (1X2).
class MatchWinnerPrediction extends Equatable {
  const MatchWinnerPrediction({
    required this.confidence,
    required this.predictedOutcome,
    required this.explanation,
    this.odds,
  });

  /// Confidence percentage 0-100.
  final double confidence;

  /// 'home' | 'draw' | 'away'
  final String predictedOutcome;

  /// Human-readable explanation.
  final String explanation;
  final Odds? odds;

  @override
  List<Object?> get props => [confidence, predictedOutcome, explanation, odds];
}

/// Double Chance prediction (1X, 12, X2).
class DoubleChancePrediction extends Equatable {
  const DoubleChancePrediction({
    required this.homeOrDraw,
    required this.homeOrAway,
    required this.drawOrAway,
    required this.explanation,
  });

  final double homeOrDraw; // 1X
  final double homeOrAway; // 12
  final double drawOrAway; // X2
  final String explanation;

  @override
  List<Object?> get props => [homeOrDraw, homeOrAway, drawOrAway, explanation];
}

/// Both Teams to Score (BTTS) prediction.
class BttsPrediction extends Equatable {
  const BttsPrediction({
    required this.yesConfidence,
    required this.noConfidence,
    required this.prediction,
    required this.explanation,
  });

  final double yesConfidence;
  final double noConfidence;

  /// true = BTTS Yes, false = BTTS No.
  final bool prediction;
  final String explanation;

  @override
  List<Object?> get props =>
      [yesConfidence, noConfidence, prediction, explanation];
}

/// Correct Score likelihood mapping.
class CorrectScorePrediction extends Equatable {
  const CorrectScorePrediction({
    required this.mostLikelyHome,
    required this.mostLikelyAway,
    required this.alternateScores,
    required this.confidence,
    required this.explanation,
  });

  final int mostLikelyHome;
  final int mostLikelyAway;
  final List<String> alternateScores; // e.g. ["2-1", "2-0", "1-1"]
  final double confidence;
  final String explanation;

  @override
  List<Object?> get props =>
      [mostLikelyHome, mostLikelyAway, alternateScores, confidence, explanation];
}

/// Over/Under goals prediction.
class OverUnderPrediction extends Equatable {
  const OverUnderPrediction({
    required this.under2_5,
    required this.over2_5,
    required this.prediction,
    required this.explanation,
  });

  final double under2_5;
  final double over2_5;

  /// true = Over 2.5, false = Under 2.5.
  final bool prediction;
  final String explanation;

  @override
  List<Object?> get props => [under2_5, over2_5, prediction, explanation];
}

/// Over/Under corners prediction.
class CornersPrediction extends Equatable {
  const CornersPrediction({
    required this.under9_5,
    required this.over9_5,
    required this.prediction,
    required this.explanation,
  });

  final double under9_5;
  final double over9_5;

  /// true = Over 9.5, false = Under 9.5.
  final bool prediction;
  final String explanation;

  @override
  List<Object?> get props => [under9_5, over9_5, prediction, explanation];
}

/// Over/Under cards prediction.
class CardsPrediction extends Equatable {
  const CardsPrediction({
    required this.under4_5,
    required this.over4_5,
    required this.prediction,
    required this.explanation,
  });

  final double under4_5;
  final double over4_5;

  /// true = Over 4.5, false = Under 4.5.
  final bool prediction;
  final String explanation;

  @override
  List<Object?> get props => [under4_5, over4_5, prediction, explanation];
}

/// Player prop metric.
class PlayerProp extends Equatable {
  const PlayerProp({
    required this.playerName,
    required this.metric,
    required this.predictedValue,
    required this.confidence,
    required this.explanation,
  });

  final String playerName;
  final String metric; // e.g. "Goals", "Assists", "Shots on Target"
  final double predictedValue;
  final double confidence;
  final String explanation;

  @override
  List<Object?> get props =>
      [playerName, metric, predictedValue, confidence, explanation];
}

/// Top-level prediction for a single match, containing all breakdowns.
class MatchPredictionEntity extends Equatable {
  const MatchPredictionEntity({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.overallConfidence,
    required this.summary,
    this.matchWinner,
    this.doubleChance,
    this.btts,
    this.correctScore,
    this.overUnder,
    this.cornersPrediction,
    this.cardsPrediction,
    this.playerProps = const [],
    this.generatedAt,
    this.matchDate,
  });

  final int matchId;
  final String homeTeam;
  final String awayTeam;

  /// Overall confidence rating 0-100.
  final double overallConfidence;

  /// Short textual summary.
  final String summary;

  final MatchWinnerPrediction? matchWinner;
  final DoubleChancePrediction? doubleChance;
  final BttsPrediction? btts;
  final CorrectScorePrediction? correctScore;
  final OverUnderPrediction? overUnder;
  final CornersPrediction? cornersPrediction;
  final CardsPrediction? cardsPrediction;
  final List<PlayerProp> playerProps;
  final DateTime? generatedAt;
  final DateTime? matchDate;

  @override
  List<Object?> get props => [
        matchId,
        homeTeam,
        awayTeam,
        overallConfidence,
        summary,
        matchWinner,
        doubleChance,
        btts,
        correctScore,
        overUnder,
        cornersPrediction,
        cardsPrediction,
        playerProps,
        generatedAt,
        matchDate,
      ];

  MatchPredictionEntity copyWith({
    int? matchId,
    String? homeTeam,
    String? awayTeam,
    double? overallConfidence,
    String? summary,
    MatchWinnerPrediction? matchWinner,
    DoubleChancePrediction? doubleChance,
    BttsPrediction? btts,
    CorrectScorePrediction? correctScore,
    OverUnderPrediction? overUnder,
    CornersPrediction? cornersPrediction,
    CardsPrediction? cardsPrediction,
    List<PlayerProp>? playerProps,
    DateTime? generatedAt,
    DateTime? matchDate,
  }) {
    return MatchPredictionEntity(
      matchId: matchId ?? this.matchId,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      summary: summary ?? this.summary,
      matchWinner: matchWinner ?? this.matchWinner,
      doubleChance: doubleChance ?? this.doubleChance,
      btts: btts ?? this.btts,
      correctScore: correctScore ?? this.correctScore,
      overUnder: overUnder ?? this.overUnder,
      cornersPrediction: cornersPrediction ?? this.cornersPrediction,
      cardsPrediction: cardsPrediction ?? this.cardsPrediction,
      playerProps: playerProps ?? this.playerProps,
      generatedAt: generatedAt ?? this.generatedAt,
      matchDate: matchDate ?? this.matchDate,
    );
  }
}

