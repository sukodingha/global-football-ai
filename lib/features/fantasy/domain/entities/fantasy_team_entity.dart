import 'package:equatable/equatable.dart';

import 'fantasy_player_entity.dart';

/// A user's fantasy team within a league. Manages roster, captain,
/// vice captain, budget and total points.
class FantasyTeamEntity extends Equatable {
  const FantasyTeamEntity({
    required this.id,
    required this.name,
    required this.userId,
    required this.leagueId,
    required this.budgetRemaining,
    this.captainId,
    this.viceCaptainId,
    this.totalPoints = 0,
    this.players = const [],
  });

  final String id;
  final String name;
  final String userId;
  final String leagueId;

  /// Remaining budget in fantasy credits.
  final double budgetRemaining;
  final String? captainId;
  final String? viceCaptainId;
  final double totalPoints;

  /// Currently selected players. Constraints are enforced at the
  /// application layer (squad size, budget, positions).
  final List<FantasyPlayerEntity> players;

  FantasyPlayerEntity? get captain {
    for (final p in players) {
      if (p.id.toString() == captainId) return p;
    }
    return null;
  }

  FantasyPlayerEntity? get viceCaptain {
    for (final p in players) {
      if (p.id.toString() == viceCaptainId) return p;
    }
    return null;
  }

  double get playersValue =>
      players.fold(0, (sum, p) => sum + p.price);

  bool containsPlayer(int playerId) =>
      players.any((p) => p.id == playerId);

  FantasyTeamEntity copyWith({
    String? name,
    String? userId,
    String? leagueId,
    double? budgetRemaining,
    String? captainId,
    String? viceCaptainId,
    double? totalPoints,
    List<FantasyPlayerEntity>? players,
  }) {
    return FantasyTeamEntity(
      id: id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      leagueId: leagueId ?? this.leagueId,
      budgetRemaining: budgetRemaining ?? this.budgetRemaining,
      captainId: captainId ?? this.captainId,
      viceCaptainId: viceCaptainId ?? this.viceCaptainId,
      totalPoints: totalPoints ?? this.totalPoints,
      players: players ?? this.players,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        userId,
        leagueId,
        budgetRemaining,
        captainId,
        viceCaptainId,
        totalPoints,
        players,
      ];
}

