import '../../domain/entities/prediction_entity.dart';

/// Data model for a full match prediction.
///
/// Serializes the complete prediction breakdown to/from JSON for
/// persistence in Firebase and local secure storage.
class MatchPredictionModel {
  const MatchPredictionModel({
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
  final double overallConfidence;
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

  factory MatchPredictionModel.fromJson(Map<String, dynamic> json) {
    return MatchPredictionModel(
      matchId: (json['matchId'] as num?)?.toInt() ?? 0,
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      overallConfidence: (json['overallConfidence'] as num?)?.toDouble() ?? 0,
      summary: json['summary'] as String? ?? '',
      matchWinner: json['matchWinner'] == null
          ? null
          : _parseMatchWinner(json['matchWinner'] as Map<String, dynamic>),
      doubleChance: json['doubleChance'] == null
          ? null
          : _parseDoubleChance(json['doubleChance'] as Map<String, dynamic>),
      btts: json['btts'] == null
          ? null
          : _parseBtts(json['btts'] as Map<String, dynamic>),
      correctScore: json['correctScore'] == null
          ? null
          : _parseCorrectScore(json['correctScore'] as Map<String, dynamic>),
      overUnder: json['overUnder'] == null
          ? null
          : _parseOverUnder(json['overUnder'] as Map<String, dynamic>),
      cornersPrediction: json['cornersPrediction'] == null
          ? null
          : _parseCorners(json['cornersPrediction'] as Map<String, dynamic>),
      cardsPrediction: json['cardsPrediction'] == null
          ? null
          : _parseCards(json['cardsPrediction'] as Map<String, dynamic>),
      playerProps: (json['playerProps'] as List<dynamic>? ?? [])
          .map((e) => _parsePlayerProp(e as Map<String, dynamic>))
          .toList(),
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.tryParse(json['generatedAt'] as String),
      matchDate: json['matchDate'] == null
          ? null
          : DateTime.tryParse(json['matchDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'overallConfidence': overallConfidence,
      'summary': summary,
      'matchWinner': matchWinner == null ? null : _serializeMatchWinner(matchWinner!),
      'doubleChance': doubleChance == null ? null : _serializeDoubleChance(doubleChance!),
      'btts': btts == null ? null : _serializeBtts(btts!),
      'correctScore': correctScore == null ? null : _serializeCorrectScore(correctScore!),
      'overUnder': overUnder == null ? null : _serializeOverUnder(overUnder!),
      'cornersPrediction': cornersPrediction == null
          ? null
          : _serializeCorners(cornersPrediction!),
      'cardsPrediction': cardsPrediction == null
          ? null
          : _serializeCards(cardsPrediction!),
      'playerProps': playerProps.map(_serializePlayerProp).toList(),
      'generatedAt': generatedAt?.toIso8601String(),
      'matchDate': matchDate?.toIso8601String(),
    };
  }

  MatchPredictionEntity toEntity() {
    return MatchPredictionEntity(
      matchId: matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      overallConfidence: overallConfidence,
      summary: summary,
      matchWinner: matchWinner,
      doubleChance: doubleChance,
      btts: btts,
      correctScore: correctScore,
      overUnder: overUnder,
      cornersPrediction: cornersPrediction,
      cardsPrediction: cardsPrediction,
      playerProps: playerProps,
      generatedAt: generatedAt,
      matchDate: matchDate,
    );
  }

  factory MatchPredictionModel.fromEntity(MatchPredictionEntity entity) {
    return MatchPredictionModel(
      matchId: entity.matchId,
      homeTeam: entity.homeTeam,
      awayTeam: entity.awayTeam,
      overallConfidence: entity.overallConfidence,
      summary: entity.summary,
      matchWinner: entity.matchWinner,
      doubleChance: entity.doubleChance,
      btts: entity.btts,
      correctScore: entity.correctScore,
      overUnder: entity.overUnder,
      cornersPrediction: entity.cornersPrediction,
      cardsPrediction: entity.cardsPrediction,
      playerProps: entity.playerProps,
      generatedAt: entity.generatedAt,
      matchDate: entity.matchDate,
    );
  }

  // ── Parsers ───────────────────────────────────────────────────────

  static MatchWinnerPrediction _parseMatchWinner(Map<String, dynamic> json) {
    return MatchWinnerPrediction(
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      predictedOutcome: json['predictedOutcome'] as String? ?? 'draw',
      explanation: json['explanation'] as String? ?? '',
      odds: json['odds'] == null
          ? null
          : Odds(
              home: (json['odds']['home'] as num?)?.toDouble() ?? 0,
              draw: (json['odds']['draw'] as num?)?.toDouble() ?? 0,
              away: (json['odds']['away'] as num?)?.toDouble() ?? 0,
            ),
    );
  }

  static Map<String, dynamic> _serializeMatchWinner(MatchWinnerPrediction p) {
    return {
      'confidence': p.confidence,
      'predictedOutcome': p.predictedOutcome,
      'explanation': p.explanation,
      'odds': p.odds == null
          ? null
          : {'home': p.odds!.home, 'draw': p.odds!.draw, 'away': p.odds!.away},
    };
  }

  static DoubleChancePrediction _parseDoubleChance(Map<String, dynamic> json) {
    return DoubleChancePrediction(
      homeOrDraw: (json['homeOrDraw'] as num?)?.toDouble() ?? 0,
      homeOrAway: (json['homeOrAway'] as num?)?.toDouble() ?? 0,
      drawOrAway: (json['drawOrAway'] as num?)?.toDouble() ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _serializeDoubleChance(DoubleChancePrediction p) {
    return {
      'homeOrDraw': p.homeOrDraw,
      'homeOrAway': p.homeOrAway,
      'drawOrAway': p.drawOrAway,
      'explanation': p.explanation,
    };
  }

  static BttsPrediction _parseBtts(Map<String, dynamic> json) {
    return BttsPrediction(
      yesConfidence: (json['yesConfidence'] as num?)?.toDouble() ?? 0,
      noConfidence: (json['noConfidence'] as num?)?.toDouble() ?? 0,
      prediction: json['prediction'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _serializeBtts(BttsPrediction p) {
    return {
      'yesConfidence': p.yesConfidence,
      'noConfidence': p.noConfidence,
      'prediction': p.prediction,
      'explanation': p.explanation,
    };
  }

  static CorrectScorePrediction _parseCorrectScore(Map<String, dynamic> json) {
    return CorrectScorePrediction(
      mostLikelyHome: (json['mostLikelyHome'] as num?)?.toInt() ?? 0,
      mostLikelyAway: (json['mostLikelyAway'] as num?)?.toInt() ?? 0,
      alternateScores: (json['alternateScores'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _serializeCorrectScore(CorrectScorePrediction p) {
    return {
      'mostLikelyHome': p.mostLikelyHome,
      'mostLikelyAway': p.mostLikelyAway,
      'alternateScores': p.alternateScores,
      'confidence': p.confidence,
      'explanation': p.explanation,
    };
  }

  static OverUnderPrediction _parseOverUnder(Map<String, dynamic> json) {
    return OverUnderPrediction(
      under2_5: (json['under2_5'] as num?)?.toDouble() ?? 0,
      over2_5: (json['over2_5'] as num?)?.toDouble() ?? 0,
      prediction: json['prediction'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _serializeOverUnder(OverUnderPrediction p) {
    return {
      'under2_5': p.under2_5,
      'over2_5': p.over2_5,
      'prediction': p.prediction,
      'explanation': p.explanation,
    };
  }

  static CornersPrediction _parseCorners(Map<String, dynamic> json) {
    return CornersPrediction(
      under9_5: (json['under9_5'] as num?)?.toDouble() ?? 0,
      over9_5: (json['over9_5'] as num?)?.toDouble() ?? 0,
      prediction: json['prediction'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _serializeCorners(CornersPrediction p) {
    return {
      'under9_5': p.under9_5,
      'over9_5': p.over9_5,
      'prediction': p.prediction,
      'explanation': p.explanation,
    };
  }

  static CardsPrediction _parseCards(Map<String, dynamic> json) {
    return CardsPrediction(
      under4_5: (json['under4_5'] as num?)?.toDouble() ?? 0,
      over4_5: (json['over4_5'] as num?)?.toDouble() ?? 0,
      prediction: json['prediction'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _serializeCards(CardsPrediction p) {
    return {
      'under4_5': p.under4_5,
      'over4_5': p.over4_5,
      'prediction': p.prediction,
      'explanation': p.explanation,
    };
  }

  static PlayerProp _parsePlayerProp(Map<String, dynamic> json) {
    return PlayerProp(
      playerName: json['playerName'] as String? ?? '',
      metric: json['metric'] as String? ?? '',
      predictedValue: (json['predictedValue'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _serializePlayerProp(PlayerProp p) {
    return {
      'playerName': p.playerName,
      'metric': p.metric,
      'predictedValue': p.predictedValue,
      'confidence': p.confidence,
      'explanation': p.explanation,
    };
  }
}

