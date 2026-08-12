import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:global_ai_prediction/core/errors/failures.dart';
import 'package:global_ai_prediction/features/home/data/dependency_injection.dart';
import 'package:global_ai_prediction/features/home/domain/entities/article_entity.dart';
import 'package:global_ai_prediction/features/home/domain/entities/competition_entity.dart';
import 'package:global_ai_prediction/features/home/domain/entities/match_entity.dart';
import 'package:global_ai_prediction/features/home/domain/entities/player_entity.dart';
import 'package:global_ai_prediction/features/home/domain/entities/prediction_entity.dart';
import 'package:global_ai_prediction/features/home/domain/repositories/home_repository.dart';
import 'package:global_ai_prediction/features/livescore/data/dependency_injection.dart';
import 'package:global_ai_prediction/features/livescore/domain/entities/sport_event_entity.dart';
import 'package:global_ai_prediction/features/livescore/domain/repositories/multi_sport_repository.dart';
import 'package:global_ai_prediction/features/predictions/data/dependency_injection.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/post_match_comparison_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/prediction_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/prediction_history_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/user_vote_entity.dart';
import 'package:global_ai_prediction/features/predictions/domain/repositories/prediction_repository.dart';

import '../features/home/fixtures/home_fixtures.dart';
import '../features/livescore/fixtures/sports_feed_fixtures.dart';
import '../features/predictions/fixtures/prediction_fixtures.dart';

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

/// In-memory fake [PredictionRepository] for tests.
class FakePredictionRepository implements PredictionRepository {
  FakePredictionRepository({
    MatchPredictionEntity? prediction,
    this.history = const [],
    this.comparisons = const [],
    this.accuracyStats,
    VoteCountsEntity? voteCounts,
    this.myVote,
    this.throwOnFetch = false,
    this.delay,
  })  : _prediction = prediction ?? buildPrediction(),
        _voteCounts = voteCounts ?? buildVoteCounts();

  MatchPredictionEntity _prediction;
  List<PredictionHistoryEntity> history;
  List<PostMatchComparisonEntity> comparisons;
  AccuracyStatsEntity? accuracyStats;
  VoteCountsEntity _voteCounts;
  String? myVote;

  /// When true, getPredictionForMatch throws a [ServerFailure].
  bool throwOnFetch;

  /// Optional delay before fetches resolve, for testing loading states.
  Duration? delay;

  // Call recording.
  int historyFetchCount = 0;
  int comparisonsFetchCount = 0;
  int savePredictionCount = 0;
  int voteCount = 0;
  int saveComparisonCount = 0;
  int? lastMatchedMatchId;

  Future<void> _maybeDelay() async {
    final d = delay;
    if (d != null) await Future<void>.delayed(d);
  }

  /// Overrides the prediction returned by [getPredictionForMatch].
  set predictionValue(MatchPredictionEntity value) => _prediction = value;

  @override
  Future<MatchPredictionEntity> getPredictionForMatch(int matchId) async {
    await _maybeDelay();
    lastMatchedMatchId = matchId;
    if (throwOnFetch) throw const ServerFailure();
    return _prediction;
  }

  @override
  Future<List<PredictionHistoryEntity>> getPredictionHistory({
    String? userId,
    int limit = 50,
  }) async {
    historyFetchCount++;
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return history;
  }

  @override
  Future<void> savePredictionToHistory({
    required String userId,
    required MatchPredictionEntity prediction,
    DateTime? matchDate,
  }) async {
    savePredictionCount++;
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
  }

  @override
  Future<VoteCountsEntity> voteOnPrediction({
    required String predictionId,
    required String userId,
    required String vote,
  }) async {
    voteCount++;
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return _voteCounts;
  }

  @override
  Future<(VoteCountsEntity, String?)> getVoteState({
    required String predictionId,
    required String userId,
  }) async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return (_voteCounts, myVote);
  }

  @override
  Future<PostMatchComparisonEntity> compareWithResult({
    required MatchPredictionEntity prediction,
    required int actualHomeScore,
    required int actualAwayScore,
    int? actualCorners,
    int? actualCards,
  }) async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return buildComparison(
      matchId: prediction.matchId,
      actualHomeScore: actualHomeScore,
      actualAwayScore: actualAwayScore,
    );
  }

  @override
  Future<void> saveComparison({
    required String userId,
    required PostMatchComparisonEntity comparison,
  }) async {
    saveComparisonCount++;
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    comparisons = [comparison, ...comparisons];
  }

  @override
  Future<List<PostMatchComparisonEntity>> getComparisons({
    String? userId,
    int limit = 20,
  }) async {
    comparisonsFetchCount++;
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return comparisons;
  }

  @override
  Future<AccuracyStatsEntity> getAccuracyStats({String? userId}) async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
    return accuracyStats ?? buildAccuracyStats();
  }

  @override
  Future<void> resolvePrediction({
    required String historyId,
    required bool isCorrect,
  }) async {
    await _maybeDelay();
    if (throwOnFetch) throw const ServerFailure();
  }
}

/// Pre-built fake providers for [FakePredictionRepository].
List<Override> predictionRepositoryOverrides(
  FakePredictionRepository repo,
) =>
    [
      predictionRepositoryProvider.overrideWithValue(repo),
    ];

/// Convenience factory for a fully loaded prediction repository.
FakePredictionRepository loadedPredictionRepository() {
  return FakePredictionRepository(
    history: [buildHistory(), buildHistory(id: 'h2', matchId: 2)],
    comparisons: [buildComparison()],
    accuracyStats: buildAccuracyStats(),
    voteCounts: buildVoteCounts(),
  );
}
