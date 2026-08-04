import '../../domain/entities/fantasy_player_entity.dart';

/// JSON model for [FantasyPlayerEntity], used for the player pool.
class FantasyPlayerModel {
  const FantasyPlayerModel({
    required this.id,
    required this.name,
    required this.position,
    required this.team,
    required this.price,
    this.teamCrest,
    this.photoUrl,
    this.totalPoints = 0,
    this.goals = 0,
    this.assists = 0,
    this.cleanSheets = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.appearances = 0,
    this.minutesPlayed = 0,
    this.saves = 0,
    this.points = 0,
    this.savesPoints = 0,
  });

  final int id;
  final String name;
  final FantasyPosition position;
  final String team;
  final double price;
  final String? teamCrest;
  final String? photoUrl;
  final double totalPoints;
  final int goals;
  final int assists;
  final int cleanSheets;
  final int yellowCards;
  final int redCards;
  final int appearances;
  final int minutesPlayed;
  final int saves;
  final int points;
  final int savesPoints;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'position': position.name,
        'team': team,
        'price': price,
        'teamCrest': teamCrest,
        'photoUrl': photoUrl,
        'totalPoints': totalPoints,
        'goals': goals,
        'assists': assists,
        'cleanSheets': cleanSheets,
        'yellowCards': yellowCards,
        'redCards': redCards,
        'appearances': appearances,
        'minutesPlayed': minutesPlayed,
        'saves': saves,
        'points': points,
        'savesPoints': savesPoints,
      };

  factory FantasyPlayerModel.fromJson(Map<String, dynamic> json) {
    return FantasyPlayerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      position: _positionFromString(json['position'] as String?),
      team: json['team'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 5.0,
      teamCrest: json['teamCrest'] as String?,
      photoUrl: json['photoUrl'] as String?,
      totalPoints: (json['totalPoints'] as num?)?.toDouble() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      cleanSheets: (json['cleanSheets'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      appearances: (json['appearances'] as num?)?.toInt() ?? 0,
      minutesPlayed: (json['minutesPlayed'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      savesPoints: (json['savesPoints'] as num?)?.toInt() ?? 0,
    );
  }

  FantasyPlayerEntity toEntity() => FantasyPlayerEntity(
        id: id,
        name: name,
        position: position,
        team: team,
        price: price,
        teamCrest: teamCrest,
        photoUrl: photoUrl,
        totalPoints: totalPoints,
        stats: MatchStatsEntity(
          goals: goals,
          assists: assists,
          cleanSheets: cleanSheets,
          yellowCards: yellowCards,
          redCards: redCards,
          appearances: appearances,
          minutesPlayed: minutesPlayed,
          saves: saves,
          points: points,
          savesPoints: savesPoints,
        ),
      );

  factory FantasyPlayerModel.fromEntity(FantasyPlayerEntity entity) =>
      FantasyPlayerModel(
        id: entity.id,
        name: entity.name,
        position: entity.position,
        team: entity.team,
        price: entity.price,
        teamCrest: entity.teamCrest,
        photoUrl: entity.photoUrl,
        totalPoints: entity.totalPoints,
        goals: entity.stats.goals,
        assists: entity.stats.assists,
        cleanSheets: entity.stats.cleanSheets,
        yellowCards: entity.stats.yellowCards,
        redCards: entity.stats.redCards,
        appearances: entity.stats.appearances,
        minutesPlayed: entity.stats.minutesPlayed,
        saves: entity.stats.saves,
        points: entity.stats.points,
        savesPoints: entity.stats.savesPoints,
      );

  static FantasyPosition _positionFromString(String? value) {
    switch (value) {
      case 'goalkeeper':
        return FantasyPosition.goalkeeper;
      case 'defender':
        return FantasyPosition.defender;
      case 'midfielder':
        return FantasyPosition.midfielder;
      case 'forward':
        return FantasyPosition.forward;
      default:
        return FantasyPosition.midfielder;
    }
  }
}

