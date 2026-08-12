import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_prediction_entity.dart';

/// Data-layer model for an admin-managed prediction.
class AdminPredictionModel {
  const AdminPredictionModel({required this.entity});

  final AdminPredictionEntity entity;

  /// Builds an [AdminPredictionEntity] from a Firestore document snapshot.
  factory AdminPredictionModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    final entity = AdminPredictionEntity(
      id: data['id'] as String? ?? doc.id,
      matchId: (data['matchId'] as num?)?.toInt() ?? 0,
      homeTeam: data['homeTeam'] as String? ?? '',
      awayTeam: data['awayTeam'] as String? ?? '',
      overallConfidence: (data['overallConfidence'] as num?)?.toDouble() ?? 0,
      summary: data['summary'] as String? ?? '',
      predictedOutcome: data['predictedOutcome'] as String?,
      suggestedScore: data['suggestedScore'] as String?,
      status: PredictionAuditStatus.fromString(data['auditStatus'] as String?),
      overrideOutcome: data['overrideOutcome'] as String?,
      overrideNote: data['overrideNote'] as String?,
      verifiedBy: data['verifiedBy'] as String?,
      verifiedAt: _timestamp(data['verifiedAt']),
      generatedAt: _timestamp(data['generatedAt']),
      matchDate: _timestamp(data['matchDate']),
    );
    return AdminPredictionModel(entity: entity);
  }

  /// Serializes the entity to a Firestore map.
  Map<String, dynamic> toJson() => {
        'id': entity.id,
        'matchId': entity.matchId,
        'homeTeam': entity.homeTeam,
        'awayTeam': entity.awayTeam,
        'overallConfidence': entity.overallConfidence,
        'summary': entity.summary,
        'predictedOutcome': entity.predictedOutcome,
        'suggestedScore': entity.suggestedScore,
        'auditStatus': entity.status.name,
        'overrideOutcome': entity.overrideOutcome,
        'overrideNote': entity.overrideNote,
        'verifiedBy': entity.verifiedBy,
        'verifiedAt': entity.verifiedAt != null
            ? Timestamp.fromDate(entity.verifiedAt!)
            : null,
        'generatedAt': entity.generatedAt != null
            ? Timestamp.fromDate(entity.generatedAt!)
            : null,
        'matchDate': entity.matchDate != null
            ? Timestamp.fromDate(entity.matchDate!)
            : null,
      };

  static DateTime? _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
