import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/fixture_entity.dart';
import '../../domain/entities/heatmap_entity.dart';
import '../../domain/entities/lineup_entity.dart';
import '../../domain/entities/match_detail_entity.dart';
import '../../domain/entities/match_statistics_entity.dart';
import '../../domain/entities/standings_entity.dart';
import '../../domain/repositories/livescore_repository.dart';
import '../datasources/live_update_stream.dart';
import '../datasources/livescore_remote_data_source.dart';

/// Implementation of [LivescoreRepository] combining remote data source
/// and the real-time update stream.
class LivescoreRepositoryImpl implements LivescoreRepository {
  LivescoreRepositoryImpl({
    required LivescoreRemoteDataSource remoteDataSource,
    LiveUpdateStream? liveUpdateStream,
  })  : _remoteDataSource = remoteDataSource,
        _liveUpdateStream = liveUpdateStream;

  final LivescoreRemoteDataSource _remoteDataSource;
  LiveUpdateStream? _liveUpdateStream;

  /// The pool interval used when lazily creating the live stream.
  static const Duration _defaultPollInterval = Duration(seconds: 30);

  LiveUpdateStream _ensureStream() {
    if (_liveUpdateStream == null) {
      _liveUpdateStream = LiveUpdateStream(
        repository: this,
        pollInterval: _defaultPollInterval,
      );
    }
    return _liveUpdateStream!;
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Future<T> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  Failure _mapException(Exception e) {
    final message = e.toString();
    if (e is NetworkException || message.contains('network')) {
      return Failure.networkFailure(message: message);
    }
    if (e is AuthenticationException || message.contains('API key')) {
      return Failure.serverFailure(message: message);
    }
    if (e is ServerException || message.contains('server')) {
      return Failure.serverFailure(message: message);
    }
    return Failure.unknown(message: message);
  }

  // ── LivescoreRepository ────────────────────────────────────────────

  @override
  Future<List<MatchEntity>> getLiveMatches() async {
    return _safeCall(() => _remoteDataSource.getLiveMatches());
  }

  @override
  Future<MatchDetailEntity> getMatchDetail(int matchId) async {
    return _safeCall(() => _remoteDataSource.getMatchDetail(matchId));
  }

  @override
  Future<List<MatchEventEntity>> getMatchTimeline(int matchId) async {
    return _safeCall(() => _remoteDataSource.getMatchTimeline(matchId));
  }

  @override
  Future<MatchLineupEntity> getMatchLineups(int matchId) async {
    return _safeCall(() => _remoteDataSource.getMatchLineups(matchId));
  }

  @override
  Future<List<MatchStatisticEntity>> getMatchStatistics(int matchId) async {
    return _safeCall(() => _remoteDataSource.getMatchStatistics(matchId));
  }

  @override
  Future<List<StandingsRowEntity>> getStandings(int competitionId) async {
    return _safeCall(() => _remoteDataSource.getStandings(competitionId));
  }

  @override
  Future<List<FixtureEntity>> getFixtures(int competitionId) async {
    return _safeCall(() => _remoteDataSource.getFixtures(competitionId));
  }

  @override
  Future<List<HeatmapPointEntity>> getMatchHeatmap(int matchId) async {
    return _safeCall(() => _remoteDataSource.getMatchHeatmap(matchId));
  }

  @override
  Stream<List<MatchEntity>> watchLiveScores() {
    return _ensureStream().stream;
  }
}

