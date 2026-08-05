import 'package:equatable/equatable.dart';

/// An audit trail entry recording an admin action.
class AdminAuditLogEntity extends Equatable {
  const AdminAuditLogEntity({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.timestamp,
    this.details,
  });

  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final String targetType;
  final String targetId;
  final DateTime timestamp;
  final String? details;

  @override
  List<Object?> get props => [
        id,
        adminId,
        adminName,
        action,
        targetType,
        targetId,
        timestamp,
        details,
      ];
}
