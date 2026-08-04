import 'package:equatable/equatable.dart';

/// Visibility of a fantasy league.
enum LeagueVisibility { public, private }

/// A fantasy football league that groups multiple [FantasyTeam]s.
class FantasyLeagueEntity extends Equatable {
  const FantasyLeagueEntity({
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

  /// Short join code used by users to discover the league.
  final String code;
  final LeagueVisibility visibility;
  final String ownerId;
  final int memberCount;

  /// Starting budget every team receives when joining (in fantasy credits).
  final double startBudget;
  final DateTime createdAt;
  final String? description;

  /// User ids that have joined the league.
  final List<String> members;

  bool get isPublic => visibility == LeagueVisibility.public;

  FantasyLeagueEntity copyWith({
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
    return FantasyLeagueEntity(
      id: id,
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

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        visibility,
        ownerId,
        memberCount,
        startBudget,
        createdAt,
        description,
        members,
      ];
}

