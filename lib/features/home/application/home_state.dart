import '../../home/domain/entities/article_entity.dart';
import '../../home/domain/entities/competition_entity.dart';
import '../../home/domain/entities/match_entity.dart';
import '../../home/domain/entities/player_entity.dart';
import '../../home/domain/entities/prediction_entity.dart';

/// Sealed state for the Home dashboard.
sealed class HomeState {
  const HomeState();
}

/// Initial state before any data loads.
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// State while the dashboard is loading.
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// State with all dashboard data loaded successfully.
class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.liveMatches,
    required this.upcomingMatches,
    required this.finishedMatches,
    required this.competitions,
    required this.trendingMatches,
    required this.news,
    required this.predictions,
    required this.playerOfTheDay,
  });

  final List<MatchEntity> liveMatches;
  final List<MatchEntity> upcomingMatches;
  final List<MatchEntity> finishedMatches;
  final List<CompetitionEntity> competitions;
  final List<MatchEntity> trendingMatches;
  final List<ArticleEntity> news;
  final PredictionSummaryEntity predictions;
  final PlayerEntity? playerOfTheDay;

  HomeLoaded copyWith({
    List<MatchEntity>? liveMatches,
    List<MatchEntity>? upcomingMatches,
    List<MatchEntity>? finishedMatches,
    List<CompetitionEntity>? competitions,
    List<MatchEntity>? trendingMatches,
    List<ArticleEntity>? news,
    PredictionSummaryEntity? predictions,
    PlayerEntity? playerOfTheDay,
  }) {
    return HomeLoaded(
      liveMatches: liveMatches ?? this.liveMatches,
      upcomingMatches: upcomingMatches ?? this.upcomingMatches,
      finishedMatches: finishedMatches ?? this.finishedMatches,
      competitions: competitions ?? this.competitions,
      trendingMatches: trendingMatches ?? this.trendingMatches,
      news: news ?? this.news,
      predictions: predictions ?? this.predictions,
      playerOfTheDay: playerOfTheDay ?? this.playerOfTheDay,
    );
  }
}

/// State with an error and partial data (if any).
class HomeError extends HomeState {
  const HomeError({
    required this.message,
    this.liveMatches = const [],
    this.upcomingMatches = const [],
    this.finishedMatches = const [],
    this.competitions = const [],
    this.trendingMatches = const [],
    this.news = const [],
  });

  final String message;
  final List<MatchEntity> liveMatches;
  final List<MatchEntity> upcomingMatches;
  final List<MatchEntity> finishedMatches;
  final List<CompetitionEntity> competitions;
  final List<MatchEntity> trendingMatches;
  final List<ArticleEntity> news;
}
