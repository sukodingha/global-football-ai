import '../../core/errors/failures.dart';
import '../../features/home/domain/entities/match_entity.dart';
import '../../features/livescore/domain/entities/fixture_entity.dart';
import '../../features/livescore/domain/entities/heatmap_entity.dart';
import '../../features/livescore/domain/entities/lineup_entity.dart';
import '../../features/livescore/domain/entities/match_detail_entity.dart';
import '../../features/livescore/domain/entities/match_statistics_entity.dart';
import '../../features/livescore/domain/entities/standings_entity.dart';

/// Abstraction over the football data provider (e.g. football-data.org,
/// API-Football, or a future mock provider).
///
/// Implementations of this interface are consumed by the
/// [LivescoreRemoteDataSource]. Swapping providers at runtime is done by
/// changing the concrete provider wired in dependency injection, without
/// touching any domain or presentation code.
abstract class FootballDataProvider {
  /// Name of the provider, used for logging/debugging.
  String get name;

  /// Fetches live matches currently in play.
  Future<List<MatchEntity>> getLiveMatches();

  /// Fetches a single match's full detail by id.
  Future<MatchDetailEntity> getMatchDetail(int matchId);

  /// Fetches the match timeline (events) for a match.
  Future<List<MatchEventEntity>> getMatchTimeline(int matchId);

  /// Fetches the lineups for a match.
  Future<MatchLineupEntity> getMatchLineups(int matchId);

  /// Fetches the advanced statistics for a match.
  Future<List<MatchStatisticEntity>> getMatchStatistics(int matchId);

  /// Fetches the standings for a competition.
  Future<List<StandingsRowEntity>> getStandings(int competitionId);

  /// Fetches the fixtures for a team or competition.
  Future<List<FixtureEntity>> getFixtures(int competitionId);

  /// Fetches the heat map data for a match.
  Future<List<HeatmapPointEntity>> getMatchHeatmap(int matchId);
}

/// Result wrapper for provider operations.
class ProviderResult<T> {
  const ProviderResult._(this.value, this.failure);
  const ProviderResult.success(T value) : this._(value, null);
  const ProviderResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}
