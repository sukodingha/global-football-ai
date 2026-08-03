import '../../../home/data/models/match_model.dart';
import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/fixture_entity.dart';

/// Data model for a fixture.
class FixtureModel {
  const FixtureModel({
    required this.match,
    this.homeForm = const [],
    this.awayForm = const [],
    this.round,
    this.matchday,
  });

  final MatchModel match;
  final List<String> homeForm;
  final List<String> awayForm;
  final String? round;
  final int? matchday;

  factory FixtureModel.fromFootballDataJson(Map<String, dynamic> json) {
    final matchModel = MatchModel.fromJson(json);
    return FixtureModel(
      match: matchModel,
      round: json['round'] as String?,
      matchday: json['matchday'] as int?,
    );
  }

  FixtureEntity toEntity() {
    return FixtureEntity(
      match: match.toEntity(),
      homeForm: homeForm,
      awayForm: awayForm,
      round: round,
      matchday: matchday,
    );
  }
}
