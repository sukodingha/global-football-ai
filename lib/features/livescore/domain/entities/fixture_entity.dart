import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/match_entity.dart';

/// A fixture (upcoming or recently finished match) associated with a
/// competition or team.
class FixtureEntity extends Equatable {
  const FixtureEntity({
    required this.match,
    this.homeForm = const [],
    this.awayForm = const [],
    this.round,
    this.matchday,
  });

  /// The underlying match entity.
  final MatchEntity match;

  /// Home team recent form strings.
  final List<String> homeForm;

  /// Away team recent form strings.
  final List<String> awayForm;

  /// Tournament round, if applicable.
  final String? round;

  /// Matchday number.
  final int? matchday;

  @override
  List<Object?> get props => [
        match,
        homeForm,
        awayForm,
        round,
        matchday,
      ];
}
