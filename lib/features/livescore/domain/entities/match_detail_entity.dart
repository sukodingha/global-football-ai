import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/match_entity.dart';
import 'heatmap_entity.dart';
import 'lineup_entity.dart';
import 'match_statistics_entity.dart';
import 'match_timeline_entity.dart';

/// Full detail for a single match, including timeline, lineups,
/// statistics, and heat map data.
class MatchDetailEntity extends Equatable {
  const MatchDetailEntity({
    required this.match,
    this.timeline = const [],
    this.lineups,
    this.statistics = const [],
    this.homeHeatmap = const [],
    this.awayHeatmap = const [],
    this.failure,
  });

  /// The core match entity.
  final MatchEntity match;

  /// Match events timeline.
  final List<MatchEventEntity> timeline;

  /// Lineups for both teams.
  final MatchLineupEntity? lineups;

  /// Advanced statistics.
  final List<MatchStatisticEntity> statistics;

  /// Heat map points for the home team.
  final List<HeatmapPointEntity> homeHeatmap;

  /// Heat map points for the away team.
  final List<HeatmapPointEntity> awayHeatmap;

  /// Optional failure when a sub-section failed to load.
  final Failure? failure;

  @override
  List<Object?> get props => [
        match,
        timeline,
        lineups,
        statistics,
        homeHeatmap,
        awayHeatmap,
        failure,
      ];
}
