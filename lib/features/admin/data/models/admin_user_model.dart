import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_user_entity.dart';

/// Data-layer model for the admin view of a user.
class AdminUserModel {
  const AdminUserModel({required this.entity});

  final AdminUserEntity entity;

  /// Builds an [AdminUserEntity] from a Firestore document snapshot.
  factory AdminUserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AdminUserEntity(
      id: data['id'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: UserRole.fromString(data['role'] as String?),
      isBanned: data['isBanned'] as bool? ?? false,
      banReason: data['banReason'] as String?,
      isPremium: data['premium'] as bool? ?? false,
      premiumPlanName: data['premiumPlanName'] as String?,
      premiumEnd: _timestamp(data['premiumEnd']),
      donationsTotalKobo: (data['donationsTotalKobo'] as num?)?.toInt() ?? 0,
      badges: (data['badges'] as List<dynamic>? ?? const []).cast<String>(),
      createdAt: _timestamp(data['createdAt']),
      lastActiveAt: _timestamp(data['lastActiveAt']),
    );
  }

  static DateTime? _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
