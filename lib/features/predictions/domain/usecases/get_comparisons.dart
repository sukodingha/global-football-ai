import '../entities/post_match_comparison_entity.dart';
import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Loads the user's stored post-match comparisons, newest first.
class GetComparisons
    implements UseCase<List<PostMatchComparisonEntity>, GetComparisonsParams> {
  const GetComparisons(this._repository);
  final PredictionRepository _repository;

  @override
  Future<List<PostMatchComparisonEntity>> call(GetComparisonsParams params) {
    return _repository.getComparisons(limit: params.limit);
  }
}
