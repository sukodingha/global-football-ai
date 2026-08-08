import 'package:global_football_ai/features/home/domain/entities/article_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/competition_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/match_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/player_entity.dart';
import 'package:global_football_ai/features/home/domain/entities/prediction_entity.dart';

/// Shared test fixtures for Home feature entities.

MatchEntity buildMatch({
  int id = 1,
  MatchStatus status = MatchStatus.scheduled,
  String homeName = 'Home FC',
  String awayName = 'Away FC',
  int? homeScore,
  int? awayScore,
}) {
  return MatchEntity(
    id: id,
    status: status,
    utcDate: DateTime(2024, 1, 1),
    homeTeam: TeamMini(id: id, name: homeName),
    awayTeam: TeamMini(id: id + 100, name: awayName),
    homeScore: homeScore,
    awayScore: awayScore,
    competitionName: 'Premier League',
  );
}

ArticleEntity buildArticle({
  String id = 'a1',
  String title = 'Test Article',
}) {
  return ArticleEntity(
    id: id,
    title: title,
    summary: 'A summary of the article.',
    publishedAt: DateTime(2024, 1, 1),
    source: 'SportSource',
  );
}

CompetitionEntity buildCompetition({
  int id = 1,
  String name = 'Premier League',
}) {
  return CompetitionEntity(
    id: id,
    name: name,
    code: 'PL',
    type: 'LEAGUE',
    country: 'England',
  );
}

PlayerEntity buildPlayer({
  int id = 1,
  String name = 'Star Player',
}) {
  return PlayerEntity(
    id: id,
    name: name,
    position: 'Forward',
    nationality: 'England',
    team: 'Home FC',
  );
}

PredictionSummaryEntity buildPredictionSummary({
  int total = 3,
  int high = 1,
}) {
  return PredictionSummaryEntity(
    totalPredictions: total,
    highConfidence: high,
    totalMatches: 10,
    predictions: const [],
  );
}

/// Builds a fully populated [HomeLoaded] set of values.
List<MatchEntity> buildLiveMatches() => [
      buildMatch(id: 1, status: MatchStatus.inPlay, homeScore: 2, awayScore: 1),
      buildMatch(id: 2, status: MatchStatus.inPlay, homeScore: 0, awayScore: 0),
    ];

List<MatchEntity> buildUpcomingMatches() => [
      buildMatch(id: 3, status: MatchStatus.timed),
      buildMatch(id: 4, status: MatchStatus.scheduled),
    ];

List<MatchEntity> buildFinishedMatches() => [
      buildMatch(id: 5, status: MatchStatus.finished, homeScore: 1, awayScore: 0),
    ];

List<MatchEntity> buildTrendingMatches() => [
      buildMatch(id: 6, status: MatchStatus.scheduled),
    ];

List<CompetitionEntity> buildCompetitions() => [
      buildCompetition(id: 1),
      buildCompetition(id: 2, name: 'La Liga'),
    ];

List<ArticleEntity> buildNews() => [
      buildArticle(id: 'n1', title: 'Big Transfer News'),
      buildArticle(id: 'n2', title: 'Match Preview'),
    ];
