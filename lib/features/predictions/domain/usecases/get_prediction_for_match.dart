import '../entities/prediction_entity.dart';
import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Generates a full AI prediction breakdown for a match.
class GetPredictionForMatch implements UseCase<MatchPredictionEntity, MatchPredictionParams> {
  const GetPredictionForMatch(this._repository);
  final PredictionRepository _repository;

  @override
  Future<MatchPredictionEntity> call(MatchPredictionParams params) {
    return _repository.getPredictionForMatch(params.matchId);
  }
}
