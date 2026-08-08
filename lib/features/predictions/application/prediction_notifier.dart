import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../auth/application/auth_providers.dart';
import '../../home/domain/entities/match_entity.dart';
import '../domain/entities/post_match_comparison_entity.dart';
import '../domain/entities/prediction_entity.dart';
import '../domain/entities/prediction_history_entity.dart';
import '../domain/entities/user_vote_entity.dart';
import '../domain/repositories/prediction_repository.dart';
import 'prediction_state.dart';

/// Riverpod controller for the AI Predictions & Analytics module.
///
/// Manages generating predictions, saving history, voting, running
/// post-match comparisons, and reading accuracy stats — all backed by the
/// [PredictionRepository].
class PredictionNotifier extends StateNotifier<PredictionState> {
  PredictionNotifier({
    required PredictionRepository repository,
    required String? Function() currentUserId,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        super(const PredictionInitial());

  final PredictionRepository _repository;
  final String? Function() _currentUserId;

  /// The authenticated user's id, or null if signed out.
  String? get _userId => _currentUserId();

  /// Generates a prediction for [matchId] and loads it into state.
  Future<void> loadPredictionForMatch(int matchId) async {
    state = const PredictionLoading();
    try {
      final prediction = await _repository.getPredictionForMatch(matchId);
      _loaded((s) => s.copyWith(prediction: prediction));
    } on Failure catch (f) {
      state = PredictionError(message: f.message);
    } catch (_) {
      state = const PredictionError(
        message: 'Unable to generate prediction. Please try again.',
      );
    }
  }

  /// Loads the user's prediction history, comparisons, and accuracy stats.
  Future<void> loadDashboard() async {
    state = const PredictionLoading();
    try {
      final history = await _loadHistory();
      final comparisons = await _loadComparisons();
      final accuracy = await _loadAccuracy();
      state = PredictionLoaded(
        history: history,
        comparisons: comparisons,
        accuracy: accuracy,
      );
    } on Failure catch (f) {
      state = PredictionError(message: f.message);
    } catch (_) {
      state = const PredictionError(
        message: 'Unable to load predictions. Please try again.',
      );
    }
  }

  /// Loads only the history (best-effort; keeps current state on error).
  Future<void> loadHistory() async {
    try {
      final history = await _loadHistory();
      _loaded((s) => s.copyWith(history: history));
    } on Failure catch (f) {
      _preserveError(f.message);
    }
  }

  /// Loads only the stored comparisons.
  Future<void> loadComparisons() async {
    try {
      final comparisons = await _loadComparisons();
      _loaded((s) => s.copyWith(comparisons: comparisons));
    } on Failure catch (f) {
      _preserveError(f.message);
    }
  }

  /// Loads only the accuracy stats.
  Future<void> loadAccuracy() async {
    try {
      final accuracy = await _loadAccuracy();
      _loaded((s) => s.copyWith(accuracy: accuracy));
    } on Failure catch (f) {
      _preserveError(f.message);
    }
  }

  /// Saves the currently selected prediction to the user's history.
  Future<String?> savePredictionToHistory() async {
    final prediction = _currentPrediction;
    final userId = _userId;
    if (prediction == null || userId == null) {
      return 'No prediction to save or you are not signed in.';
    }
    _loaded((s) => s.copyWith(isSaving: true));
    try {
      await _repository.savePredictionToHistory(
        userId: userId,
        prediction: prediction,
        matchDate: prediction.matchDate,
      );
      final history = await _loadHistory();
      _loaded((s) => s.copyWith(
            history: history,
            isSaving: false,
            lastSavedPrediction: prediction,
          ));
      return null;
    } on Failure catch (f) {
      _loaded((s) => s.copyWith(isSaving: false));
      return f.message;
    } catch (_) {
      _loaded((s) => s.copyWith(isSaving: false));
      return 'Unable to save prediction. Please try again.';
    }
  }

  /// Votes on the currently selected prediction.
  Future<String?> voteOnPrediction(String vote) async {
    final prediction = _currentPrediction;
    final userId = _userId;
    if (prediction == null || userId == null) {
      return 'No prediction to vote on or you are not signed in.';
    }
    try {
      final voteCounts = await _repository.voteOnPrediction(
        predictionId: '${prediction.matchId}',
        userId: userId,
        vote: vote,
      );
final (counts, myVote) = await _repository.getVoteState(
        predictionId: '${prediction.matchId}',
        userId: userId,
      );
      _loaded((s) => s.copyWith(voteCounts: counts, myVote: myVote));
      return null;
    } on Failure catch (f) {
      return f.message;
    } catch (_) {
      return 'Unable to submit vote. Please try again.';
    }
  }

  /// Runs a post-match comparison against actual results and persists it.
  Future<PostMatchComparisonEntity?> compareWithResult({
    required int actualHomeScore,
    required int actualAwayScore,
    int? actualCorners,
    int? actualCards,
  }) async {
    final prediction = _currentPrediction;
    final userId = _userId;
    if (prediction == null) return null;
    try {
      final comparison = await _repository.compareWithResult(
        prediction: prediction,
        actualHomeScore: actualHomeScore,
        actualAwayScore: actualAwayScore,
        actualCorners: actualCorners,
        actualCards: actualCards,
      );
      if (userId != null) {
        await _repository.saveComparison(
          userId: userId,
          comparison: comparison,
        );
        final comparisons = await _loadComparisons();
        _loaded((s) => s.copyWith(comparisons: comparisons));
      }
      return comparison;
    } on Failure catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Loads upcoming matches so the user can pick one to predict.
  Future<void> loadUpcomingMatches(List<MatchEntity> matches) async {
    _loaded((s) => s.copyWith(upcomingMatches: matches));
  }

  // ── Helpers ────────────────────────────────────────────────────────

  MatchPredictionEntity? get _currentPrediction {
    final s = state;
    if (s is PredictionLoaded) {
      return s.prediction;
    }
    return null;
  }

  Future<List<PredictionHistoryEntity>> _loadHistory() async {
    final userId = _userId;
    if (userId == null) return const [];
    return _repository.getPredictionHistory(userId: userId);
  }

  Future<List<PostMatchComparisonEntity>> _loadComparisons() async {
    final userId = _userId;
    if (userId == null) return const [];
    return _repository.getComparisons(userId: userId);
  }

  Future<AccuracyStatsEntity?> _loadAccuracy() async {
    final userId = _userId;
    if (userId == null) return null;
    try {
      return await _repository.getAccuracyStats(userId: userId);
    } catch (_) {
      return null;
    }
  }

  void _loaded(PredictionLoaded Function(PredictionLoaded) transform) {
    final s = state;
    if (s is PredictionLoaded) {
      state = transform(s);
    } else {
      state = transform(const PredictionLoaded());
    }
  }

  void _preserveError(String message) {
    // Keep the current loaded data; only surface an error if there is none.
    if (state is! PredictionLoaded) {
      state = PredictionError(message: message);
    }
  }

  /// Clears any error state, returning to an empty loaded state.
  void clearError() {
    if (state is PredictionError) {
      state = const PredictionLoaded();
    }
  }
}
