import 'package:equatable/equatable.dart';

/// A player in a match lineup.
class LineupPlayerEntity extends Equatable {
  const LineupPlayerEntity({
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
  final String position; // GK, DEF, MID, FWD
  final String? imageUrl;
  final bool isCaptain;
  final int? replacedPlayerId;
  final String? replacedPlayerName;
  final int? replacedMinute;

  @override
  List<Object?> get props => [
        id,
        name,
        number,
        position,
        imageUrl,
        isCaptain,
        replacedPlayerId,
        replacedPlayerName,
        replacedMinute,
      ];
}

/// The full lineup for both teams.
class MatchLineupEntity extends Equatable {
  const MatchLineupEntity({
    required this.homeTeam,
    required this.awayTeam,
    required this.formation,
    this.homeSubstitutes = const [],
    this.awaySubstitutes = const [],
  });

  /// Home team starting XI.
  final List<LineupPlayerEntity> homeTeam;

  /// Away team starting XI.
  final List<LineupPlayerEntity> awayTeam;

  /// Formation string (e.g. "4-3-3").
  final String formation;

  /// Home team substitutes.
  final List<LineupPlayerEntity> homeSubstitutes;

  /// Away team substitutes.
  final List<LineupPlayerEntity> awaySubstitutes;

  @override
  List<Object?> get props => [
        homeTeam,
        awayTeam,
        formation,
        homeSubstitutes,
        awaySubstitutes,
      ];
}
