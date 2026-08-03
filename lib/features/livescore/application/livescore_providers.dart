import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/entities/match_entity.dart';
import '../domain/entities/fixture_entity.dart';
import '../domain/entities/heatmap_entity.dart';
import '../domain/entities/lineup_entity.dart';
import '../domain/entities/match_detail_entity.dart';
import '../domain/entities/match_statistics_entity.dart';
import '../domain/entities/standings_entity.dart';
import '../data/dependency_injection.dart';
import 'livescore_notifier.dart';
import 'livescore_state.dart';

/// Provider for the [LivescoreNotifier] controller.
final livescoreNotifierProvider =
    StateNotifierProvider<LivescoreNotifier, LivescoreState>((ref) {
  final repository = ref.watch(livescoreRepositoryProvider);
  return LivescoreNotifier(repository: repository);
});

/// Selector for live matches.
final liveMatchesProvider = Provider<List<MatchEntity>>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.liveMatches;
  }
  return const [];
});

/// Selector for the currently selected match detail.
final matchDetailProvider = Provider<MatchDetailEntity?>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.matchDetail;
  }
  return null;
});

/// Selector for the match timeline.
final timelineProvider = Provider<List<MatchEventEntity>>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.timeline;
  }
  return const [];
});

/// Selector for match lineups.
final lineupsProvider = Provider<MatchLineupEntity?>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.lineups;
  }
  return null;
});

/// Selector for match statistics.
final statisticsProvider = Provider<List<MatchStatisticEntity>>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.statistics;
  }
  return const [];
});

/// Selector for standings.
final standingsProvider = Provider<List<StandingsRowEntity>>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.standings;
  }
  return const [];
});

/// Selector for fixtures.
final fixturesProvider = Provider<List<FixtureEntity>>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.fixtures;
  }
  return const [];
});

/// Selector for home heat map points.
final homeHeatmapProvider = Provider<List<HeatmapPointEntity>>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.homeHeatmap;
  }
  return const [];
});

/// Selector for away heat map points.
final awayHeatmapProvider = Provider<List<HeatmapPointEntity>>((ref) {
  final state = ref.watch(livescoreNotifierProvider);
  if (state is LivescoreLoaded) {
    return state.awayHeatmap;
  }
  return const [];
});
