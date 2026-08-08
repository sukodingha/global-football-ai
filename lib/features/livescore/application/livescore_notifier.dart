import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../home/domain/entities/match_entity.dart';
import '../domain/entities/fixture_entity.dart';
import '../domain/entities/heatmap_entity.dart';
import '../domain/entities/lineup_entity.dart';
import '../domain/entities/match_detail_entity.dart';
import '../domain/entities/match_statistics_entity.dart';
import '../domain/entities/match_timeline_entity.dart';
import '../domain/entities/standings_entity.dart';
import '../domain/repositories/livescore_repository.dart';
import 'livescore_state.dart';

/// Riverpod controller for the Live Scores feature.
///
/// Manages live match lists (with real-time updates), match detail,
/// timeline, lineups, statistics, standings, fixtures, and heat maps.
class LivescoreNotifier extends StateNotifier<LivescoreState> {
  LivescoreNotifier({required LivescoreRepository repository})
      : _repository = repository,
        super(const LivescoreInitial());

  final LivescoreRepository _repository;

  StreamSubscription<List<MatchEntity>>? _liveSubscription;

  /// Loads live matches and starts the real-time update stream.
  Future<void> loadLiveMatches() async {
    state = const LivescoreLoading();
    try {
      final matches = await _repository.getLiveMatches();
      state = LivescoreLoaded(liveMatches: matches, lastUpdated: DateTime.now());
      _startLiveUpdates();
    } on Failure catch (f) {
      state = LivescoreError(message: f.message);
    } catch (_) {
      state = const LivescoreError(
        message: 'Unable to load live scores. Please try again.',
      );
    }
  }

  void _startLiveUpdates() {
    _liveSubscription?.cancel();
    _liveSubscription = _repository.watchLiveScores().listen(
      (matches) {
        if (state is LivescoreLoaded) {
          state = (state as LivescoreLoaded).copyWith(
            liveMatches: matches,
            lastUpdated: DateTime.now(),
            stale: false,
          );
        }
      },
      onError: (Object error) {
        if (state is LivescoreLoaded) {
          state = (state as LivescoreLoaded).copyWith(stale: true);
        }
      },
    );
  }

  /// Fetches the full detail for a match and populates sub-sections.
  Future<void> loadMatchDetail(int matchId) async {
    state = const LivescoreLoading();
    try {
      final detail = await _repository.getMatchDetail(matchId);
      state = LivescoreLoaded(
        liveMatches: _currentLiveMatches,
        matchDetail: detail,
        timeline: detail.timeline,
        lineups: detail.lineups,
        statistics: detail.statistics,
        homeHeatmap: detail.homeHeatmap,
        awayHeatmap: detail.awayHeatmap,
        lastUpdated: DateTime.now(),
      );
    } on Failure catch (f) {
      state = LivescoreError(message: f.message);
    } catch (_) {
      state = const LivescoreError(
        message: 'Unable to load match details. Please try again.',
      );
    }
  }

  List<MatchEntity> get _currentLiveMatches {
    final s = state;
    if (s is LivescoreLoaded) {
      return s.liveMatches;
    }
    return const [];
  }

  /// Fetches the match timeline events.
  Future<void> loadTimeline(int matchId) async {
    try {
      final timeline = await _repository.getMatchTimeline(matchId);
      _update((s) => s.copyWith(timeline: timeline));
    } on Failure catch (f) {
      _error(f.message);
    }
  }

  /// Fetches the lineups for a match.
  Future<void> loadLineups(int matchId) async {
    try {
      final lineups = await _repository.getMatchLineups(matchId);
      _update((s) => s.copyWith(lineups: lineups));
    } on Failure catch (f) {
      _error(f.message);
    }
  }

  /// Fetches advanced statistics for a match.
  Future<void> loadStatistics(int matchId) async {
    try {
      final statistics = await _repository.getMatchStatistics(matchId);
      _update((s) => s.copyWith(statistics: statistics));
    } on Failure catch (f) {
      _error(f.message);
    }
  }

  /// Fetches standings for a competition.
  Future<void> loadStandings(int competitionId) async {
    try {
      final standings = await _repository.getStandings(competitionId);
      _update((s) => s.copyWith(standings: standings));
    } on Failure catch (f) {
      _error(f.message);
    }
  }

  /// Fetches fixtures for a competition.
  Future<void> loadFixtures(int competitionId) async {
    try {
      final fixtures = await _repository.getFixtures(competitionId);
      _update((s) => s.copyWith(fixtures: fixtures));
    } on Failure catch (f) {
      _error(f.message);
    }
  }

  /// Fetches the heat map for a match.
  Future<void> loadHeatmap(int matchId) async {
    try {
      final points = await _repository.getMatchHeatmap(matchId);
      _update((s) => s.copyWith(homeHeatmap: points, awayHeatmap: points));
    } on Failure catch (f) {
      _error(f.message);
    }
  }

  void _update(LivescoreLoaded Function(LivescoreLoaded) transform) {
    final s = state;
    if (s is LivescoreLoaded) {
      state = transform(s);
    }
  }

  void _error(String message) {
    if (state is! LivescoreError) {
      state = LivescoreError(message: message);
    }
  }

  /// Clears any error state, returning to the loaded state.
  void clearError() {
    if (state is LivescoreError) {
      state = LivescoreLoaded(liveMatches: _currentLiveMatches);
    }
  }

  @override
  void dispose() {
    _liveSubscription?.cancel();
    super.dispose();
  }
}
