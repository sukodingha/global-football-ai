import '../entities/post_match_comparison_entity.dart';
import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Compares an AI prediction against the actual match result.
class CompareWithResult implements UseCase<PostMatchComparisonEntity, ComparisonParams> {
  const CompareWithResult(this._repository);
  final PredictionRepository _repository;

  @override
  Future<PostMatchComparisonEntity> call(ComparisonParams params) {
    return _repository.compareWithResult(
      prediction: params.prediction,
      actualHomeScore: params.actualHomeScore,
      actualAwayScore: params.actualAwayScore,
      actualCorners: params.actualCorners,
      actualCards: params.actualCards,
    );
  }
}
