import 'package:global_football_ai/features/livescore/domain/entities/sport_event_entity.dart';

/// Shared test fixtures for the multi-sport live feed.

SportCompetitor buildCompetitor({
  String id = 'c1',
  String name = 'Team One',
  int? score,
  int? setsWon,
}) {
  return SportCompetitor(id: id, name: name, score: score, setsWon: setsWon);
}

SportEventEntity buildSportEvent({
  String id = 'e1',
  SportType sport = SportType.football,
  SportEventStatus status = SportEventStatus.live,
  String homeName = 'Team One',
  String awayName = 'Team Two',
  int? homeScore,
  int? awayScore,
}) {
  return SportEventEntity(
    id: id,
    sport: sport,
    status: status,
    startTime: DateTime(2024, 1, 1),
    home: buildCompetitor(id: 'h', name: homeName, score: homeScore),
    away: buildCompetitor(id: 'a', name: awayName, score: awayScore),
    competition: 'World Cup',
    minute: status == SportEventStatus.live ? 67 : null,
    currentPeriod: status == SportEventStatus.halftime ? 'HT' : null,
    eventDetails: const {},
  );
}

List<SportEventEntity> buildFootballEvents() => [
      buildSportEvent(
        id: 'f1',
        sport: SportType.football,
        status: SportEventStatus.live,
        homeScore: 2,
        awayScore: 1,
      ),
      buildSportEvent(
        id: 'f2',
        sport: SportType.football,
        status: SportEventStatus.live,
        homeName: 'Reds',
        awayName: 'Blues',
        homeScore: 0,
        awayScore: 0,
      ),
    ];

List<SportEventEntity> buildTennisEvents() => [
      buildSportEvent(
        id: 't1',
        sport: SportType.tennis,
        status: SportEventStatus.live,
        homeName: 'Player A',
        awayName: 'Player B',
        homeScore: 1,
        awayScore: 0,
      ),
    ];

List<SportEventEntity> buildBasketballEvents() => [
      buildSportEvent(
        id: 'b1',
        sport: SportType.basketball,
        status: SportEventStatus.live,
        homeName: 'Lakers',
        awayName: 'Celtics',
        homeScore: 45,
        awayScore: 40,
      ),
    ];
