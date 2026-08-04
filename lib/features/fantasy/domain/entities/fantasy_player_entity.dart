import 'package:equatable/equatable.dart';

/// Position of a player in fantasy football.
enum FantasyPosition { goalkeeper, defender, midfielder, forward }

/// Player-level statistics used for scoring.
class MatchStatsEntity extends Equatable {
  const MatchStatsEntity({
    this.goals = 0,
    this.assists = 0,
    this.cleanSheets = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.appearances = 0,
    this.minutesPlayed = 0,
    this.saves = 0,
    this.savesPoints = 0,
    this.points = 0,
  });

  final int goals;
  final int assists;
  final int cleanSheets;
  final int yellowCards;
  final int redCards;
  final int appearances;
  final int minutesPlayed;
  final int saves;

  /// Total fantasy points derived from events.
  final int points;

  /// Bonus points awarded (e.g. saves bonus for keepers).
  final int savesPoints;

  MatchStatsEntity copyWith({
    int? goals,
    int? assists,
    int? cleanSheets,
    int? yellowCards,
    int? redCards,
    int? appearances,
    int? minutesPlayed,
    int? saves,
    int? points,
    int? savesPoints,
  }) {
    return MatchStatsEntity(
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      cleanSheets: cleanSheets ?? this.cleanSheets,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      appearances: appearances ?? this.appearances,
      minutesPlayed: minutesPlayed ?? this.minutesPlayed,
      saves: saves ?? this.saves,
      points: points ?? this.points,
      savesPoints: savesPoints ?? this.savesPoints,
    );
  }

  @override
  List<Object?> get props => [
        goals,
        assists,
        cleanSheets,
        yellowCards,
        redCards,
        appearances,
        minutesPlayed,
        saves,
        points,
        savesPoints,
      ];
}

/// A football player available to be picked in a fantasy team.
///
/// [price] is expressed in fantasy credits; [totalPoints] is the running
/// fantasy score aggregated from the scoring engine.
class FantasyPlayerEntity extends Equatable {
  const FantasyPlayerEntity({
    required this.id,
    required this.name,
    required this.position,
    required this.team,
    required this.price,
    this.teamCrest,
    this.photoUrl,
    this.totalPoints = 0,
    this.stats = const MatchStatsEntity(),
  });

  final int id;
  final String name;
  final FantasyPosition position;
  final String team;
  final double price;
  final String? teamCrest;
  final String? photoUrl;
  final double totalPoints;
  final MatchStatsEntity stats;

  bool get isGoalkeeper => position == FantasyPosition.goalkeeper;
  bool get isDefender => position == FantasyPosition.defender;
  bool get isMidfielder => position == FantasyPosition.midfielder;
  bool get isForward => position == FantasyPosition.forward;

  FantasyPlayerEntity copyWith({
    int? id,
    String? name,
    FantasyPosition? position,
    String? team,
    double? price,
    String? teamCrest,
    String? photoUrl,
    double? totalPoints,
    MatchStatsEntity? stats,
  }) {
    return FantasyPlayerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      team: team ?? this.team,
      price: price ?? this.price,
      teamCrest: teamCrest ?? this.teamCrest,
      photoUrl: photoUrl ?? this.photoUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        position,
        team,
        price,
        teamCrest,
        photoUrl,
        totalPoints,
        stats,
      ];
}

