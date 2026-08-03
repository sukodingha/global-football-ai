import '../entities/prediction_entity.dart';
import 'match_model.dart';

/// Data model for an AI prediction.
class PredictionModel {
  const PredictionModel({
    required this.id,
    required this.match,
    required this.predictedResult,
    required this.confidence,
    required this.confidenceScore,
    this.suggestedScore,
    this.analysisSummary,
  });

  final String id;
  final MatchModel match;
  final String predictedResult;
  final PredictionConfidence confidence;
  final double confidenceScore;
  final String? suggestedScore;
  final String? analysisSummary;

  /// Parses a prediction from the API response.
  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    final confidenceStr = json['confidence'] as String? ?? 'medium';
    return PredictionModel(
      id: json['id'].toString(),
      match: MatchModel.fromJson(
        json['match'] as Map<String, dynamic>? ?? const {},
      ),
      predictedResult: json['predictedResult'] as String? ?? 'Unknown',
      confidence: _parseConfidence(confidenceStr),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      suggestedScore: json['suggestedScore'] as String?,
      analysisSummary: json['analysisSummary'] as String?,
    );
  }

  static PredictionConfidence _parseConfidence(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return PredictionConfidence.low;
      case 'medium':
        return PredictionConfidence.medium;
      case 'high':
        return PredictionConfidence.high;
      case 'very_high':
      case 'veryHigh':
        return PredictionConfidence.veryHigh;
      default:
        return PredictionConfidence.medium;
    }
  }

  /// Converts to a domain entity.
  PredictionEntity toEntity() {
    return PredictionEntity(
      id: id,
      match: match.toEntity(),
      predictedResult: predictedResult,
      confidence: confidence,
      confidenceScore: confidenceScore,
      suggestedScore: suggestedScore,
      analysisSummary: analysisSummary,
    );
  }
}

/// Data model for today's prediction summary.
class PredictionSummaryModel {
  const PredictionSummaryModel({
    required this.totalPredictions,
    required this.highConfidence,
    required this.totalMatches,
    required this.predictions,
  });

  final int totalPredictions;
  final int highConfidence;
  final int totalMatches;
  final List<PredictionModel> predictions;

  factory PredictionSummaryModel.fromJson(Map<String, dynamic> json) {
    final predictions = (json['predictions'] as List<dynamic>? ?? [])
        .map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PredictionSummaryModel(
      totalPredictions: json['totalPredictions'] as int? ?? predictions.length,
      highConfidence: json['highConfidence'] as int? ?? 0,
      totalMatches: json['totalMatches'] as int? ?? 0,
      predictions: predictions,
    );
  }

  /// Converts to a domain entity.
  PredictionSummaryEntity toEntity() {
    return PredictionSummaryEntity(
      totalPredictions: totalPredictions,
      highConfidence: highConfidence,
      totalMatches: totalMatches,
      predictions: predictions.map((p) => p.toEntity()).toList(),
    );
  }
}
