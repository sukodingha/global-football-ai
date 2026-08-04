import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/match_entity.dart';
import '../entities/fixture_entity.dart';
import '../entities/heatmap_entity.dart';
import '../entities/lineup_entity.dart';
import '../entities/match_detail_entity.dart';
import '../entities/match_statistics_entity.dart';
import '../entities/standings_entity.dart';

/// Abstract contract for the live scores repository.
abstract class LivescoreRepository {
  /// Fetches live matches currently in play.
  ///
  /// When [refresh] is true, fresh data is always fetched from the network,
  /// bypassing the local cache.
  Future<List<MatchEntity>> getLiveMatches({bool refresh = false});

  /// Fetches a single match's full detail.
  Future<MatchDetailEntity> getMatchDetail(int matchId);

  /// Fetches the match timeline (events).
  Future<List<MatchEventEntity>> getMatchTimeline(int matchId);

  /// Fetches lineups for a match.
  Future<MatchLineupEntity> getMatchLineups(int matchId);

  /// Fetches advanced statistics for a match.
  Future<List<MatchStatisticEntity>> getMatchStatistics(int matchId);

  /// Fetches standings for a competition.
  Future<List<StandingsRowEntity>> getStandings(int competitionId);

  /// Fetches fixtures for a competition or team.
  Future<List<FixtureEntity>> getFixtures(int competitionId);

  /// Fetches heat map data for a match.
  Future<List<HeatmapPointEntity>> getMatchHeatmap(int matchId);

  /// Subscribes to real-time live score updates.
  Stream<List<MatchEntity>> watchLiveScores();
}

/// Result wrapper for livescore repository operations.
class LivescoreResult<T> {
  const LivescoreResult._(this.value, this.failure);
  const LivescoreResult.success(T value) : this._(value, null);
  const LivescoreResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}
