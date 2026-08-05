import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_competition_entity.dart';

/// Data-layer model for an admin-managed competition.
class AdminCompetitionModel {
  const AdminCompetitionModel({required this.entity});

  final AdminCompetitionEntity entity;

  /// Builds an [AdminCompetitionEntity] from a Firestore document snapshot.
  factory AdminCompetitionModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return AdminCompetitionEntity(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      type: data['type'] as String? ?? 'LEAGUE',
      emblem: data['emblem'] as String?,
      country: data['country'] as String?,
      currentMatchday: (data['currentMatchday'] as num?)?.toInt(),
      featured: data['featured'] as bool? ?? false,
      active: data['active'] as bool? ?? true,
      totalTeams: (data['totalTeams'] as num?)?.toInt() ?? 0,
      totalFixtures: (data['totalFixtures'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes the entity to a Firestore map.
  Map<String, dynamic> toJson() => {
        'id': entity.id,
        'name': entity.name,
        'code': entity.code,
        'type': entity.type,
        'emblem': entity.emblem,
        'country': entity.country,
        'currentMatchday': entity.currentMatchday,
        'featured': entity.featured,
        'active': entity.active,
        'totalTeams': entity.totalTeams,
        'totalFixtures': entity.totalFixtures,
      };
}
