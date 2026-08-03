import 'package:equatable/equatable.dart';

import 'prediction_entity.dart';

/// A stored prediction record in the user's history.
class PredictionHistoryEntity extends Equatable {
  const PredictionHistoryEntity({
    required this.id,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.prediction,
    required this.createdAt,
    this.matchDate,
    this.actualHomeScore,
    this.actualAwayScore,
    this.status = PredictionStatus.pending,
    this.isCorrect,
  });

  final String id;
  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final MatchPredictionEntity prediction;
  final DateTime createdAt;
  final DateTime? matchDate;
  final int? actualHomeScore;
  final int? actualAwayScore;
  final PredictionStatus status;

  /// Whether the prediction was correct (null if not yet resolved).
  final bool? isCorrect;

  @override
  List<Object?> get props => [
        id,
        matchId,
        homeTeam,
        awayTeam,
        prediction,
        createdAt,
        matchDate,
        actualHomeScore,
        actualAwayScore,
        status,
        isCorrect,
      ];

  PredictionHistoryEntity copyWith({
    String? id,
    int? matchId,
    String? homeTeam,
    String? awayTeam,
    MatchPredictionEntity? prediction,
    DateTime? createdAt,
    DateTime? matchDate,
    int? actualHomeScore,
    int? actualAwayScore,
    PredictionStatus? status,
    bool? isCorrect,
  }) {
    return PredictionHistoryEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      prediction: prediction ?? this.prediction,
      createdAt: createdAt ?? this.createdAt,
      matchDate: matchDate ?? this.matchDate,
      actualHomeScore: actualHomeScore ?? this.actualHomeScore,
      actualAwayScore: actualAwayScore ?? this.actualAwayScore,
      status: status ?? this.status,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

/// Status of a prediction.
enum PredictionStatus {
  pending,
  won,
  lost,
  voided,
}

/// Overall accuracy statistics for a user's prediction history.
class AccuracyStatsEntity extends Equatable {
  const AccuracyStatsEntity({
    required this.totalPredictions,
    required this.correctPredictions,
    required this.incorrectPredictions,
    required this.voidedPredictions,
  });

  final int totalPredictions;
  final int correctPredictions;
  final int incorrectPredictions;
  final int voidedPredictions;

  /// Percentage accuracy 0-100.
  double get accuracyPercentage {
    if (totalPredictions == 0) return 0;
    return (correctPredictions / totalPredictions) * 100;
  }

  @override
  List<Object?> get props => [
        totalPredictions,
        correctPredictions,
        incorrectPredictions,
        voidedPredictions,
      ];
}
