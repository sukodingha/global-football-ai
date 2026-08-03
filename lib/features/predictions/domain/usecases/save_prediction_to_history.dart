import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Saves a prediction into the user's history.
class SavePredictionToHistory implements UseCase<void, SaveHistoryParams> {
  const SavePredictionToHistory(this._repository);
  final PredictionRepository _repository;

  @override
  Future<void> call(SaveHistoryParams params) {
    return _repository.savePredictionToHistory(
      userId: params.userId,
      prediction: params.prediction,
      matchDate: params.matchDate,
    );
  }
}
