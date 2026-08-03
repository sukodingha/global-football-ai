import '../../../core/errors/failures.dart';
import '../entities/post_match_comparison_entity.dart';
import '../entities/prediction_entity.dart';
import '../entities/prediction_history_entity.dart';
import '../entities/user_vote_entity.dart';

/// Contract for the prediction repository.
///
/// The implementation combines a real statistical prediction engine
/// (Poisson-based expected goals) fed by the football data API, plus
/// Firebase persistence for history, votes, and comparisons.
abstract class PredictionRepository {
  /// Generates a full prediction breakdown for a match.
  Future<MatchPredictionEntity> getPredictionForMatch(int matchId);

  /// Returns the authenticated user's prediction history, newest first.
  Future<List<PredictionHistoryEntity>> getPredictionHistory({
    String? userId,
    int limit = 50,
  });

  /// Saves a prediction into the user's history.
  Future<void> savePredictionToHistory({
    required String userId,
    required MatchPredictionEntity prediction,
    DateTime? matchDate,
  });

  /// Votes on a prediction.
  ///
  /// `vote` is one of 'up' | 'down' | 'neutral'.
  Future<VoteCountsEntity> voteOnPrediction({
    required String predictionId,
    required String userId,
    required String vote,
  });

  /// Returns current vote counts and the user's own vote for a prediction.
  Future<(VoteCountsEntity, String?)> getVoteState({
    required String predictionId,
    required String userId,
  });

  /// Compares an AI prediction against the actual match result.
  Future<PostMatchComparisonEntity> compareWithResult({
    required MatchPredictionEntity prediction,
    required int actualHomeScore,
    required int actualAwayScore,
  });

  /// Computes overall accuracy statistics from the user's history.
  Future<AccuracyStatsEntity> getAccuracyStats({String? userId});

  /// Marks a settled match's prediction as won/lost in history.
  Future<void> resolvePrediction({
    required String historyId,
    required bool isCorrect,
  });
}

/// Result wrapper for prediction repository operations.
class PredictionResult<T> {
  const PredictionResult._(this.value, this.failure);
  const PredictionResult.success(T value) : this._(value, null);
  const PredictionResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}

