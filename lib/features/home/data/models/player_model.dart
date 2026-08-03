import '../entities/player_entity.dart';

/// Data model for a featured player, mapped from the API.
class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.name,
    required this.position,
    this.nationality,
    this.team,
    this.teamCrest,
    this.photoUrl,
    this.age,
    this.rating,
    this.stats,
  });

  final int id;
  final String name;
  final String position;
  final String? nationality;
  final String? team;
  final String? teamCrest;
  final String? photoUrl;
  final int? age;
  final double? rating;
  final Map<String, int>? stats;

  /// Parses a player from the football-data.org API response.
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>? ?? const {};
    return PlayerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      position: json['position'] as String? ?? 'Forward',
      nationality: json['nationality'] as String?,
      team: team['name'] as String?,
      teamCrest: team['crest'] as String?,
      photoUrl: json['photoUrl'] as String?,
      age: json['age'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      stats: json['stats'] != null
          ? (json['stats'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num).toInt()))
          : null,
    );
  }

  /// Converts to a domain entity.
  PlayerEntity toEntity() {
    return PlayerEntity(
      id: id,
      name: name,
      position: position,
      nationality: nationality,
      team: team,
      teamCrest: teamCrest,
      photoUrl: photoUrl,
      age: age,
      rating: rating,
      stats: stats,
    );
  }
}
