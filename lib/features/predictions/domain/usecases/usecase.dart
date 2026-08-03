/// Base contract for prediction use cases.
abstract class UseCase<Type, Params> {
  Type call(Params params);
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
  });
  final MatchPredictionEntity prediction;
  final int actualHomeScore;
  final int actualAwayScore;
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

