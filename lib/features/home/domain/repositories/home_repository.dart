import '../../../../core/errors/failures.dart';
import '../entities/article_entity.dart';
import '../entities/competition_entity.dart';
import '../entities/match_entity.dart';
import '../entities/player_entity.dart';
import '../entities/prediction_entity.dart';

/// Abstract contract for the Home dashboard data.
abstract class HomeRepository {
  /// Fetches live matches currently in play.
  Future<List<MatchEntity>> getLiveMatches();

  /// Fetches upcoming (scheduled) matches.
  Future<List<MatchEntity>> getUpcomingMatches();

  /// Fetches finished matches.
  Future<List<MatchEntity>> getFinishedMatches();

  /// Fetches featured competitions.
  Future<List<CompetitionEntity>> getFeaturedCompetitions();

  /// Fetches trending matches.
  Future<List<MatchEntity>> getTrendingMatches();

  /// Fetches the football news feed.
  Future<List<ArticleEntity>> getNews();

  /// Fetches today's AI predictions summary.
  Future<PredictionSummaryEntity> getTodayPredictions();

  /// Fetches the featured Player of the Day.
  Future<PlayerEntity> getPlayerOfTheDay();
}

/// Result wrapper for home repository operations.
class HomeResult<T> {
  const HomeResult._(this.value, this.failure);
  const HomeResult.success(T value) : this._(value, null);
  const HomeResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}
