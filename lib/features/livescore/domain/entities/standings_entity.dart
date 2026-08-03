import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/match_entity.dart';

/// A single row in a competition standings table.
class StandingsRowEntity extends Equatable {
  const StandingsRowEntity({
    required this.position,
    required this.teamId,
    required this.teamName,
    required this.teamCrest,
    required this.playedGames,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    this.form = const [],
  });

  final int position;
  final int teamId;
  final String teamName;
  final String? teamCrest;
  final int playedGames;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  /// Recent results, e.g. ['W', 'D', 'L', 'W', 'W'].
  final List<String> form;

  @override
  List<Object?> get props => [
        position,
        teamId,
        teamName,
        teamCrest,
        playedGames,
        won,
        draw,
        lost,
        points,
        goalsFor,
        goalsAgainst,
        goalDifference,
        form,
      ];
}

/// Standings for a competition, grouped by table (some competitions have
/// multiple groups).
class StandingsEntity extends Equatable {
  const StandingsEntity({
    required this.competitionId,
    required this.competitionName,
    required this.rows,
    this.stage,
    this.group,
  });

  final int competitionId;
  final String competitionName;
  final List<StandingsRowEntity> rows;
  final String? stage;
  final String? group;

  @override
  List<Object?> get props => [
        competitionId,
        competitionName,
        rows,
        stage,
        group,
      ];
}
