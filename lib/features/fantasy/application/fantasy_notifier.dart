import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/fantasy_league_entity.dart';
import '../domain/entities/fantasy_player_entity.dart';
import '../domain/entities/fantasy_team_entity.dart';
import '../domain/entities/leaderboard_entry_entity.dart';
import '../domain/repositories/fantasy_repository.dart';
import 'fantasy_state.dart';

/// Riverpod controller for the fantasy football feature.
///
/// Owns the user's leagues, current team, player pool and real-time
/// leaderboard subscriptions. All roster mutations are routed through the
/// repository which enforces budget and squad constraints.
class FantasyNotifier extends StateNotifier<FantasyState> {
  FantasyNotifier({required FantasyRepository repository})
      : _repository = repository,
        super(const FantasyInitial());

  final FantasyRepository _repository;

  StreamSubscription<List<LeaderboardEntryEntity>>? _globalSub;
  StreamSubscription<List<LeaderboardEntryEntity>>? _leagueSub;
  StreamSubscription<FantasyTeamEntity>? _teamSub;

  String? _userId;

  /// Initialises the fantasy hub for [userId].
  Future<void> loadDashboard({required String userId}) async {
    _userId = userId;
    state = const FantasyLoading();
    try {
      final leagues = await _repository.getLeaguesForUser(userId);
      final publicLeagues = await _repository.getPublicLeagues();
      final pool = await _repository.getPlayerPool();

      // Load the user's team for the first league (if any).
      FantasyTeamEntity? currentTeam;
      if (leagues.isNotEmpty) {
        currentTeam = await _repository.getTeamInLeague(
          userId: userId,
          leagueId: leagues.first.id,
        );
        if (currentTeam != null) {
          _startTeamSubscription(currentTeam);
        }
        _startLeagueLeaderboard(leagues.first.id);
      }

      state = FantasyLoaded(
        leagues: leagues,
        publicLeagues: publicLeagues,
        selectedLeague: leagues.isNotEmpty ? leagues.first : null,
        currentTeam: currentTeam,
        myTeams: currentTeam != null ? [currentTeam] : const [],
        playerPool: pool,
      );

      _startGlobalLeaderboard();
    } on Failure catch (f) {
      state = FantasyError(message: f.message);
    } catch (_) {
      state = const FantasyError(
        message: 'Unable to load your fantasy dashboard.',
      );
    }
  }

  /// Refreshes public leagues and player pool without resetting state.
  Future<void> refreshExplorer() async {
    if (state is! FantasyLoaded) return;
    try {
      final loaded = state as FantasyLoaded;
      final userId = _userId;
      final publicLeagues = await _repository.getPublicLeagues();
      final pool = await _repository.getPlayerPool();
      state = loaded.copyWith(publicLeagues: publicLeagues, playerPool: pool);
      if (userId != null && loaded.leagues.isNotEmpty) {
        final leagues = await _repository.getLeaguesForUser(userId);
        state = (state as FantasyLoaded).copyWith(leagues: leagues);
      }
    } on Failure catch (f) {
      state = (state as FantasyLoaded).copyWith(error: f.message);
    } catch (_) {
      state = (state as FantasyLoaded).copyWith(
        error: 'Unable to refresh the explorer.',
      );
    }
  }

  // ─── League actions ───────────────────────────────────────────────

  /// Creates a new league and joins it as the owner.
  Future<FantasyLeagueEntityResult> createLeague({
    required String name,
    required LeagueVisibility visibility,
    required String ownerId,
    String? description,
    String? teamName,
    double startBudget = 100,
  }) async {
    if (state is! FantasyLoaded) {
      return const FantasyLeagueEntityResult.failure(
        UnknownFailure('Fantasy hub is not ready yet.'),
      );
    }
    state = (state as FantasyLoaded).copyWith(busy: true, clearError: true);
    try {
      final league = await _repository.createLeague(
        CreateLeagueParams(
          name: name,
          visibility: visibility,
          ownerId: ownerId,
          description: description,
          startBudget: startBudget,
        ),
      );

      final team = await _repository.createTeam(
        name: teamName ?? '${name} FC',
        userId: ownerId,
        leagueId: league.id,
        budget: startBudget,
      );

      final loaded = state as FantasyLoaded;
      final leagues = [league, ...loaded.leagues];
      state = loaded.copyWith(
        leagues: leagues,
        selectedLeague: league,
        myTeams: [team, ...loaded.myTeams],
        currentTeam: team,
        busy: false,
      );
      _startTeamSubscription(team);
      _startLeagueLeaderboard(league.id);
      return const FantasyLeagueEntityResult.success();
    } on Failure catch (f) {
      state = (state as FantasyLoaded).copyWith(busy: false, error: f.message);
      return FantasyLeagueEntityResult.failure(f);
    } catch (_) {
      const f = UnknownFailure();
      state = (state as FantasyLoaded).copyWith(busy: false, error: 'Failed to create league.');
      return const FantasyLeagueEntityResult.failure(
        UnknownFailure('Failed to create league.'),
      );
    }
  }

  /// Joins a league by join code and creates a starter team.
  Future<FantasyLeagueEntityResult> joinLeague({
    required String code,
    required String userId,
    required String userName,
    required String teamName,
  }) async {
    if (state is! FantasyLoaded) {
      return const FantasyLeagueEntityResult.failure(
        UnknownFailure('Fantasy hub is not ready yet.'),
      );
    }
    state = (state as FantasyLoaded).copyWith(busy: true, clearError: true);
    try {
      final league = await _repository.joinLeagueByCode(
        JoinLeagueParams(
          code: code,
          userId: userId,
          userName: userName,
          teamName: teamName,
        ),
      );

      var team = await _repository.getTeamInLeague(
        userId: userId,
        leagueId: league.id,
      );
      team ??= await _repository.createTeam(
        name: teamName,
        userId: userId,
        leagueId: league.id,
        budget: league.startBudget,
      );

      final loaded = state as FantasyLoaded;
      final leagues = [league, ...loaded.leagues];
      state = loaded.copyWith(
        leagues: leagues,
        selectedLeague: league,
        myTeams: [team, ...loaded.myTeams],
        currentTeam: team,
        busy: false,
      );
      _startTeamSubscription(team);
      _startLeagueLeaderboard(league.id);
      return const FantasyLeagueEntityResult.success();
    } on Failure catch (f) {
      state = (state as FantasyLoaded).copyWith(busy: false, error: f.message);
      return FantasyLeagueEntityResult.failure(f);
    } catch (_) {
      state = (state as FantasyLoaded).copyWith(
        busy: false,
        error: 'Failed to join league.',
      );
      return const FantasyLeagueEntityResult.failure(
        UnknownFailure('Failed to join league.'),
      );
    }
  }

  /// Selects a league and loads its team + leaderboard.
  Future<void> selectLeague(String leagueId) async {
    if (state is! FantasyLoaded) return;
    final loaded = state as FantasyLoaded;
    try {
      final league = await _repository.getLeague(leagueId);
      final userId = _userId;
      FantasyTeamEntity? team;
      if (league.members.contains(userId) || league.ownerId == userId) {
        team = await _repository.getTeamInLeague(
          userId: userId ?? '',
          leagueId: leagueId,
        );
      }
      state = loaded.copyWith(
        selectedLeague: league,
        currentTeam: team,
      );
      if (team != null) _startTeamSubscription(team);
      _startLeagueLeaderboard(leagueId);
    } on Failure catch (f) {
      state = loaded.copyWith(error: f.message);
    } catch (_) {
      state = loaded.copyWith(error: 'Unable to load league.');
    }
  }

  // ─── Roster actions ───────────────────────────────────────────────

  /// Adds a player to the current team (budget-aware).
  Future<String?> addPlayer(FantasyPlayerEntity player) async {
    if (state is! FantasyLoaded) return 'Fantasy hub is not ready yet.';
    final loaded = state as FantasyLoaded;
    final team = loaded.currentTeam;
    if (team == null) return 'Create or join a league to build a team.';

    if (team.players.length >= 11) {
      return 'Squad full. Drop a player before signing a new one.';
    }
    if (team.containsPlayer(player.id)) return 'Player is already in your squad.';

    state = loaded.copyWith(busy: true, clearError: true);
    try {
      final updated = await _repository.addPlayerToTeam(
        teamId: team.id,
        player: player,
      );
      state = (state as FantasyLoaded).copyWith(
        currentTeam: updated,
        myTeams: _replaceTeam(updated),
        busy: false,
      );
      return null;
    } on Failure catch (f) {
      state = (state as FantasyLoaded).copyWith(busy: false, error: f.message);
      return f.message;
    }
  }

  /// Removes a player from the current team.
  Future<String?> removePlayer(int playerId) async {
    if (state is! FantasyLoaded) return 'Fantasy hub is not ready yet.';
    final loaded = state as FantasyLoaded;
    final team = loaded.currentTeam;
    if (team == null) return 'No team selected.';

    state = loaded.copyWith(busy: true, clearError: true);
    try {
      final updated = await _repository.removePlayerFromTeam(
        teamId: team.id,
        playerId: playerId,
      );
      state = (state as FantasyLoaded).copyWith(
        currentTeam: updated,
        myTeams: _replaceTeam(updated),
        busy: false,
      );
      return null;
    } on Failure catch (f) {
      state = (state as FantasyLoaded).copyWith(busy: false, error: f.message);
      return f.message;
    }
  }

  /// Assigns the captain (2x points multiplier).
  Future<String?> setCaptain(int playerId) async {
    return _setLeadership(playerId, isCaptain: true);
  }

  /// Assigns the vice captain (1.5x fallback multiplier).
  Future<String?> setViceCaptain(int playerId) async {
    return _setLeadership(playerId, isCaptain: false);
  }

  Future<String?> _setLeadership(int playerId, {required bool isCaptain}) async {
    if (state is! FantasyLoaded) return 'Fantasy hub is not ready yet.';
    final loaded = state as FantasyLoaded;
    final team = loaded.currentTeam;
    if (team == null) return 'No team selected.';

    state = loaded.copyWith(busy: true, clearError: true);
    try {
      final updated = isCaptain
          ? await _repository.setCaptain(teamId: team.id, playerId: playerId)
          : await _repository.setViceCaptain(teamId: team.id, playerId: playerId);
      state = (state as FantasyLoaded).copyWith(
        currentTeam: updated,
        myTeams: _replaceTeam(updated),
        busy: false,
      );
      return null;
    } on Failure catch (f) {
      state = (state as FantasyLoaded).copyWith(busy: false, error: f.message);
      return f.message;
    }
  }

  List<FantasyTeamEntity> _replaceTeam(FantasyTeamEntity updated) {
    final loaded = state as FantasyLoaded;
    return loaded.myTeams
        .map((t) => t.id == updated.id ? updated : t)
        .toList();
  }

  // ─── Subscriptions ────────────────────────────────────────────────

  void _startGlobalLeaderboard() {
    _globalSub?.cancel();
    _globalSub = _repository.watchGlobalLeaderboard().listen(
      (entries) {
        final s = state;
        if (s is FantasyLoaded) {
          state = s.copyWith(globalLeaderboard: entries);
        }
      },
      onError: (_) {},
    );
  }

  void _startLeagueLeaderboard(String leagueId) {
    _leagueSub?.cancel();
    _leagueSub = _repository.watchLeagueLeaderboard(leagueId).listen(
      (entries) {
        final s = state;
        if (s is FantasyLoaded) {
          state = s.copyWith(leagueLeaderboard: entries);
        }
      },
      onError: (_) {},
    );
  }

  void _startTeamSubscription(FantasyTeamEntity team) {
    _teamSub?.cancel();
    _teamSub = _repository.watchTeam(team.id).listen(
      (updated) {
        final s = state;
        if (s is FantasyLoaded) {
          state = s.copyWith(
            currentTeam: updated,
            myTeams: _replaceTeam(updated),
          );
        }
      },
      onError: (_) {},
    );
  }

  /// Stops all active streams.
  void stop() {
    _globalSub?.cancel();
    _leagueSub?.cancel();
    _teamSub?.cancel();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Lightweight result for league create/join operations.
class FantasyLeagueEntityResult {
  const FantasyLeagueEntityResult._(this.failure);
  const FantasyLeagueEntityResult.success() : this._(null);
  const FantasyLeagueEntityResult.failure(Failure failure) : this._(failure);

  final Failure? failure;
  bool get isSuccess => failure == null;
}

