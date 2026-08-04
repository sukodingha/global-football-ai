import '../../domain/entities/fantasy_player_entity.dart';
import '../../domain/entities/scoring_rule_entity.dart';

/// Computes fantasy points from live match events.
///
/// The engine is deterministic and pure: given a player's current stats and
/// a match event, it returns the updated stats and the number of points
/// earned for that event. This keeps scoring consistent across clients and
/// testable in isolation.
class ScoringEngine {
  const ScoringEngine();

  /// Applies a single scoring event to [player] and returns the updated
  /// player plus the delta points earned for this event.
  ///
  /// [eventType] is one of:
  ///   - `goal`
  ///   - `assist`
  ///   - `clean_sheet`
  ///   - `yellow_card`
  ///   - `red_card`
  ///   - `save`
  ///   - `appearance`
  ///   - `minutes` (with [quantity] = minutes played)
  (FantasyPlayerEntity, int) applyEvent(
    FantasyPlayerEntity player,
    String eventType, {
    int quantity = 1,
  }) {
    final stats = player.stats;
    int points = 0;
    int deltaPoints = 0;

    switch (eventType) {
      case 'goal':
        final newGoals = stats.goals + quantity;
        deltaPoints = _goalPoints(player.position) * quantity;
        points = deltaPoints;
        stats = stats.copyWith(goals: newGoals, points: stats.points + deltaPoints);
        break;
      case 'assist':
        final newAssists = stats.assists + quantity;
        deltaPoints = FantasyScoringRules.assist * quantity;
        points = deltaPoints;
        stats = stats.copyWith(
            assists: newAssists, points: stats.points + deltaPoints);
        break;
      case 'clean_sheet':
        final newCleanSheets = stats.cleanSheets + quantity;
        deltaPoints = _cleanSheetPoints(player.position) * quantity;
        points = deltaPoints;
        stats = stats.copyWith(
            cleanSheets: newCleanSheets, points: stats.points + deltaPoints);
        break;
      case 'yellow_card':
        final newYellows = stats.yellowCards + quantity;
        deltaPoints = FantasyScoringRules.yellowCard * quantity;
        points = deltaPoints;
        stats = stats.copyWith(
            yellowCards: newYellows, points: stats.points + deltaPoints);
        break;
      case 'red_card':
        final newReds = stats.redCards + quantity;
        deltaPoints = FantasyScoringRules.redCard * quantity;
        points = deltaPoints;
        stats = stats.copyWith(
            redCards: newReds, points: stats.points + deltaPoints);
        break;
      case 'save':
        final newSaves = stats.saves + quantity;
        // 1 point per 3 saves.
        final newSavesPoints =
            (newSaves ~/ 3) * FantasyScoringRules.everyThreeSaves;
        deltaPoints = newSavesPoints - stats.savesPoints;
        points = deltaPoints;
        stats = stats.copyWith(
          saves: newSaves,
          savesPoints: newSavesPoints,
          points: stats.points + deltaPoints,
        );
        break;
      case 'appearance':
        final newAppearances = stats.appearances + quantity;
        deltaPoints = FantasyScoringRules.appearance * quantity;
        points = deltaPoints;
        stats = stats.copyWith(
            appearances: newAppearances, points: stats.points + deltaPoints);
        break;
      case 'minutes':
        final newMinutes = stats.minutesPlayed + quantity;
        // 2 bonus points if the player crosses the 60-minute threshold.
        final crossed =
            stats.minutesPlayed < FantasyScoringRules.minutesPlayedMin &&
                newMinutes >= FantasyScoringRules.minutesPlayedMin;
        deltaPoints = crossed ? 2 : 0;
        points = deltaPoints;
        stats = stats.copyWith(
            minutesPlayed: newMinutes, points: stats.points + deltaPoints);
        break;
      default:
        break;
    }

    final updated = player.copyWith(
      stats: stats,
      totalPoints: player.totalPoints + deltaPoints,
    );
    return (updated, deltaPoints);
  }

  int _goalPoints(FantasyPosition position) {
    switch (position) {
      case FantasyPosition.goalkeeper:
        return FantasyScoringRules.goalGoalkeeper;
      case FantasyPosition.defender:
        return FantasyScoringRules.goalDefender;
      case FantasyPosition.midfielder:
        return FantasyScoringRules.goalMidfielder;
      case FantasyPosition.forward:
        return FantasyScoringRules.goalForward;
    }
  }

  int _cleanSheetPoints(FantasyPosition position) {
    switch (position) {
      case FantasyPosition.goalkeeper:
      case FantasyPosition.defender:
        return FantasyScoringRules.cleanSheetGoalkeeper;
      case FantasyPosition.midfielder:
      case FantasyPosition.forward:
        return 0;
    }
  }
}

