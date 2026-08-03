import '../../domain/entities/prediction_history_entity.dart';
import 'prediction_model.dart';

/// Data model for a stored prediction history record.
class PredictionHistoryModel {
  const PredictionHistoryModel({
    required this.id,
    required this.userId,
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
  final String userId;
  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final MatchPredictionModel prediction;
  final DateTime createdAt;
  final DateTime? matchDate;
  final int? actualHomeScore;
  final int? actualAwayScore;
  final PredictionStatus status;
  final bool? isCorrect;

  factory PredictionHistoryModel.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      matchId: (json['matchId'] as num?)?.toInt() ?? 0,
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      prediction: MatchPredictionModel.fromJson(
        json['prediction'] as Map<String, dynamic>? ?? const {},
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      matchDate: json['matchDate'] == null
          ? null
          : DateTime.tryParse(json['matchDate'] as String),
      actualHomeScore: (json['actualHomeScore'] as num?)?.toInt(),
      actualAwayScore: (json['actualAwayScore'] as num?)?.toInt(),
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      isCorrect: json['isCorrect'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'matchId': matchId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'prediction': prediction.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'matchDate': matchDate?.toIso8601String(),
      'actualHomeScore': actualHomeScore,
      'actualAwayScore': actualAwayScore,
      'status': status.name,
      'isCorrect': isCorrect,
    };
  }

  PredictionHistoryEntity toEntity() {
    return PredictionHistoryEntity(
      id: id,
      matchId: matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      prediction: prediction.toEntity(),
      createdAt: createdAt,
      matchDate: matchDate,
      actualHomeScore: actualHomeScore,
      actualAwayScore: actualAwayScore,
      status: status,
      isCorrect: isCorrect,
    );
  }

  factory PredictionHistoryModel.fromEntity({
    required PredictionHistoryEntity entity,
    required String userId,
  }) {
    return PredictionHistoryModel(
      id: entity.id,
      userId: userId,
      matchId: entity.matchId,
      homeTeam: entity.homeTeam,
      awayTeam: entity.awayTeam,
      prediction: MatchPredictionModel.fromEntity(entity.prediction),
      createdAt: entity.createdAt,
      matchDate: entity.matchDate,
      actualHomeScore: entity.actualHomeScore,
      actualAwayScore: entity.actualAwayScore,
      status: entity.status,
      isCorrect: entity.isCorrect,
    );
  }

  static PredictionStatus _parseStatus(String value) {
    switch (value) {
      case 'won':
        return PredictionStatus.won;
      case 'lost':
        return PredictionStatus.lost;
      case 'voided':
        return PredictionStatus.voided;
      default:
        return PredictionStatus.pending;
    }
  }
}

