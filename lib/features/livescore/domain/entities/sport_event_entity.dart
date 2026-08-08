import 'package:equatable/equatable.dart';

/// Supported sports in the multi-sport live feed.
enum SportType {
  football,
  tennis,
  basketball;

  String get label {
    switch (this) {
      case SportType.football:
        return 'Football';
      case SportType.tennis:
        return 'Tennis';
      case SportType.basketball:
        return 'Basketball';
    }
  }

  /// API-Sports endpoint slugs.
  String get apiPath {
    switch (this) {
      case SportType.football:
        return 'football';
      case SportType.tennis:
        return 'tennis';
      case SportType.basketball:
        return 'basketball';
    }
  }

  static SportType fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'football':
        return SportType.football;
      case 'tennis':
        return SportType.tennis;
      case 'basketball':
        return SportType.basketball;
      default:
        return SportType.football;
    }
  }
}

/// Match/event status shared across sports (Live, Halftime, Full Time, ...).
enum SportEventStatus {
  scheduled,
  live,
  halftime,
  fulltime,
  extraTime,
  postponed,
  cancelled;

  String get label {
    switch (this) {
      case SportEventStatus.scheduled:
        return 'Scheduled';
      case SportEventStatus.live:
        return 'LIVE';
      case SportEventStatus.halftime:
        return 'Halftime';
      case SportEventStatus.fulltime:
        return 'FT';
      case SportEventStatus.extraTime:
        return 'Extra Time';
      case SportEventStatus.postponed:
        return 'Postponed';
      case SportEventStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isLive => this == SportEventStatus.live || this == SportEventStatus.halftime;

  bool get isFinished => this == SportEventStatus.fulltime;

  /// Parses common API status strings.
  static SportEventStatus fromApi(String value) {
    final v = value.trim().toUpperCase();
    if (v.contains('LIVE') && v.contains('HT')) return SportEventStatus.halftime;
    if (v.contains('HALFTIME') || v == 'HT') return SportEventStatus.halftime;
    if (v.contains('FULL') || v == 'FT' || v.contains('FINISHED')) {
      return SportEventStatus.fulltime;
    }
    if (v.contains('EXTRA')) return SportEventStatus.extraTime;
    if (v.contains('POSTPONED')) return SportEventStatus.postponed;
    if (v.contains('CANCEL')) return SportEventStatus.cancelled;
    if (v.contains('LIVE') || v == 'IN PLAY' || v == '1ST' || v == '2ND') {
      return SportEventStatus.live;
    }
    return SportEventStatus.scheduled;
  }
}

/// A competitor/team/player in a sport event.
class SportCompetitor extends Equatable {
  const SportCompetitor({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
    this.score,
    this.secondaryScore,
    this.setsWon,
  });

  final String id;
  final String name;
  final String? shortName;
  final String? logo;

  /// Primary score (goals/points/sets won).
  final int? score;

  /// Secondary score (e.g. basketball quarters aggregate, tennis games in
  /// current set is captured separately in the event-level breakdown).
  final int? secondaryScore;

  /// Sets won (tennis).
  final int? setsWon;

  @override
  List<Object?> get props =>
      [id, name, shortName, logo, score, secondaryScore, setsWon];

  SportCompetitor copyWith({
    String? id,
    String? name,
    String? shortName,
    String? logo,
    int? score,
    int? secondaryScore,
    int? setsWon,
  }) {
    return SportCompetitor(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      logo: logo ?? this.logo,
      score: score ?? this.score,
      secondaryScore: secondaryScore ?? this.secondaryScore,
      setsWon: setsWon ?? this.setsWon,
    );
  }
}

/// A multi-sport live event (football, tennis, basketball) with scores,
/// status, and real-time tracking metadata.
class SportEventEntity extends Equatable {
  const SportEventEntity({
    required this.id,
    required this.sport,
    required this.status,
    required this.startTime,
    required this.home,
    required this.away,
    this.competition,
    this.venue,
    this.minute,
    this.currentPeriod,
    this.eventDetails = const {},
    this.lastUpdated,
  });

  final String id;
  final SportType sport;
  final SportEventStatus status;
  final DateTime startTime;
  final SportCompetitor home;
  final SportCompetitor away;
  final String? competition;
  final String? venue;

  /// Match minute for football.
  final int? minute;

  /// Current period label (e.g. "Q3", "Set 2", "1st Half").
  final String? currentPeriod;

  /// Sport-specific details (game scores, set games, etc.).
  final Map<String, dynamic> eventDetails;

  final DateTime? lastUpdated;

  /// Whether the event is live right now.
  bool get isLive => status.isLive;

  /// Whether the event has concluded.
  bool get isFinished => status.isFinished;

  @override
  List<Object?> get props => [
        id,
        sport,
        status,
        startTime,
        home,
        away,
        competition,
        venue,
        minute,
        currentPeriod,
        eventDetails,
        lastUpdated,
      ];

  SportEventEntity copyWith({
    String? id,
    SportType? sport,
    SportEventStatus? status,
    DateTime? startTime,
    SportCompetitor? home,
    SportCompetitor? away,
    String? competition,
    String? venue,
    int? minute,
    String? currentPeriod,
    Map<String, dynamic>? eventDetails,
    DateTime? lastUpdated,
  }) {
    return SportEventEntity(
      id: id ?? this.id,
      sport: sport ?? this.sport,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      home: home ?? this.home,
      away: away ?? this.away,
      competition: competition ?? this.competition,
      venue: venue ?? this.venue,
      minute: minute ?? this.minute,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      eventDetails: eventDetails ?? this.eventDetails,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

