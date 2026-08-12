import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_audit_log_entity.dart';

/// Data-layer model for an admin audit log entry.
class AdminAuditLogModel {
  const AdminAuditLogModel({required this.entity});

  final AdminAuditLogEntity entity;

  /// Builds an [AdminAuditLogEntity] from a Firestore document snapshot.
  factory AdminAuditLogModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    final entity = AdminAuditLogEntity(
      id: data['id'] as String? ?? doc.id,
      adminId: data['adminId'] as String? ?? '',
      adminName: data['adminName'] as String? ?? 'Unknown',
      action: data['action'] as String? ?? '',
      targetType: data['targetType'] as String? ?? '',
      targetId: data['targetId'] as String? ?? '',
      timestamp: _timestamp(data['timestamp']) ?? DateTime.now(),
      details: data['details'] as String?,
    );
    return AdminAuditLogModel(entity: entity);
  }

  /// Serializes the entity to a Firestore map.
  Map<String, dynamic> toJson() => {
        'id': entity.id,
        'adminId': entity.adminId,
        'adminName': entity.adminName,
        'action': entity.action,
        'targetType': entity.targetType,
        'targetId': entity.targetId,
        'timestamp': Timestamp.fromDate(entity.timestamp),
        'details': entity.details,
      };

  static DateTime? _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
