import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:global_football_ai/core/errors/failures.dart';
import 'package:global_football_ai/features/home/data/dependency_injection.dart';
import 'package:global_football_ai/features/home/domain/entities/article_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/competition_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/match_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/player_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/prediction_entity.dart';
import 'package:global_football_ai/features/home/domain/repositories/home_repository.dart';
import 'package:global_football_ai/features/livescore/data/dependency_injection.dart';
import 'package:global_football_ai/features/livescore/domain/entities/sport_event_entity.dart';
import 'package:global_football_ai/features/livescore/domain/repositories/multi_sport_repository.dart';

import '../features/home/fixtures/home_fixtures.dart';
import '../features/livescore/fixtures/sports_feed_fixtures.dart';

/// In-memory fake [HomeRepository] for tests.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.liveMatches = const [],
    this.upcomingMatches = const [],
    this.finishedMatches = const [],
    this.competitions = const [],
    this.trendingMatches = const [],
    this.news = const [],
    this.predictionSummary = const PredictionSummaryEntity.empty(),
    this.playerOfTheDay,
    this.throwOnFetch = false,
    this.delay,
  });

  List<MatchEntity> liveMatches;
  List<MatchEntity> upcomingMatches;
  List<MatchEntity> finishedMatches;
  List<CompetitionEntity> competitions;
  List<MatchEntity> trendingMatches;
  List<ArticleEntity> news;
  PredictionSummaryEntity predictionSummary;
  PlayerEntity? playerOfTheDay;

  /// When true, all fetches throw a [ServerFailure].
  bool throwOnFetch;

  /// Optional delay before fetches resolve, for testing loading states.
  Duration? delay;

  int newsFetchCount = 0;

  Future<void> _maybeDelay() async {
    final d = delay;
    if (d != null) await Future<void>.delayed(d);
  }

  @override
  Future<List<MatchEntity>> getLiveMatches() async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return liveMatches;
  }

  @override
  Future<List<MatchEntity>> getUpcomingMatches() async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return upcomingMatches;
  }

  @override
  Future<List<MatchEntity>> getFinishedMatches() async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return finishedMatches;
  }

  @override
  Future<List<CompetitionEntity>> getFeaturedCompetitions() async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return competitions;
  }

  @override
  Future<List<MatchEntity>> getTrendingMatches() async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return trendingMatches;
  }

  @override
  Future<List<ArticleEntity>> getNews({bool refresh = false}) async {
    newsFetchCount++;
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return news;
  }

  @override
  Future<PredictionSummaryEntity> getTodayPredictions() async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return predictionSummary;
  }

  @override
  Future<PlayerEntity> getPlayerOfTheDay() async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    if (playerOfTheDay == null) {
      throw const ServerFailure('No player of the day');
    }
    return playerOfTheDay!;
  }
}

/// In-memory fake [MultiSportRepository] for tests.
class FakeMultiSportRepository implements MultiSportRepository {
  FakeMultiSportRepository({
    this.events = const {},
    this.throwOnFetch = false,
  });

  Map<SportType, List<SportEventEntity>> events;
  bool throwOnFetch;

  final StreamController<Map<SportType, List<SportEventEntity>>> _controller =
      StreamController.broadcast();

  @override
  Future<List<SportEventEntity>> getLiveEvents(SportType sport) async {
    if (throwOnFetch) throw const ServerFailure();
    return events[sport] ?? const [];
  }

  @override
  Future<List<SportEventEntity>> getTodayEvents(SportType sport) async {
    if (throwOnFetch) throw const ServerFailure();
    return events[sport] ?? const [];
  }

  @override
  Stream<List<SportEventEntity>> watchLiveEvents(SportType sport) {
    return _controller.stream
        .map((all) => all[sport] ?? const <SportEventEntity>[]);
  }

  @override
  Future<Map<SportType, List<SportEventEntity>>> getLiveEventsAll() async {
    if (throwOnFetch) throw const ServerFailure();
    return events;
  }

  /// Emits an updated snapshot to subscribers.
  void emit(Map<SportType, List<SportEventEntity>> updated) {
    _controller.add(updated);
  }

  void dispose() {
    _controller.close();
  }
}

/// Pre-built fake providers for [FakeHomeRepository].
List<Override> homeRepositoryOverrides(FakeHomeRepository repo) => [
      homeRepositoryProvider.overrideWithValue(repo),
    ];

/// Pre-built fake providers for [FakeMultiSportRepository].
List<Override> multiSportRepositoryOverrides(FakeMultiSportRepository repo) => [
      multiSportRepositoryProvider.overrideWithValue(repo),
    ];

/// Convenience factory for a fully loaded home repository.
FakeHomeRepository loadedHomeRepository() {
  return FakeHomeRepository(
    liveMatches: buildLiveMatches(),
    upcomingMatches: buildUpcomingMatches(),
    finishedMatches: buildFinishedMatches(),
    competitions: buildCompetitions(),
    trendingMatches: buildTrendingMatches(),
    news: buildNews(),
    predictionSummary: buildPredictionSummary(),
    playerOfTheDay: buildPlayer(),
  );
}

/// Convenience factory for a fully loaded multi-sport repository.
FakeMultiSportRepository loadedSportsRepository() {
  return FakeMultiSportRepository(
    events: {
      SportType.football: buildFootballEvents(),
      SportType.tennis: buildTennisEvents(),
      SportType.basketball: buildBasketballEvents(),
    },
  );
}
