import 'package:equatable/equatable.dart';

import 'match_entity.dart';

/// The confidence level of an AI prediction.
enum PredictionConfidence {
  low,
  medium,
  high,
  veryHigh;

  /// Displays the confidence as a percentage threshold label.
  String get label {
    switch (this) {
      case PredictionConfidence.low:
        return 'Low';
      case PredictionConfidence.medium:
        return 'Medium';
      case PredictionConfidence.high:
        return 'High';
      case PredictionConfidence.veryHigh:
        return 'Very High';
    }
  }
}

/// A single AI football prediction.
class PredictionEntity extends Equatable {
  const PredictionEntity({
    required this.id,
    required this.match,
    required this.predictedResult,
    required this.confidence,
    required this.confidenceScore,
    this.suggestedScore,
    this.analysisSummary,
  });

  final String id;
  final MatchEntity match;
  final String predictedResult;
  final PredictionConfidence confidence;
  final double confidenceScore;
  final String? suggestedScore;
  final String? analysisSummary;

  @override
  List<Object?> get props => [
        id,
        match,
        predictedResult,
        confidence,
        confidenceScore,
        suggestedScore,
        analysisSummary,
      ];
}

/// Dashboard summary of today's AI predictions.
class PredictionSummaryEntity extends Equatable {
  const PredictionSummaryEntity({
    required this.totalPredictions,
    required this.highConfidence,
    required this.totalMatches,
    required this.predictions,
  });

  /// Creates an empty summary representing "no predictions available".
  const PredictionSummaryEntity.empty()
      : totalPredictions = 0,
        highConfidence = 0,
        totalMatches = 0,
        predictions = const [];

  final int totalPredictions;
  final int highConfidence;
  final int totalMatches;
  final List<PredictionEntity> predictions;

  @override
  List<Object?> get props => [totalPredictions, highConfidence, totalMatches, predictions];
}
