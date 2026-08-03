import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../home/domain/entities/match_entity.dart';
import '../../livescore/domain/repositories/livescore_repository.dart';
import '../../domain/entities/post_match_comparison_entity.dart';
import '../../domain/entities/prediction_entity.dart';
import '../../domain/entities/prediction_history_entity.dart';
import '../../domain/entities/user_vote_entity.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../datasources/prediction_local_data_source.dart';
import '../datasources/prediction_remote_data_source.dart';
import '../engine/comparison_engine.dart';

/// Implementation of [PredictionRepository].
///
/// Combines the statistical [PredictionRemoteDataSource] (Poisson engine)
/// with Firestore-backed [PredictionLocalDataSource] for history, votes,
/// and accuracy tracking.
class PredictionRepositoryImpl implements PredictionRepository {
  PredictionRepositoryImpl({
    required PredictionRemoteDataSource remoteDataSource,
    required PredictionLocalDataSource localDataSource,
    required LivescoreRepository livescoreRepository,
    required AuthRepository authRepository,
    ComparisonEngine? comparisonEngine,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _livescoreRepository = livescoreRepository,
        _authRepository = authRepository,
        _comparisonEngine = comparisonEngine ?? const ComparisonEngine();

  final PredictionRemoteDataSource _remoteDataSource;
  final PredictionLocalDataSource _localDataSource;
  final LivescoreRepository _livescoreRepository;
  final AuthRepository _authRepository;
  final ComparisonEngine _comparisonEngine;

  // ── Helpers ────────────────────────────────────────────────────────

  Future<String> _currentUserId() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw const AuthenticationException('You must be signed in to continue.');
    }
    return user.id;
  }

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
    if (e is AuthenticationException || message.contains('sign in')) {
      return Failure.serverFailure(message: message);
    }
    if (e is CacheException || message.contains('cache')) {
      return Failure.cacheFailure(message: message);
    }
    if (e is ServerException || message.contains('server')) {
      return Failure.serverFailure(message: message);
    }
    return Failure.unknown(message: message);
  }

  // ── PredictionRepository ───────────────────────────────────────────

  @override
  Future<MatchPredictionEntity> getPredictionForMatch(int matchId) async {
    return _safeCall(() async {
      // Fetch the match detail from the live scores provider.
      final detail = await _livescoreRepository.getMatchDetail(matchId);
      final match = detail.match;

      // Derive form weights from the match statistics when available.
      final homeForm = _formFromStats(detail.statistics, isHome: true);
      final awayForm = _formFromStats(detail.statistics, isHome: false);

      return _remoteDataSource.generatePrediction(
        match: match,
        homeForm: homeForm,
        awayForm: awayForm,
      );
    });
  }

  /// Derives a simple 0-1 form weight from match statistics.
  double _formFromStats(
    List<dynamic> statistics, {
    required bool isHome,
  }) {
    // The statistics list is typed as List<MatchStatisticEntity> in the
    // domain layer; we use a generic approach here to avoid tight coupling.
    // A positive value indicates stronger attacking output.
    double weight = 0.0;
    for (final stat in statistics) {
      final label = stat.toString().toLowerCase();
      if (label.contains('possession')) {
        final value = isHome
            ? _extractNumeric(stat.toString(), 'home')
            : _extractNumeric(stat.toString(), 'away');
        weight += (value - 50) / 50; // -1 to +1
      }
      if (label.contains('shots on target')) {
        final value = isHome
            ? _extractNumeric(stat.toString(), 'home')
            : _extractNumeric(stat.toString(), 'away');
        weight += value / 10; // 0 to ~1
      }
    }
    return weight.clamp(-1.0, 1.0).toDouble();
  }

  double _extractNumeric(String text, String side) {
    // Best-effort numeric extraction from the stat's string representation.
    final match = RegExp('$side[^0-9]*([0-9.]+)').firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  @override
  Future<List<PredictionHistoryEntity>> getPredictionHistory({
    String? userId,
    int limit = 50,
  }) async {
    return _safeCall(() async {
      final uid = userId ?? await _currentUserId();
      return _localDataSource.getHistory(uid, limit: limit);
    });
  }

  @override
  Future<void> savePredictionToHistory({
    required String userId,
    required MatchPredictionEntity prediction,
    DateTime? matchDate,
  }) async {
    return _safeCall(() async {
      await _localDataSource.saveHistory(
        userId: userId,
        prediction: prediction,
        matchDate: matchDate,
      );
    });
  }

  @override
  Future<VoteCountsEntity> voteOnPrediction({
    required String predictionId,
    required String userId,
    required String vote,
  }) async {
    return _safeCall(() async {
      return _localDataSource.voteOnPrediction(
        predictionId: predictionId,
        userId: userId,
        vote: vote,
      );
    });
  }

  @override
  Future<(VoteCountsEntity, String?)> getVoteState({
    required String predictionId,
    required String userId,
  }) async {
    return _safeCall(() async {
      return _localDataSource.getVoteState(
        predictionId: predictionId,
        userId: userId,
      );
    });
  }

  @override
  Future<PostMatchComparisonEntity> compareWithResult({
    required MatchPredictionEntity prediction,
    required int actualHomeScore,
    required int actualAwayScore,
  }) async {
    return _safeCall(() async {
      return _comparisonEngine.compare(
        prediction: prediction,
        actualHomeScore: actualHomeScore,
        actualAwayScore: actualAwayScore,
      );
    });
  }

  @override
  Future<AccuracyStatsEntity> getAccuracyStats({String? userId}) async {
    return _safeCall(() async {
      final uid = userId ?? await _currentUserId();
      return _localDataSource.getAccuracyStats(uid);
    });
  }

  @override
  Future<void> resolvePrediction({
    required String historyId,
    required bool isCorrect,
  }) async {
    return _safeCall(() async {
      final uid = await _currentUserId();
      await _localDataSource.resolvePrediction(
        historyId: historyId,
        userId: uid,
        isCorrect: isCorrect,
      );
    });
  }
}
