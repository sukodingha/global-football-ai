import '../../domain/entities/post_match_comparison_entity.dart';
import 'prediction_model.dart';

/// Data model for a stored post-match comparison.
///
/// Serializes the full comparison breakdown to/from JSON for persistence in
/// Cloud Firestore.
class PostMatchComparisonModel {
  const PostMatchComparisonModel({
    required this.id,
    required this.userId,
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

  final String id;
  final String userId;
  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final int actualHomeScore;
  final int actualAwayScore;
  final MatchPredictionModel prediction;
  final bool matchWinnerCorrect;
  final bool doubleChanceCorrect;
  final bool bttsCorrect;
  final bool correctScoreCorrect;
  final bool overUnderCorrect;
  final bool? cornersCorrect;
  final bool? cardsCorrect;
  final int correctPredictions;
  final int totalPredictions;
  final double overallAccuracy;
  final DateTime comparisonDate;

  factory PostMatchComparisonModel.fromEntity({
    required PostMatchComparisonEntity entity,
    required String userId,
    String? id,
  }) {
    return PostMatchComparisonModel(
      id: id ?? '${entity.matchId}_${entity.comparisonDate.millisecondsSinceEpoch}',
      userId: userId,
      matchId: entity.matchId,
      homeTeam: entity.homeTeam,
      awayTeam: entity.awayTeam,
      actualHomeScore: entity.actualHomeScore,
      actualAwayScore: entity.actualAwayScore,
      prediction: MatchPredictionModel.fromEntity(entity.prediction),
      matchWinnerCorrect: entity.matchWinnerCorrect,
      doubleChanceCorrect: entity.doubleChanceCorrect,
      bttsCorrect: entity.bttsCorrect,
      correctScoreCorrect: entity.correctScoreCorrect,
      overUnderCorrect: entity.overUnderCorrect,
      cornersCorrect: entity.cornersCorrect,
      cardsCorrect: entity.cardsCorrect,
      correctPredictions: entity.correctPredictions,
      totalPredictions: entity.totalPredictions,
      overallAccuracy: entity.overallAccuracy,
      comparisonDate: entity.comparisonDate,
    );
  }

  factory PostMatchComparisonModel.fromJson(Map<String, dynamic> json) {
    return PostMatchComparisonModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      matchId: (json['matchId'] as num?)?.toInt() ?? 0,
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      actualHomeScore: (json['actualHomeScore'] as num?)?.toInt() ?? 0,
      actualAwayScore: (json['actualAwayScore'] as num?)?.toInt() ?? 0,
      prediction: MatchPredictionModel.fromJson(
        json['prediction'] as Map<String, dynamic>? ?? const {},
      ),
      matchWinnerCorrect: json['matchWinnerCorrect'] as bool? ?? false,
      doubleChanceCorrect: json['doubleChanceCorrect'] as bool? ?? false,
      bttsCorrect: json['bttsCorrect'] as bool? ?? false,
      correctScoreCorrect: json['correctScoreCorrect'] as bool? ?? false,
      overUnderCorrect: json['overUnderCorrect'] as bool? ?? false,
      cornersCorrect: json['cornersCorrect'] as bool?,
      cardsCorrect: json['cardsCorrect'] as bool?,
      correctPredictions: (json['correctPredictions'] as num?)?.toInt() ?? 0,
      totalPredictions: (json['totalPredictions'] as num?)?.toInt() ?? 0,
      overallAccuracy: (json['overallAccuracy'] as num?)?.toDouble() ?? 0,
      comparisonDate:
          DateTime.tryParse(json['comparisonDate'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'matchId': matchId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'actualHomeScore': actualHomeScore,
      'actualAwayScore': actualAwayScore,
      'prediction': prediction.toJson(),
      'matchWinnerCorrect': matchWinnerCorrect,
      'doubleChanceCorrect': doubleChanceCorrect,
      'bttsCorrect': bttsCorrect,
      'correctScoreCorrect': correctScoreCorrect,
      'overUnderCorrect': overUnderCorrect,
      'cornersCorrect': cornersCorrect,
      'cardsCorrect': cardsCorrect,
      'correctPredictions': correctPredictions,
      'totalPredictions': totalPredictions,
      'overallAccuracy': overallAccuracy,
      'comparisonDate': comparisonDate.toIso8601String(),
    };
  }

  PostMatchComparisonEntity toEntity() {
    return PostMatchComparisonEntity(
      matchId: matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      actualHomeScore: actualHomeScore,
      actualAwayScore: actualAwayScore,
      prediction: prediction.toEntity(),
      matchWinnerCorrect: matchWinnerCorrect,
      doubleChanceCorrect: doubleChanceCorrect,
      bttsCorrect: bttsCorrect,
      correctScoreCorrect: correctScoreCorrect,
      overUnderCorrect: overUnderCorrect,
      cornersCorrect: cornersCorrect,
      cardsCorrect: cardsCorrect,
      correctPredictions: correctPredictions,
      totalPredictions: totalPredictions,
      overallAccuracy: overallAccuracy,
      comparisonDate: comparisonDate,
    );
  }
}
