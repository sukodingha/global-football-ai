import '../../domain/entities/fantasy_player_entity.dart';
import '../../domain/entities/fantasy_team_entity.dart';
import 'fantasy_player_model.dart';

/// Firestore-compatible JSON model for [FantasyTeamEntity].
class FantasyTeamModel {
  const FantasyTeamModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.leagueId,
    required this.budgetRemaining,
    this.captainId,
    this.viceCaptainId,
    this.totalPoints = 0,
    this.playerIds = const [],
    this.players = const [],
  });

  final String id;
  final String name;
  final String userId;
  final String leagueId;
  final double budgetRemaining;
  final String? captainId;
  final String? viceCaptainId;
  final double totalPoints;

  /// Ids of the selected player pool (for compact storage).
  final List<int> playerIds;

  /// Full player objects (hydrated from pool for the UI).
  final List<FantasyPlayerModel> players;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'userId': userId,
        'leagueId': leagueId,
        'budgetRemaining': budgetRemaining,
        'captainId': captainId,
        'viceCaptainId': viceCaptainId,
        'totalPoints': totalPoints,
        'playerIds': playerIds,
      };

  factory FantasyTeamModel.fromJson(Map<String, dynamic> json) {
    return FantasyTeamModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      leagueId: json['leagueId'] as String? ?? '',
      budgetRemaining: (json['budgetRemaining'] as num?)?.toDouble() ?? 100,
      captainId: json['captainId'] as String?,
      viceCaptainId: json['viceCaptainId'] as String?,
      totalPoints: (json['totalPoints'] as num?)?.toDouble() ?? 0,
      playerIds: (json['playerIds'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }

  FantasyTeamEntity toEntity() => FantasyTeamEntity(
        id: id,
        name: name,
        userId: userId,
        leagueId: leagueId,
        budgetRemaining: budgetRemaining,
        captainId: captainId,
        viceCaptainId: viceCaptainId,
        totalPoints: totalPoints,
        players: players.map((p) => p.toEntity()).toList(),
      );

  factory FantasyTeamModel.fromEntity(FantasyTeamEntity entity) =>
      FantasyTeamModel(
        id: entity.id,
        name: entity.name,
        userId: entity.userId,
        leagueId: entity.leagueId,
        budgetRemaining: entity.budgetRemaining,
        captainId: entity.captainId,
        viceCaptainId: entity.viceCaptainId,
        totalPoints: entity.totalPoints,
        playerIds: entity.players.map((p) => p.id).toList(),
        players:
            entity.players.map((p) => FantasyPlayerModel.fromEntity(p)).toList(),
      );
}

