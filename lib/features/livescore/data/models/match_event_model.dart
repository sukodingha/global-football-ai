import '../../domain/entities/match_timeline_entity.dart';

/// Data model for a match timeline event.
class MatchEventModel {
  const MatchEventModel({
    required this.id,
    required this.type,
    required this.minute,
    this.additionalMinute,
    required this.teamId,
    required this.teamName,
    this.playerName,
    this.assistPlayerName,
    this.homeScore,
    this.awayScore,
    this.detail,
  });

  final int id;
  final MatchEventType type;
  final int minute;
  final int? additionalMinute;
  final int teamId;
  final String teamName;
  final String? playerName;
  final String? assistPlayerName;
  final int? homeScore;
  final int? awayScore;
  final String? detail;

  factory MatchEventModel.fromFootballDataJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>? ?? const {};
    final player = json['player'] as Map<String, dynamic>?;
    final assist = json['assist'] as Map<String, dynamic>?;
    final typeStr = json['type'] as String? ?? '';

    MatchEventType eventType;
    final subType = json['subType'] as String?;
    if (subType != null && subType.toUpperCase() == 'OWN_GOAL') {
      eventType = MatchEventType.ownGoal;
    } else {
      eventType = MatchEventType.fromApi(typeStr);
    }

    return MatchEventModel(
      id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      type: eventType,
      minute: json['minute'] as int? ?? 0,
      additionalMinute: json['extraTime'] as int?,
      teamId: team['id'] as int? ?? 0,
      teamName: team['name'] as String? ?? 'Unknown',
      playerName: player?['name'] as String?,
      assistPlayerName: assist?['name'] as String?,
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      detail: json['detail'] as String?,
    );
  }

  /// Converts to domain entity.
  MatchEventEntity toEntity() {
    return MatchEventEntity(
      id: id,
      type: type,
      minute: minute,
      additionalMinute: additionalMinute,
      teamId: teamId,
      teamName: teamName,
      playerName: playerName,
      assistPlayerName: assistPlayerName,
      homeScore: homeScore,
      awayScore: awayScore,
      detail: detail,
    );
  }
}
