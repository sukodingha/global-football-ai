import '../../domain/entities/lineup_entity.dart';

/// Data model for a lineup player.
class LineupPlayerModel {
  const LineupPlayerModel({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    this.imageUrl,
    this.isCaptain = false,
    this.replacedPlayerId,
    this.replacedPlayerName,
    this.replacedMinute,
  });

  final int id;
  final String name;
  final int number;
  final String position;
  final String? imageUrl;
  final bool isCaptain;
  final int? replacedPlayerId;
  final String? replacedPlayerName;
  final int? replacedMinute;

  factory LineupPlayerModel.fromFootballDataJson(Map<String, dynamic> json) {
    return LineupPlayerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      number: json['shirtNumber'] as int? ?? 0,
      position: json['position'] as String? ?? 'SUB',
      imageUrl: null,
      isCaptain: json['captain'] as bool? ?? false,
    );
  }

  LineupPlayerEntity toEntity() {
    return LineupPlayerEntity(
      id: id,
      name: name,
      number: number,
      position: position,
      imageUrl: imageUrl,
      isCaptain: isCaptain,
      replacedPlayerId: replacedPlayerId,
      replacedPlayerName: replacedPlayerName,
      replacedMinute: replacedMinute,
    );
  }
}

/// Data model for the full match lineup.
class MatchLineupModel {
  const MatchLineupModel({
    required this.homeTeam,
    required this.awayTeam,
    required this.formation,
    this.homeSubstitutes = const [],
    this.awaySubstitutes = const [],
  });

  final List<LineupPlayerModel> homeTeam;
  final List<LineupPlayerModel> awayTeam;
  final String formation;
  final List<LineupPlayerModel> homeSubstitutes;
  final List<LineupPlayerModel> awaySubstitutes;

  factory MatchLineupModel.fromFootballDataJson(Map<String, dynamic> json) {
    final homeTeam = json['homeTeam'] as Map<String, dynamic>? ?? {};
    final awayTeam = json['awayTeam'] as Map<String, dynamic>? ?? {};

    final homeStarters = _parsePlayers(homeTeam['startingXI'] as List<dynamic>?);
    final awayStarters = _parsePlayers(awayTeam['startingXI'] as List<dynamic>?);
    final homeSubs = _parsePlayers(homeTeam['substitutes'] as List<dynamic>?);
    final awaySubs = _parsePlayers(awayTeam['substitutes'] as List<dynamic>?);

    return MatchLineupModel(
      homeTeam: homeStarters,
      awayTeam: awayStarters,
      formation: homeTeam['formation'] as String? ?? '4-3-3',
      homeSubstitutes: homeSubs,
      awaySubstitutes: awaySubs,
    );
  }

  static List<LineupPlayerModel> _parsePlayers(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((e) {
      final player = e is Map<String, dynamic> ? e : const <String, dynamic>{};
      // Sometimes the player is nested under a 'player' key.
      final data = player['player'] as Map<String, dynamic>? ?? player;
      return LineupPlayerModel.fromFootballDataJson(data);
    }).toList();
  }

  MatchLineupEntity toEntity() {
    return MatchLineupEntity(
      homeTeam: homeTeam.map((e) => e.toEntity()).toList(),
      awayTeam: awayTeam.map((e) => e.toEntity()).toList(),
      formation: formation,
      homeSubstitutes: homeSubstitutes.map((e) => e.toEntity()).toList(),
      awaySubstitutes: awaySubstitutes.map((e) => e.toEntity()).toList(),
    );
  }
}
