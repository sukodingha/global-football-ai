import 'package:equatable/equatable.dart';

/// A single fantasy scoring rule mapping a football event to points.
class ScoringRuleEntity extends Equatable {
  const ScoringRuleEntity({
    required this.id,
    required this.label,
    required this.points,
    this.icon,
  });

  final String id;
  final String label;
  final int points;
  final String? icon;

  @override
  List<Object?> get props => [id, label, points, icon];
}

/// The standard fantasy points configuration used by the scoring engine.
///
/// Mirrors common fantasy football scoring conventions:
/// - Goals (weighted by position)
/// - Assists
/// - Clean sheets (GK / DEF only)
/// - Yellow / red cards
/// - Saves (goalkeepers)
/// - Appearance / minutes
class FantasyScoringRules {
  const FantasyScoringRules._();

  static const int goalGoalkeeper = 6;
  static const int goalDefender = 6;
  static const int goalMidfielder = 5;
  static const int goalForward = 4;
  static const int assist = 3;
  static const int cleanSheetGoalkeeper = 4;
  static const int cleanSheetDefender = 4;
  static const int yellowCard = -1;
  static const int redCard = -3;
  static const int everyThreeSaves = 1;
  static const int appearance = 1;
  static const int minutesPlayedMin = 60;

  /// Base rules surfaced for the UI's "Scoring" info panel.
  static const List<ScoringRuleEntity> all = [
    ScoringRuleEntity(
      id: 'goal_gk',
      label: 'Goal (Goalkeeper)',
      points: goalGoalkeeper,
      icon: 'sports_soccer',
    ),
    ScoringRuleEntity(
      id: 'goal_def',
      label: 'Goal (Defender)',
      points: goalDefender,
      icon: 'sports_soccer',
    ),
    ScoringRuleEntity(
      id: 'goal_mid',
      label: 'Goal (Midfielder)',
      points: goalMidfielder,
      icon: 'sports_soccer',
    ),
    ScoringRuleEntity(
      id: 'goal_fw',
      label: 'Goal (Forward)',
      points: goalForward,
      icon: 'sports_soccer',
    ),
    ScoringRuleEntity(
      id: 'assist',
      label: 'Assist',
      points: assist,
      icon: 'assistant',
    ),
    ScoringRuleEntity(
      id: 'clean_sheet',
      label: 'Clean Sheet (GK/DEF)',
      points: cleanSheetGoalkeeper,
      icon: 'shield',
    ),
    ScoringRuleEntity(
      id: 'yellow_card',
      label: 'Yellow Card',
      points: yellowCard,
      icon: 'square',
    ),
    ScoringRuleEntity(
      id: 'red_card',
      label: 'Red Card',
      points: redCard,
      icon: 'block',
    ),
    ScoringRuleEntity(
      id: 'every_three_saves',
      label: 'Every 3 Saves (GK)',
      points: everyThreeSaves,
      icon: 'sports_handball',
    ),
    ScoringRuleEntity(
      id: 'appearance',
      label: 'Appearance',
      points: appearance,
      icon: 'person',
    ),
  ];
}

