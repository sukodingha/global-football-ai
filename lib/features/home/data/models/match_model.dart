import '../../domain/entities/match_entity.dart';

/// Data model for a football match, mapped from the football-data.org API.
class MatchModel {
  const MatchModel({
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

  /// Parses a match from the football-data.org API response.
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final home = json['homeTeam'] as Map<String, dynamic>? ?? const {};
    final away = json['awayTeam'] as Map<String, dynamic>? ?? const {};
    final score = json['score'] as Map<String, dynamic>? ?? const {};
    final fullTime = score['fullTime'] as Map<String, dynamic>? ?? const {};
    final competition = json['competition'] as Map<String, dynamic>? ?? const {};

    return MatchModel(
      id: json['id'] as int? ?? 0,
      status: MatchStatus.fromApi(json['status'] as String? ?? 'SCHEDULED'),
      utcDate: DateTime.tryParse(json['utcDate'] as String? ?? '') ??
          DateTime.now(),
      homeTeam: TeamMini(
        id: home['id'] as int? ?? 0,
        name: home['name'] as String? ?? 'Unknown',
        shortName: home['shortName'] as String?,
        crest: home['crest'] as String?,
      ),
      awayTeam: TeamMini(
        id: away['id'] as int? ?? 0,
        name: away['name'] as String? ?? 'Unknown',
        shortName: away['shortName'] as String?,
        crest: away['crest'] as String?,
      ),
      homeScore: fullTime['home'] as int?,
      awayScore: fullTime['away'] as int?,
      competitionName: competition['name'] as String?,
      competitionEmblem: competition['emblem'] as String?,
      minute: score['minute'] as int?,
    );
  }

/// Serializes back to a JSON map (for caching).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': _statusToApi(status),
      'utcDate': utcDate.toIso8601String(),
      'homeTeam': {
        'id': homeTeam.id,
        'name': homeTeam.name,
        'shortName': homeTeam.shortName,
        'crest': homeTeam.crest,
      },
      'awayTeam': {
        'id': awayTeam.id,
        'name': awayTeam.name,
        'shortName': awayTeam.shortName,
        'crest': awayTeam.crest,
      },
      'score': {
        'fullTime': {'home': homeScore, 'away': awayScore},
        'minute': minute,
      },
      'competition': {
        'name': competitionName,
        'emblem': competitionEmblem,
      },
    };
  }

/// Converts to a domain entity.
  MatchEntity toEntity() {
    return MatchEntity(
      id: id,
      status: status,
      utcDate: utcDate,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      competitionName: competitionName,
      competitionEmblem: competitionEmblem,
      minute: minute,
    );
  }

  /// Maps a [MatchStatus] to its football-data.org API string.
  static String _statusToApi(MatchStatus s) {
    return switch (s) {
      MatchStatus.scheduled => 'SCHEDULED',
      MatchStatus.timed => 'TIMED',
      MatchStatus.inPlay => 'IN_PLAY',
      MatchStatus.paused => 'PAUSED',
      MatchStatus.finished => 'FINISHED',
      MatchStatus.postponed => 'POSTPONED',
      MatchStatus.cancelled => 'CANCELLED',
      MatchStatus.awarded => 'AWARDED',
    };
  }
}
