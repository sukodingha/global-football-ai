import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/news_cache_service.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/competition_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/prediction_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/article_model.dart';

/// Implementation of [HomeRepository] backed by the football-data.org API.
///
/// The news feed is cached locally via [NewsCacheService] so it renders
/// instantly offline and reduces redundant network calls.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required HomeRemoteDataSource remoteDataSource,
    NewsCacheService? newsCache,
  })  : _remoteDataSource = remoteDataSource,
        _newsCache = newsCache;

  final HomeRemoteDataSource _remoteDataSource;
  final NewsCacheService? _newsCache;

  // ── Helpers ────────────────────────────────────────────────────────

  /// Executes a remote call, mapping any exception to a [Failure].
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

  // ── HomeRepository ─────────────────────────────────────────────────

  @override
  Future<List<MatchEntity>> getLiveMatches() async {
    return _safeCall(() async {
      final models = await _remoteDataSource.getLiveMatches();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<List<MatchEntity>> getUpcomingMatches() async {
    return _safeCall(() async {
      final models = await _remoteDataSource.getUpcomingMatches();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<List<MatchEntity>> getFinishedMatches() async {
    return _safeCall(() async {
      final models = await _remoteDataSource.getFinishedMatches();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<List<CompetitionEntity>> getFeaturedCompetitions() async {
    return _safeCall(() async {
      final models = await _remoteDataSource.getFeaturedCompetitions();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<List<MatchEntity>> getTrendingMatches() async {
    return _safeCall(() async {
      final models = await _remoteDataSource.getTrendingMatches();
      return models.map((m) => m.toEntity()).toList();
    });
  }

@override
  Future<List<ArticleEntity>> getNews({bool refresh = false}) async {
    final cache = _newsCache;

    // Serve from cache first when present (unless a refresh is requested).
    if (!refresh && cache != null) {
      final cached = await cache.getCachedNews('home');
      if (cached != null) {
        try {
          return cached
              .map(ArticleModel.fromJson)
              .map((m) => m.toEntity())
              .toList();
        } catch (_) {
          // Fall through to remote fetch if cache is corrupt.
        }
      }
    }

    return _safeCall(() async {
      final models = await _remoteDataSource.getNews();
      final entities = models.map((m) => m.toEntity()).toList();

      // Persist the fresh feed to cache for offline / instant load.
      if (cache != null) {
        await cache.cacheNews(
          'home',
          models.map((m) => m.toJson()).toList(),
        );
      }
      return entities;
    });
  }

  @override
  Future<PredictionSummaryEntity> getTodayPredictions() async {
    return _safeCall(() async {
      final model = await _remoteDataSource.getTodayPredictions();
      return model.toEntity();
    });
  }

  @override
  Future<PlayerEntity> getPlayerOfTheDay() async {
    return _safeCall(() async {
      final model = await _remoteDataSource.getPlayerOfTheDay();
      return model.toEntity();
    });
  }
}
