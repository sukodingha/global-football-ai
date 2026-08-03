import '../../home/domain/entities/match_entity.dart';
import '../domain/entities/fixture_entity.dart';
import '../domain/entities/heatmap_entity.dart';
import '../domain/entities/lineup_entity.dart';
import '../domain/entities/match_detail_entity.dart';
import '../domain/entities/match_statistics_entity.dart';
import '../domain/entities/match_timeline_entity.dart';
import '../domain/entities/standings_entity.dart';

/// Immutable state for the Live Scores feature.
sealed class LivescoreState {
  const LivescoreState();
}

/// Initial state.
class LivescoreInitial extends LivescoreState {
  const LivescoreInitial();
}

/// Loading state for a specific operation.
class LivescoreLoading extends LivescoreState {
  const LivescoreLoading();
}

/// Loaded state with all live-score data.
class LivescoreLoaded extends LivescoreState {
  const LivescoreLoaded({
    required this.liveMatches,
    this.matchDetail,
    this.timeline = const [],
    this.lineups,
    this.statistics = const [],
    this.standings = const [],
    this.fixtures = const [],
    this.homeHeatmap = const [],
    this.awayHeatmap = const [],
    this.lastUpdated,
    this.stale = false,
  });

  final List<MatchEntity> liveMatches;
  final MatchDetailEntity? matchDetail;
  final List<MatchEventEntity> timeline;
  final MatchLineupEntity? lineups;
  final List<MatchStatisticEntity> statistics;
  final List<StandingsRowEntity> standings;
  final List<FixtureEntity> fixtures;
  final List<HeatmapPointEntity> homeHeatmap;
  final List<HeatmapPointEntity> awayHeatmap;
  final DateTime? lastUpdated;
  final bool stale;

  LivescoreLoaded copyWith({
    List<MatchEntity>? liveMatches,
    MatchDetailEntity? matchDetail,
    List<MatchEventEntity>? timeline,
    MatchLineupEntity? lineups,
    List<MatchStatisticEntity>? statistics,
    List<StandingsRowEntity>? standings,
    List<FixtureEntity>? fixtures,
    List<HeatmapPointEntity>? homeHeatmap,
    List<HeatmapPointEntity>? awayHeatmap,
    DateTime? lastUpdated,
    bool? stale,
  }) {
    return LivescoreLoaded(
      liveMatches: liveMatches ?? this.liveMatches,
      matchDetail: matchDetail ?? this.matchDetail,
      timeline: timeline ?? this.timeline,
      lineups: lineups ?? this.lineups,
      statistics: statistics ?? this.statistics,
      standings: standings ?? this.standings,
      fixtures: fixtures ?? this.fixtures,
      homeHeatmap: homeHeatmap ?? this.homeHeatmap,
      awayHeatmap: awayHeatmap ?? this.awayHeatmap,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      stale: stale ?? this.stale,
    );
  }
}

/// Error state with a user-safe message.
class LivescoreError extends LivescoreState {
  const LivescoreError({required this.message});
  final String message;
}

