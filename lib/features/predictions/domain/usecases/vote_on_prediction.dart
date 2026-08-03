import '../entities/user_vote_entity.dart';
import '../repositories/prediction_repository.dart';
import 'usecase.dart';

/// Votes on a prediction (up/down/neutral).
class VoteOnPrediction implements UseCase<VoteCountsEntity, VoteParams> {
  const VoteOnPrediction(this._repository);
  final PredictionRepository _repository;

  @override
  Future<VoteCountsEntity> call(VoteParams params) {
    return _repository.voteOnPrediction(
      predictionId: params.predictionId,
      userId: params.userId,
      vote: params.vote,
    );
  }
}
