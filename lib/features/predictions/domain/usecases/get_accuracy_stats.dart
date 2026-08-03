import '../entities/prediction_history_entity.dart';
import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Computes overall accuracy statistics from the user's history.
class GetAccuracyStats implements UseCase<AccuracyStatsEntity, NoParams> {
  const GetAccuracyStats(this._repository);
  final PredictionRepository _repository;

  @override
  Future<AccuracyStatsEntity> call(NoParams params) {
    return _repository.getAccuracyStats();
  }
}
