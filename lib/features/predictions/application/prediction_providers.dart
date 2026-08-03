import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../home/domain/entities/match_entity.dart';
import '../data/dependency_injection.dart';
import '../domain/entities/post_match_comparison_entity.dart';
import '../domain/entities/prediction_entity.dart';
import '../domain/entities/prediction_history_entity.dart';
import '../domain/entities/user_vote_entity.dart';
import 'prediction_notifier.dart';
import 'prediction_state.dart';

/// Provider for the [PredictionNotifier] controller.
final predictionNotifierProvider =
    StateNotifierProvider<PredictionNotifier, PredictionState>((ref) {
  final repository = ref.watch(predictionRepositoryProvider);
  return PredictionNotifier(
    repository: repository,
    currentUserId: () =>
        ref.read(currentUserProvider)?.id,
  );
});

/// Selector for the currently selected prediction.
final selectedPredictionProvider = Provider<MatchPredictionEntity?>((ref) {
  final state = ref.watch(predictionNotifierProvider);
  if (state is PredictionLoaded) {
    return state.prediction;
  }
  return null;
});

/// Selector for the user's prediction history.
final predictionHistoryProvider = Provider<List<PredictionHistoryEntity>>((ref) {
  final state = ref.watch(predictionNotifierProvider);
  if (state is PredictionLoaded) {
    return state.history;
  }
  return const [];
});

/// Selector for stored post-match comparisons.
final comparisonListProvider = Provider<List<PostMatchComparisonEntity>>((ref) {
  final state = ref.watch(predictionNotifierProvider);
  if (state is PredictionLoaded) {
    return state.comparisons;
  }
  return const [];
});

/// Selector for the accuracy stats.
final accuracyStatsProvider = Provider<AccuracyStatsEntity?>((ref) {
  final state = ref.watch(predictionNotifierProvider);
  if (state is PredictionLoaded) {
    return state.accuracy;
  }
  return null;
});

/// Selector for the current vote counts.
final voteCountsProvider = Provider<VoteCountsEntity?>((ref) {
  final state = ref.watch(predictionNotifierProvider);
  if (state is PredictionLoaded) {
    return state.voteCounts;
  }
  return null;
});

/// Selector for the current user's vote on the selected prediction.
final myVoteProvider = Provider<String?>((ref) {
  final state = ref.watch(predictionNotifierProvider);
  if (state is PredictionLoaded) {
    return state.myVote;
  }
  return null;
});

/// Selector for upcoming matches available for prediction.
final upcomingPredictionMatchesProvider = Provider<List<MatchEntity>>((ref) {
  final state = ref.watch(predictionNotifierProvider);
  if (state is PredictionLoaded) {
    return state.upcomingMatches;
  }
  return const [];
});
