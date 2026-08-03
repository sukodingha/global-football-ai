import '../entities/prediction_history_entity.dart';
import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Fetches the user's prediction history.
class GetPredictionHistory implements UseCase<List<PredictionHistoryEntity>, NoParams> {
  const GetPredictionHistory(this._repository);
  final PredictionRepository _repository;

  @override
  Future<List<PredictionHistoryEntity>> call(NoParams params) {
    return _repository.getPredictionHistory();
  }
}
