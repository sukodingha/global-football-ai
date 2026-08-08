import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/live_scores_cache_service.dart';
import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/fixture_entity.dart';
import '../../domain/entities/heatmap_entity.dart';
import '../../domain/entities/lineup_entity.dart';
import '../../domain/entities/match_detail_entity.dart';
import '../../domain/entities/match_statistics_entity.dart';
import '../../domain/entities/match_timeline_entity.dart';
import '../../domain/entities/standings_entity.dart';
import '../../domain/repositories/livescore_repository.dart';
import '../datasources/live_update_stream.dart';
import '../datasources/livescore_remote_data_source.dart';

/// Implementation of [LivescoreRepository] combining remote data source
/// and the real-time update stream.
///
/// Live matches are cached locally via [LiveScoresCacheService] so the live
/// scores UI can render instantly from cache while fresh data is fetched.
class LivescoreRepositoryImpl implements LivescoreRepository {
  LivescoreRepositoryImpl({
    required LivescoreRemoteDataSource remoteDataSource,
    LiveUpdateStream? liveUpdateStream,
    LiveScoresCacheService? liveScoresCache,
  })  : _remoteDataSource = remoteDataSource,
        _liveUpdateStream = liveUpdateStream,
        _liveScoresCache = liveScoresCache;

  final LivescoreRemoteDataSource _remoteDataSource;
  final LiveScoresCacheService? _liveScoresCache;
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
  Future<List<MatchEntity>> getLiveMatches({bool refresh = false}) async {
    final cache = _liveScoresCache;

    // Serve from cache first unless a refresh is explicitly requested.
    if (!refresh && cache != null) {
      final cached = await cache.getCachedLiveMatches();
      if (cached != null && cached.isNotEmpty) {
        try {
          return cached.map(_matchFromJson).toList();
        } catch (_) {
          // Fall through to remote fetch if cache is corrupt.
        }
      }
    }

    return _safeCall(() async {
      final entities = await _remoteDataSource.getLiveMatches();

      // Persist the fresh live scores for offline / instant rendering.
      if (cache != null) {
        await cache.cacheLiveMatches(
          entities.map(_matchToJson).toList(),
        );
      }
      return entities;
    });
  }

  /// Serializes a [MatchEntity] to a JSON map for caching.
  Map<String, dynamic> _matchToJson(MatchEntity match) {
    return {
      'id': match.id,
      'status': match.status.name,
      'utcDate': match.utcDate.toIso8601String(),
      'homeTeam': {
        'id': match.homeTeam.id,
        'name': match.homeTeam.name,
        'shortName': match.homeTeam.shortName,
        'crest': match.homeTeam.crest,
      },
      'awayTeam': {
        'id': match.awayTeam.id,
        'name': match.awayTeam.name,
        'shortName': match.awayTeam.shortName,
        'crest': match.awayTeam.crest,
      },
      'homeScore': match.homeScore,
      'awayScore': match.awayScore,
      'competitionName': match.competitionName,
      'competitionEmblem': match.competitionEmblem,
      'minute': match.minute,
    };
  }

  /// Deserializes a cached JSON map into a [MatchEntity].
  MatchEntity _matchFromJson(Map<String, dynamic> json) {
    final homeRaw = json['homeTeam'] as Map<String, dynamic>? ?? const {};
    final awayRaw = json['awayTeam'] as Map<String, dynamic>? ?? const {};
    return MatchEntity(
      id: json['id'] as int? ?? 0,
      status: MatchStatus.fromApi(json['status'] as String? ?? ''),
      utcDate:
          DateTime.tryParse(json['utcDate'] as String? ?? '') ?? DateTime.now(),
      homeTeam: TeamMini(
        id: homeRaw['id'] as int? ?? 0,
        name: homeRaw['name'] as String? ?? 'Home',
        shortName: homeRaw['shortName'] as String?,
        crest: homeRaw['crest'] as String?,
      ),
      awayTeam: TeamMini(
        id: awayRaw['id'] as int? ?? 0,
        name: awayRaw['name'] as String? ?? 'Away',
        shortName: awayRaw['shortName'] as String?,
        crest: awayRaw['crest'] as String?,
      ),
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      competitionName: json['competitionName'] as String?,
      competitionEmblem: json['competitionEmblem'] as String?,
      minute: json['minute'] as int?,
    );
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

