import 'package:equatable/equatable.dart';

/// Audit/verification status of an AI prediction.
enum PredictionAuditStatus {
  pending,
  verified,
  overridden;

  String get label => switch (this) {
        PredictionAuditStatus.pending => 'Pending',
        PredictionAuditStatus.verified => 'Verified',
        PredictionAuditStatus.overridden => 'Overridden',
      };

  static PredictionAuditStatus fromString(String? value) {
    switch (value) {
      case 'verified':
        return PredictionAuditStatus.verified;
      case 'overridden':
        return PredictionAuditStatus.overridden;
      default:
        return PredictionAuditStatus.pending;
    }
  }
}

/// Admin-facing view of an AI prediction for audit/override.
class AdminPredictionEntity extends Equatable {
  const AdminPredictionEntity({
    required this.id,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.overallConfidence,
    required this.summary,
    this.predictedOutcome,
    this.suggestedScore,
    this.status = PredictionAuditStatus.pending,
    this.overrideOutcome,
    this.overrideNote,
    this.verifiedBy,
    this.verifiedAt,
    this.generatedAt,
    this.matchDate,
  });

  final String id;
  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final double overallConfidence;
  final String summary;
  final String? predictedOutcome;
  final String? suggestedScore;
  final PredictionAuditStatus status;
  final String? overrideOutcome;
  final String? overrideNote;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime? generatedAt;
  final DateTime? matchDate;

  @override
  List<Object?> get props => [
        id,
        matchId,
        homeTeam,
        awayTeam,
        overallConfidence,
        summary,
        predictedOutcome,
        suggestedScore,
        status,
        overrideOutcome,
        overrideNote,
        verifiedBy,
        verifiedAt,
        generatedAt,
        matchDate,
      ];

  AdminPredictionEntity copyWith({
    String? id,
    int? matchId,
    String? homeTeam,
    String? awayTeam,
    double? overallConfidence,
    String? summary,
    String? predictedOutcome,
    String? suggestedScore,
    PredictionAuditStatus? status,
    String? overrideOutcome,
    String? overrideNote,
    String? verifiedBy,
    DateTime? verifiedAt,
    DateTime? generatedAt,
    DateTime? matchDate,
  }) {
    return AdminPredictionEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      summary: summary ?? this.summary,
      predictedOutcome: predictedOutcome ?? this.predictedOutcome,
      suggestedScore: suggestedScore ?? this.suggestedScore,
      status: status ?? this.status,
      overrideOutcome: overrideOutcome ?? this.overrideOutcome,
      overrideNote: overrideNote ?? this.overrideNote,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      generatedAt: generatedAt ?? this.generatedAt,
      matchDate: matchDate ?? this.matchDate,
    );
  }
}
