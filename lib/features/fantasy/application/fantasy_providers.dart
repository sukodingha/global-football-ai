import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/dependency_injection.dart';
import '../domain/entities/fantasy_league_entity.dart';
import '../domain/entities/fantasy_player_entity.dart';
import '../domain/entities/fantasy_team_entity.dart';
import '../domain/entities/leaderboard_entry_entity.dart';
import '../domain/entities/scoring_rule_entity.dart';
import 'fantasy_notifier.dart';
import 'fantasy_state.dart';

/// Provider for the [FantasyNotifier] controller.
final fantasyNotifierProvider =
    StateNotifierProvider<FantasyNotifier, FantasyState>((ref) {
  final repository = ref.watch(fantasyRepositoryProvider);
  return FantasyNotifier(repository: repository);
});

/// Initialises the fantasy dashboard when first read.
final fantasyDashboardControllerProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    ref.read(fantasyNotifierProvider.notifier).loadDashboard(userId: user.id);
  }
  return null;
});

// ─── Selectors ────────────────────────────────────────────────────────

/// The user's league list.
final myLeaguesProvider = Provider<List<FantasyLeagueEntity>>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.leagues;
  return const [];
});

/// Publicly discoverable leagues.
final publicLeaguesProvider = Provider<List<FantasyLeagueEntity>>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.publicLeagues;
  return const [];
});

/// The currently selected league.
final selectedLeagueProvider = Provider<FantasyLeagueEntity?>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.selectedLeague;
  return null;
});

/// The user's current team in the selected league.
final currentTeamProvider = Provider<FantasyTeamEntity?>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.currentTeam;
  return null;
});

/// The user's teams across leagues.
final myTeamsProvider = Provider<List<FantasyTeamEntity>>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.myTeams;
  return const [];
});

/// Full player pool (all eligible players with prices).
final playerPoolProvider = Provider<List<FantasyPlayerEntity>>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.playerPool;
  return const [];
});

/// Global fantasy leaderboard.
final globalLeaderboardProvider =
    Provider<List<LeaderboardEntryEntity>>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.globalLeaderboard;
  return const [];
});

/// League-specific leaderboard.
final leagueLeaderboardProvider =
    Provider<List<LeaderboardEntryEntity>>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.leagueLeaderboard;
  return const [];
});

/// Whether the fantasy notifier is busy writing.
final fantasyBusyProvider = Provider<bool>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.busy;
  return false;
});

/// Error message surfaced from the last write operation.
final fantasyErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(fantasyNotifierProvider);
  if (state is FantasyLoaded) return state.error;
  return null;
});

/// The static list of scoring rules for display.
final scoringRulesProvider = Provider<List<ScoringRuleEntity>>((ref) {
  return FantasyScoringRules.all;
});

