import 'package:equatable/equatable.dart';

/// Type of match event on the timeline.
enum MatchEventType {
  goal,
  yellowCard,
  secondYellowCard,
  redCard,
  substitution,
  penalty,
  ownGoal,
  missedPenalty,
  varDecision,
  shotOnTarget,
  shotOffTarget,
  foul,
  corner,
  offside;

  /// Parses from an API string.
  static MatchEventType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'GOAL':
        return MatchEventType.goal;
      case 'YELLOW_CARD':
        return MatchEventType.yellowCard;
      case 'SECOND_YELLOW_CARD':
        return MatchEventType.secondYellowCard;
      case 'RED_CARD':
        return MatchEventType.redCard;
      case 'SUBSTITUTION':
        return MatchEventType.substitution;
      case 'PENALTY':
        return MatchEventType.penalty;
      case 'OWN_GOAL':
        return MatchEventType.ownGoal;
      case 'MISSED_PENALTY':
        return MatchEventType.missedPenalty;
      case 'VAR':
        return MatchEventType.varDecision;
      default:
        return MatchEventType.shotOnTarget;
    }
  }

  /// Human-readable label for the event type.
  String get label {
    switch (this) {
      case MatchEventType.goal:
        return 'Goal';
      case MatchEventType.yellowCard:
        return 'Yellow Card';
      case MatchEventType.secondYellowCard:
        return 'Second Yellow';
      case MatchEventType.redCard:
        return 'Red Card';
      case MatchEventType.substitution:
        return 'Substitution';
      case MatchEventType.penalty:
        return 'Penalty';
      case MatchEventType.ownGoal:
        return 'Own Goal';
      case MatchEventType.missedPenalty:
        return 'Missed Penalty';
      case MatchEventType.varDecision:
        return 'VAR Decision';
      default:
        return 'Event';
    }
  }
}

/// A single event on the match timeline.
class MatchEventEntity extends Equatable {
  const MatchEventEntity({
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

  @override
  List<Object?> get props => [
        id,
        type,
        minute,
        additionalMinute,
        teamId,
        teamName,
        playerName,
        assistPlayerName,
        homeScore,
        awayScore,
        detail,
      ];
}
