import 'package:equatable/equatable.dart';

/// Current status of a football match.
enum MatchStatus {
  scheduled,
  timed,
  inPlay,
  paused,
  finished,
  postponed,
  cancelled,
  awarded;

  /// Whether the match is currently live.
  bool get isLive => this == inPlay || this == paused;

  /// Whether the match has concluded.
  bool get isFinished => this == finished || this == awarded;

  /// Parses a status string from the API.
  static MatchStatus fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'SCHEDULED':
        return MatchStatus.scheduled;
      case 'TIMED':
        return MatchStatus.timed;
      case 'IN_PLAY':
        return MatchStatus.inPlay;
      case 'PAUSED':
        return MatchStatus.paused;
      case 'FINISHED':
        return MatchStatus.finished;
      case 'POSTPONED':
        return MatchStatus.postponed;
      case 'CANCELLED':
        return MatchStatus.cancelled;
      case 'AWARDED':
        return MatchStatus.awarded;
      default:
        return MatchStatus.scheduled;
    }
  }
}

/// A simplified team representation for a match.
class TeamMini extends Equatable {
  const TeamMini({
    required this.id,
    required this.name,
    this.shortName,
    this.crest,
  });

  final int id;
  final String name;
  final String? shortName;
  final String? crest;

  @override
  List<Object?> get props => [id, name, shortName, crest];
}

/// A complete football match.
class MatchEntity extends Equatable {
  const MatchEntity({
    required this.id,
    required this.status,
    required this.utcDate,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    this.competitionName,
    this.competitionEmblem,
    this.minute,
  });

  final int id;
  final MatchStatus status;
  final DateTime utcDate;
  final TeamMini homeTeam;
  final TeamMini awayTeam;
  final int? homeScore;
  final int? awayScore;
  final String? competitionName;
  final String? competitionEmblem;
  final int? minute;

  @override
  List<Object?> get props => [
        id,
        status,
        utcDate,
        homeTeam,
        awayTeam,
        homeScore,
        awayScore,
        competitionName,
        competitionEmblem,
        minute,
      ];
}
