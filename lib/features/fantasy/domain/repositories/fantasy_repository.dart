import   '../../../../core/errors/failures.dart';
import '../entities/fantasy_league_entity.dart';
import '../entities/fantasy_player_entity.dart';
import '../entities/fantasy_team_entity.dart';
import '../entities/leaderboard_entry_entity.dart';

/// Result wrapper for fantasy repository operations.
class FantasyResult<T> {
  const FantasyResult._(this.value, this.failure);
  const FantasyResult.success(T value) : this._(value, null);
  const FantasyResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}

/// Parameters for creating a league.
class CreateLeagueParams {
  const CreateLeagueParams({
    required this.name,
    required this.visibility,
    required this.ownerId,
    this.description,
    this.startBudget = 100,
  });

  final String name;
  final LeagueVisibility visibility;
  final String ownerId;
  final String? description;
  final double startBudget;
}

/// Parameters for joining a league via its join code.
class JoinLeagueParams {
  const JoinLeagueParams({
    required this.code,
    required this.userId,
    required this.userName,
    required this.teamName,
  });

  final String code;
  final String userId;
  final String userName;
  final String teamName;
}

/// Contract for the fantasy football repository.
///
/// Backed by Cloud Firestore for real-time league, team, leaderboard, and
/// player stats data. Scoring events are aggregated by the scoring engine
/// and written by a trusted producer (admin cloud function or API key).
abstract class FantasyRepository {
  /// Creates a new league and a starter team for the owner.
  Future<FantasyLeagueEntity> createLeague(CreateLeagueParams params);

  /// Joins a public league (or any league) using its [code] and creates a
  /// starter team for [userId].
  Future<FantasyLeagueEntity> joinLeagueByCode(JoinLeagueParams params);

  /// Fetches a snapshot of the league document.
  Future<FantasyLeagueEntity> getLeague(String leagueId);

  /// Watches a league for real-time updates (member count, etc.).
  Stream<FantasyLeagueEntity> watchLeague(String leagueId);

  /// Lists leagues the user has joined.
  Future<List<FantasyLeagueEntity>> getLeaguesForUser(String userId);

  /// Lists discoverable public leagues (for the join screen).
  Future<List<FantasyLeagueEntity>> getPublicLeagues({int limit = 20});

  /// Watches the public league directory for new leagues.
  Stream<List<FantasyLeagueEntity>> watchPublicLeagues({int limit = 20});

  /// Creates/initialises the user's team in a league.
  Future<FantasyTeamEntity> createTeam({
    required String name,
    required String userId,
    required String leagueId,
    double budget = 100,
  });

  /// Fetches the user's team in a league.
  Future<FantasyTeamEntity?> getTeamInLeague({
    required String userId,
    required String leagueId,
  });

  /// Watches a team for real-time point updates.
  Stream<FantasyTeamEntity> watchTeam(String teamId);

  /// Adds a player to the team roster (budget-aware).
  Future<FantasyTeamEntity> addPlayerToTeam({
    required String teamId,
    required FantasyPlayerEntity player,
  });

  /// Removes a player from the team roster.
  Future<FantasyTeamEntity> removePlayerFromTeam({
    required String teamId,
    required int playerId,
  });

  /// Sets the captain (2x points multiplier).
  Future<FantasyTeamEntity> setCaptain({
    required String teamId,
    required int playerId,
  });

  /// Sets the vice captain (1.5x points multiplier fallback).
  Future<FantasyTeamEntity> setViceCaptain({
    required String teamId,
    required int playerId,
  });

  /// Watches the global leaderboard.
  Stream<List<LeaderboardEntryEntity>> watchGlobalLeaderboard({int limit = 50});

  /// Watches the leaderboard for a specific league.
  Stream<List<LeaderboardEntryEntity>> watchLeagueLeaderboard(
    String leagueId, {
    int limit = 50,
  });

  /// Fetches the available player pool with prices and stats.
  Future<List<FantasyPlayerEntity>> getPlayerPool({String? position});

  /// Watches the available player pool for live stat/point updates.
  Stream<List<FantasyPlayerEntity>> watchPlayerPool({String? position});

  /// Applies match events for a player through the scoring engine and
  /// persists the updated stats + total points.
  Future<FantasyPlayerEntity> applyScoringEvent({
    required int playerId,
    required String eventType,
    int quantity = 1,
  });
}

