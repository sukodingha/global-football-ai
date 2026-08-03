import '../../../core/api/football_data_provider.dart';
import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/fixture_entity.dart';
import '../../domain/entities/heatmap_entity.dart';
import '../../domain/entities/lineup_entity.dart';
import '../../domain/entities/match_detail_entity.dart';
import '../../domain/entities/match_statistics_entity.dart';
import '../../domain/entities/standings_entity.dart';

/// Remote data source for the Live Scores feature.
///
/// Delegates all operations to a [FootballDataProvider]. This is the seam
/// where data providers can be swapped (football-data.org, API-Football,
/// mock, etc.) without affecting any other layer.
class LivescoreRemoteDataSource {
  const LivescoreRemoteDataSource({required FootballDataProvider provider})
      : _provider = provider;

  final FootballDataProvider _provider;

  /// The active provider name, for debugging/logging.
  String get providerName => _provider.name;

  Future<List<MatchEntity>> getLiveMatches() => _provider.getLiveMatches();

  Future<MatchDetailEntity> getMatchDetail(int matchId) =>
      _provider.getMatchDetail(matchId);

  Future<List<MatchEventEntity>> getMatchTimeline(int matchId) =>
      _provider.getMatchTimeline(matchId);

  Future<MatchLineupEntity> getMatchLineups(int matchId) =>
      _provider.getMatchLineups(matchId);

  Future<List<MatchStatisticEntity>> getMatchStatistics(int matchId) =>
      _provider.getMatchStatistics(matchId);

  Future<List<StandingsRowEntity>> getStandings(int competitionId) =>
      _provider.getStandings(competitionId);

  Future<List<FixtureEntity>> getFixtures(int competitionId) =>
      _provider.getFixtures(competitionId);

  Future<List<HeatmapPointEntity>> getMatchHeatmap(int matchId) =>
      _provider.getMatchHeatmap(matchId);
}

