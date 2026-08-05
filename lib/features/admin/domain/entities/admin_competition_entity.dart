import 'package:equatable/equatable.dart';

/// Admin-facing representation of a competition (league, cup, etc.).
class AdminCompetitionEntity extends Equatable {
  const AdminCompetitionEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.emblem,
    this.country,
    this.currentMatchday,
    this.featured = false,
    this.active = true,
    this.totalTeams = 0,
    this.totalFixtures = 0,
  });

  final String id;
  final String name;
  final String code;
  final String type;
  final String? emblem;
  final String? country;
  final int? currentMatchday;
  final bool featured;
  final bool active;
  final int totalTeams;
  final int totalFixtures;

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        type,
        emblem,
        country,
        currentMatchday,
        featured,
        active,
        totalTeams,
        totalFixtures,
      ];

  AdminCompetitionEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? type,
    String? emblem,
    String? country,
    int? currentMatchday,
    bool? featured,
    bool? active,
    int? totalTeams,
    int? totalFixtures,
  }) {
    return AdminCompetitionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      emblem: emblem ?? this.emblem,
      country: country ?? this.country,
      currentMatchday: currentMatchday ?? this.currentMatchday,
      featured: featured ?? this.featured,
      active: active ?? this.active,
      totalTeams: totalTeams ?? this.totalTeams,
      totalFixtures: totalFixtures ?? this.totalFixtures,
    );
  }
}
