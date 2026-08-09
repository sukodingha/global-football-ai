import '../entities/post_match_comparison_entity.dart';
import '../entities/prediction_entity.dart';

/// Base contract for prediction use cases.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// No parameters.
class NoParams {
  const NoParams();
}

/// Parameters for fetching a match prediction.
class MatchPredictionParams {
  const MatchPredictionParams(this.matchId);
  final int matchId;
}

/// Parameters for a vote.
class VoteParams {
  const VoteParams({
    required this.predictionId,
    required this.userId,
    required this.vote,
  });
  final String predictionId;
  final String userId;
  final String vote;
}

/// Parameters for comparing with the actual result.
class ComparisonParams {
  const ComparisonParams({
    required this.prediction,
    required this.actualHomeScore,
    required this.actualAwayScore,
    this.actualCorners,
    this.actualCards,
  });
  final MatchPredictionEntity prediction;
  final int actualHomeScore;
  final int actualAwayScore;
  final int? actualCorners;
  final int? actualCards;
}

/// Parameters for persisting a post-match comparison.
class SaveComparisonParams {
  const SaveComparisonParams({
    required this.userId,
    required this.comparison,
  });
  final String userId;
  final PostMatchComparisonEntity comparison;
}

/// Parameters for fetching stored comparisons.
class GetComparisonsParams {
  const GetComparisonsParams({this.limit = 20});
  final int limit;
}

/// Parameters for saving a prediction to history.
class SaveHistoryParams {
  const SaveHistoryParams({
    required this.userId,
    required this.prediction,
    this.matchDate,
  });
  final String userId;
  final MatchPredictionEntity prediction;
  final DateTime? matchDate;
}

