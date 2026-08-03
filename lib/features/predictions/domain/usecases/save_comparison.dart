import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Persists a post-match comparison for the authenticated user.
class SaveComparison implements UseCase<void, SaveComparisonParams> {
  const SaveComparison(this._repository);
  final PredictionRepository _repository;

  @override
  Future<void> call(SaveComparisonParams params) {
    return _repository.saveComparison(
      userId: params.userId,
      comparison: params.comparison,
    );
  }
}
