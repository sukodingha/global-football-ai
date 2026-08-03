import '../../domain/entities/match_statistics_entity.dart';

/// Data model for a match statistic category.
class MatchStatisticModel {
  const MatchStatisticModel({
    required this.category,
    required this.homeValue,
    required this.awayValue,
    this.homePercentage,
    this.awayPercentage,
  });

  final String category;
  final String homeValue;
  final String awayValue;
  final double? homePercentage;
  final double? awayPercentage;

  /// Attempts to parse percentage values from raw values (e.g. "55%" or "12").
  static double? _parsePercentage(String value) {
    if (value.endsWith('%')) {
      return double.tryParse(value.replaceAll('%', ''))?.clamp(0, 100) ?? 0;
    }
    // For counts, we can't infer a percentage without the other side,
    // so return null.
    return null;
  }

  /// Parses a single stat from the football-data.org halfTime/fullTime/extratime
  /// score structures or directly from a stats array.
  factory MatchStatisticModel.fromMap({required String category, required String homeValue, required String awayValue}) {
    double? homePct;
    double? awayPct;

    if (category.toLowerCase() == 'possession') {
      homePct = _parsePercentage(homeValue);
      awayPct = _parsePercentage(awayValue);
      if (homePct != null && awayPct == null) {
        awayPct = 100.0 - homePct;
      }
    }

    return MatchStatisticModel(
      category: category,
      homeValue: homeValue,
      awayValue: awayValue,
      homePercentage: homePct,
      awayPercentage: awayPct,
    );
  }

  /// Parses from an API-Football style stats array.
  factory MatchStatisticModel.fromApiFootballJson(
      Map<String, dynamic> json) {
    return MatchStatisticModel(
      category: json['type'] as String? ?? 'Stat',
      homeValue: json['home'] as String? ?? '0',
      awayValue: json['away'] as String? ?? '0',
    );
  }

  MatchStatisticEntity toEntity() {
    return MatchStatisticEntity(
      category: category,
      homeValue: homeValue,
      awayValue: awayValue,
      homePercentage: homePercentage,
      awayPercentage: awayPercentage,
    );
  }
}
