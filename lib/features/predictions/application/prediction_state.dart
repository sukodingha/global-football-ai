import '../../home/domain/entities/match_entity.dart';
import '../domain/entities/post_match_comparison_entity.dart';
import '../domain/entities/prediction_entity.dart';
import '../domain/entities/prediction_history_entity.dart';
import '../domain/entities/user_vote_entity.dart';

/// Immutable state for the AI Predictions & Analytics module.
sealed class PredictionState {
  const PredictionState();
}

/// Initial state before any data loads.
class PredictionInitial extends PredictionState {
  const PredictionInitial();
}

/// State while a prediction operation is loading.
class PredictionLoading extends PredictionState {
  const PredictionLoading();
}

/// Loaded state with the full prediction context for the module.
class PredictionLoaded extends PredictionState {
  const PredictionLoaded({
    this.prediction,
    this.history = const [],
    this.comparisons = const [],
    this.accuracy,
    this.voteCounts,
    this.myVote,
    this.upcomingMatches = const [],
    this.isSaving = false,
    this.lastSavedPrediction,
  });

  /// The breakdown for the currently selected match, if any.
  final MatchPredictionEntity? prediction;

  /// The authenticated user's prediction history, newest first.
  final List<PredictionHistoryEntity> history;

  /// Stored post-match comparisons, newest first.
  final List<PostMatchComparisonEntity> comparisons;

  /// Overall accuracy stats computed from history.
  final AccuracyStatsEntity? accuracy;

  /// Current vote counts for the selected prediction.
  final VoteCountsEntity? voteCounts;

  /// The current user's vote on the selected prediction.
  final String? myVote;

  /// Upcoming matches that can be predicted.
  final List<MatchEntity> upcomingMatches;

  /// Whether a history save is in-flight.
  final bool isSaving;

  final MatchPredictionEntity? lastSavedPrediction;

  PredictionLoaded copyWith({
    MatchPredictionEntity? prediction,
    List<PredictionHistoryEntity>? history,
    List<PostMatchComparisonEntity>? comparisons,
    AccuracyStatsEntity? accuracy,
    VoteCountsEntity? voteCounts,
    String? myVote,
    List<MatchEntity>? upcomingMatches,
    bool? isSaving,
    MatchPredictionEntity? lastSavedPrediction,
  }) {
    // Allow clearing the prediction and vote state with sentinel values.
    return PredictionLoaded(
      prediction: prediction ?? this.prediction,
      history: history ?? this.history,
      comparisons: comparisons ?? this.comparisons,
      accuracy: accuracy ?? this.accuracy,
      voteCounts: voteCounts ?? this.voteCounts,
      myVote: myVote ?? this.myVote,
      upcomingMatches: upcomingMatches ?? this.upcomingMatches,
      isSaving: isSaving ?? this.isSaving,
      lastSavedPrediction: lastSavedPrediction ?? this.lastSavedPrediction,
    );
  }
}

/// Error state with a user-safe message.
class PredictionError extends PredictionState {
  const PredictionError({required this.message});
  final String message;
}
