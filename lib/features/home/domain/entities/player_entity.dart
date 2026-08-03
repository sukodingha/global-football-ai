import 'package:equatable/equatable.dart';

/// A featured player (Player of the Day).
class PlayerEntity extends Equatable {
  const PlayerEntity({
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

  @override
  List<Object?> get props => [
        id,
        name,
        position,
        nationality,
        team,
        teamCrest,
        photoUrl,
        age,
        rating,
        stats,
      ];
}
