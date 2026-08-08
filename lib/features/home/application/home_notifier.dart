import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../home/domain/entities/article_entity.dart';
import '../../home/domain/entities/competition_entity.dart';
import '../../home/domain/entities/match_entity.dart';
import '../../home/domain/entities/player_entity.dart';
import '../../home/domain/entities/prediction_entity.dart';
import '../../home/domain/repositories/home_repository.dart';
import 'home_state.dart';

/// StateNotifier for the Home dashboard.
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier({required HomeRepository repository})
      : _repository = repository,
        super(const HomeInitial());

  final HomeRepository _repository;

  /// Loads all dashboard sections.
  Future<void> loadDashboard() async {
    state = const HomeLoading();

// Load sections concurrently for responsive performance.
    final results = await Future.wait([
      _guard(() => _repository.getLiveMatches()),
      _guard(() => _repository.getUpcomingMatches()),
      _guard(() => _repository.getFinishedMatches()),
      _guard(() => _repository.getFeaturedCompetitions()),
      _guard(() => _repository.getTrendingMatches()),
      _guard(() => _repository.getNews()),
      _guard(() => _repository.getTodayPredictions()),
      _guard(() => _repository.getPlayerOfTheDay()),
    ]);

    final liveMatches = _valueOf<List<MatchEntity>>(results[0]) ?? const [];
    final upcomingMatches =
        _valueOf<List<MatchEntity>>(results[1]) ?? const [];
    final finishedMatches =
        _valueOf<List<MatchEntity>>(results[2]) ?? const [];
    final competitions =
        _valueOf<List<CompetitionEntity>>(results[3]) ?? const [];
    final trendingMatches =
        _valueOf<List<MatchEntity>>(results[4]) ?? const [];
    final news = _valueOf<List<ArticleEntity>>(results[5]) ?? const [];
    final predictions =
        _valueOf<PredictionSummaryEntity>(results[6]) ??
            const PredictionSummaryEntity.empty();
    final player = _valueOf<PlayerEntity>(results[7]);

    // If everything failed, surface an error state.
    if (results.every((r) => r.isFailure)) {
      final failure = results.firstWhere((r) => r.isFailure).failure!;
      state = HomeError(message: failure.message);
      return;
    }

    state = HomeLoaded(
      liveMatches: liveMatches,
      upcomingMatches: upcomingMatches,
      finishedMatches: finishedMatches,
      competitions: competitions,
      trendingMatches: trendingMatches,
      news: news,
      predictions: predictions,
      playerOfTheDay: player,
    );
  }

  /// Refreshes the dashboard.
  Future<void> refresh() => loadDashboard();

  // ── Helpers ────────────────────────────────────────────────────────

  Future<HomeResult<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return HomeResult.success(await call());
    } catch (e) {
      return HomeResult.failure(_mapFailure(e));
    }
  }

Failure _mapFailure(Object e) {
    if (e is Failure) return e;
    return Failure.unknown(message: e.toString());
  }

  /// Safely extracts the value of a [HomeResult] if it is a success of type [T].
  T? _valueOf<T>(HomeResult<Object> result) {
    if (result.isSuccess && result.value is T) {
      return result.value as T;
    }
    return null;
  }
}

/// Ergonomic fold over [HomeResult].
extension _ResultFold<T> on HomeResult<T> {
  /// Returns [onValue] when successful, otherwise [elseValue].
  R fold<R>(R elseValue, R Function(T) onValue) {
    if (isSuccess) return onValue(value!);
    return elseValue;
  }
}
