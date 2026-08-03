import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/standings_entity.dart';

/// Data model for a standings row.
class StandingsRowModel {
  const StandingsRowModel({
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
  final List<String> form;

  factory StandingsRowModel.fromFootballDataJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>? ?? const {};

    List<String> parseForm(dynamic formValue) {
      if (formValue is String) {
        return formValue.split('').map((e) => e.trim()).toList();
      }
      return [];
    }

    return StandingsRowModel(
      position: json['position'] as int? ?? 0,
      teamId: team['id'] as int? ?? 0,
      teamName: team['name'] as String? ?? 'Unknown',
      teamCrest: team['crest'] as String?,
      playedGames: json['playedGames'] as int? ?? 0,
      won: json['won'] as int? ?? 0,
      draw: json['draw'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      goalsFor: json['goalsFor'] as int? ?? 0,
      goalsAgainst: json['goalsAgainst'] as int? ?? 0,
      goalDifference: json['goalDifference'] as int? ?? 0,
      form: parseForm(json['form']),
    );
  }

  StandingsRowEntity toEntity() {
    return StandingsRowEntity(
      position: position,
      teamId: teamId,
      teamName: teamName,
      teamCrest: teamCrest,
      playedGames: playedGames,
      won: won,
      draw: draw,
      lost: lost,
      points: points,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      goalDifference: goalDifference,
      form: form,
    );
  }
}

/// Data model for standings (includes competition metadata).
class StandingsModel {
  const StandingsModel({
    required this.competitionId,
    required this.competitionName,
    required this.rows,
    this.stage,
    this.group,
  });

  final int competitionId;
  final String competitionName;
  final List<StandingsRowModel> rows;
  final String? stage;
  final String? group;

  factory StandingsModel.fromFootballDataJson(Map<String, dynamic> json) {
    final competition = json['competition'] as Map<String, dynamic>? ?? const {};
    final standingsList = json['standings'] as List<dynamic>? ?? [];

    // Use the first table (usually the main one).
    List<StandingsRowModel> rows = [];
    String? stage;
    String? group;

    if (standingsList.isNotEmpty) {
      final table = standingsList.first as Map<String, dynamic>;
      stage = table['stage'] as String?;
      group = table['group'] as String?;
      final tableRows = table['table'] as List<dynamic>? ?? [];
      rows = tableRows
          .map((e) =>
              StandingsRowModel.fromFootballDataJson(e as Map<String, dynamic>))
          .toList();
    }

    return StandingsModel(
      competitionId: competition['id'] as int? ?? 0,
      competitionName: competition['name'] as String? ?? 'Unknown',
      rows: rows,
      stage: stage,
      group: group,
    );
  }

  StandingsEntity toEntity() {
    return StandingsEntity(
      competitionId: competitionId,
      competitionName: competitionName,
      rows: rows.map((e) => e.toEntity()).toList(),
      stage: stage,
      group: group,
    );
  }
}
