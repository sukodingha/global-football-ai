import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/fantasy_league_entity.dart';

/// Firestore-compatible JSON model for [FantasyLeagueEntity].
class FantasyLeagueModel {
  const FantasyLeagueModel({
    required this.id,
    required this.name,
    required this.code,
    required this.visibility,
    required this.ownerId,
    required this.memberCount,
    required this.startBudget,
    required this.createdAt,
    this.description,
    this.members = const [],
  });

  final String id;
  final String name;
  final String code;
  final LeagueVisibility visibility;
  final String ownerId;
  final int memberCount;
  final double startBudget;
  final DateTime createdAt;
  final String? description;
  final List<String> members;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'visibility': visibility.name,
        'ownerId': ownerId,
        'memberCount': memberCount,
        'startBudget': startBudget,
        'createdAt': Timestamp.fromDate(createdAt),
        'description': description,
        'members': members,
      };

  factory FantasyLeagueModel.fromJson(Map<String, dynamic> json) {
    return FantasyLeagueModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      visibility: _visibilityFromString(json['visibility'] as String?),
      ownerId: json['ownerId'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      startBudget: (json['startBudget'] as num?)?.toDouble() ?? 100,
      createdAt: _timestamp(json['createdAt']),
      description: json['description'] as String?,
      members: (json['members'] as List<dynamic>? ?? const [])
          .cast<String>(),
    );
  }

  FantasyLeagueEntity toEntity() => FantasyLeagueEntity(
        id: id,
        name: name,
        code: code,
        visibility: visibility,
        ownerId: ownerId,
        memberCount: memberCount,
        startBudget: startBudget,
        createdAt: createdAt,
        description: description,
        members: members,
      );

  factory FantasyLeagueModel.fromEntity(FantasyLeagueEntity entity) =>
      FantasyLeagueModel(
        id: entity.id,
        name: entity.name,
        code: entity.code,
        visibility: entity.visibility,
        ownerId: entity.ownerId,
        memberCount: entity.memberCount,
        startBudget: entity.startBudget,
        createdAt: entity.createdAt,
        description: entity.description,
        members: entity.members,
      );

  FantasyLeagueModel copyWith({
    String? id,
    String? name,
    String? code,
    LeagueVisibility? visibility,
    String? ownerId,
    int? memberCount,
    double? startBudget,
    DateTime? createdAt,
    String? description,
    List<String>? members,
  }) {
    return FantasyLeagueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      visibility: visibility ?? this.visibility,
      ownerId: ownerId ?? this.ownerId,
      memberCount: memberCount ?? this.memberCount,
      startBudget: startBudget ?? this.startBudget,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      members: members ?? this.members,
    );
  }

  static LeagueVisibility _visibilityFromString(String? value) {
    switch (value) {
      case 'public':
        return LeagueVisibility.public;
      case 'private':
        return LeagueVisibility.private;
      default:
        return LeagueVisibility.public;
    }
  }

  static DateTime _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}

