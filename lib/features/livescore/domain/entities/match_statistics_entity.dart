import 'package:equatable/equatable.dart';

/// A single match statistic category (possession, shots, fouls, etc.).
class MatchStatisticEntity extends Equatable {
  const MatchStatisticEntity({
    required this.category,
    required this.homeValue,
    required this.awayValue,
    this.homePercentage,
    this.awayPercentage,
  });

  /// Category name (e.g. "Possession", "Shots on Target", "Fouls", "Corners").
  final String category;

  /// The raw numeric/string value for the home team.
  final String homeValue;

  /// The raw numeric/string value for the away team.
  final String awayValue;

  /// Percentage for visual bar (0.0 – 1.0).
  final double? homePercentage;

  /// Percentage for visual bar (0.0 – 1.0).
  final double? awayPercentage;

  @override
  List<Object?> get props => [
        category,
        homeValue,
        awayValue,
        homePercentage,
        awayPercentage,
      ];
}
