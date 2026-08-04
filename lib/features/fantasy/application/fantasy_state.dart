import '../domain/entities/fantasy_league_entity.dart';
import '../domain/entities/fantasy_player_entity.dart';
import '../domain/entities/fantasy_team_entity.dart';
import '../domain/entities/leaderboard_entry_entity.dart';

/// Immutable state for the fantasy football feature.
sealed class FantasyState {
  const FantasyState();
}

/// Initial state before the user has been resolved.
class FantasyInitial extends FantasyState {
  const FantasyInitial();
}

/// Loading state while initial data is fetched.
class FantasyLoading extends FantasyState {
  const FantasyLoading();
}

/// Loaded state with the user's leagues, teams, leaderboards and player pool.
class FantasyLoaded extends FantasyState {
  const FantasyLoaded({
    this.leagues = const [],
    this.publicLeagues = const [],
    this.selectedLeague,
    this.myTeams = const [],
    this.currentTeam,
    this.playerPool = const [],
    this.globalLeaderboard = const [],
    this.leagueLeaderboard = const [],
    this.transfersEnabled = true,
    this.busy = false,
    this.error,
  });

  /// Leagues the user has joined.
  final List<FantasyLeagueEntity> leagues;

  /// Discoverable public leagues for the join screen.
  final List<FantasyLeagueEntity> publicLeagues;

  final FantasyLeagueEntity? selectedLeague;

  /// The user's teams indexed by league id.
  final List<FantasyTeamEntity> myTeams;

  /// The currently selected/active team.
  final FantasyTeamEntity? currentTeam;

  /// The full player pool available for transfers.
  final List<FantasyPlayerEntity> playerPool;

  final List<LeaderboardEntryEntity> globalLeaderboard;
  final List<LeaderboardEntryEntity> leagueLeaderboard;

  /// Whether transfers/roster changes are currently allowed.
  final bool transfersEnabled;

  /// Whether a write operation is in flight.
  final bool busy;

  /// A surfaceable error message from the last write operation.
  final String? error;

  bool get hasTeams => myTeams.isNotEmpty;
  bool get hasSelectedLeague => selectedLeague != null;

  FantasyTeamEntity? teamForLeague(String leagueId) {
    for (final t in myTeams) {
      if (t.leagueId == leagueId) return t;
    }
    return null;
  }

  FantasyLoaded copyWith({
    List<FantasyLeagueEntity>? leagues,
    List<FantasyLeagueEntity>? publicLeagues,
    FantasyLeagueEntity? selectedLeague,
    bool clearSelectedLeague = false,
    List<FantasyTeamEntity>? myTeams,
    FantasyTeamEntity? currentTeam,
    List<FantasyPlayerEntity>? playerPool,
    List<LeaderboardEntryEntity>? globalLeaderboard,
    List<LeaderboardEntryEntity>? leagueLeaderboard,
    bool? transfersEnabled,
    bool? busy,
    String? error,
    bool clearError = false,
  }) {
    return FantasyLoaded(
      leagues: leagues ?? this.leagues,
      publicLeagues: publicLeagues ?? this.publicLeagues,
      selectedLeague: clearSelectedLeague ? null : selectedLeague ?? this.selectedLeague,
      myTeams: myTeams ?? this.myTeams,
      currentTeam: currentTeam ?? this.currentTeam,
      playerPool: playerPool ?? this.playerPool,
      globalLeaderboard: globalLeaderboard ?? this.globalLeaderboard,
      leagueLeaderboard: leagueLeaderboard ?? this.leagueLeaderboard,
      transfersEnabled: transfersEnabled ?? this.transfersEnabled,
      busy: busy ?? this.busy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Error state with a user-safe message.
class FantasyError extends FantasyState {
  const FantasyError({required this.message});
  final String message;
}

