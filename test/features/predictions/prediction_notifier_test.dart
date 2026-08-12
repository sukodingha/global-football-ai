import 'package:flutter_test/flutter_test.dart';

import 'package:global_ai_prediction/features/predictions/application/prediction_notifier.dart';
import 'package:global_ai_prediction/features/predictions/application/prediction_state.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/prediction_entity.dart';

import '../../test_helpers/fake_repositories.dart';
import 'fixtures/prediction_fixtures.dart';

void main() {
  const signedInUser = 'user-1';

  PredictionNotifier buildNotifier(
    FakePredictionRepository repo, {
    String? userId = signedInUser,
  }) {
    return PredictionNotifier(
      repository: repo,
      currentUserId: () => userId,
    );
  }

  group('PredictionNotifier', () {
    test('initial state is PredictionInitial', () {
      final notifier = buildNotifier(FakePredictionRepository());
      expect(notifier.state, isA<PredictionInitial>());
      notifier.dispose();
    });

    test('loadPredictionForMatch transitions to Loading then Loaded', () async {
      final repo = FakePredictionRepository();
      final notifier = buildNotifier(repo);

      final future = notifier.loadPredictionForMatch(7);
      expect(notifier.state, isA<PredictionLoading>());

      await future;
      final state = notifier.state;
      expect(state, isA<PredictionLoaded>());
      final loaded = state as PredictionLoaded;
      expect(loaded.prediction, isNotNull);
      expect(loaded.prediction!.matchId, 1);
      expect(repo.lastMatchedMatchId, 7);

      notifier.dispose();
    });

    test('loadPredictionForMatch surfaces PredictionError on Failure', () async {
      final repo = FakePredictionRepository(throwOnFetch: true);
      final notifier = buildNotifier(repo);

      await notifier.loadPredictionForMatch(1);
      expect(notifier.state, isA<PredictionError>());
      expect((notifier.state as PredictionError).message, isNotEmpty);

      notifier.dispose();
    });

    test('loadDashboard loads history, comparisons, and accuracy', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo);

      await notifier.loadDashboard();
      final state = notifier.state;
      expect(state, isA<PredictionLoaded>());
      final loaded = state as PredictionLoaded;
      expect(loaded.history, hasLength(2));
      expect(loaded.comparisons, hasLength(1));
      expect(loaded.accuracy, isNotNull);
      expect(loaded.accuracy!.totalPredictions, 10);

      notifier.dispose();
    });

    test('loadDashboard returns empty data when signed out', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo, userId: null);

      await notifier.loadDashboard();
      final loaded = notifier.state as PredictionLoaded;
      expect(loaded.history, isEmpty);
      expect(loaded.comparisons, isEmpty);
      expect(loaded.accuracy, isNull);

      notifier.dispose();
    });

    test('loadDashboard surfaces PredictionError on failure', () async {
      final repo = FakePredictionRepository(throwOnFetch: true);
      final notifier = buildNotifier(repo);

      await notifier.loadDashboard();
      expect(notifier.state, isA<PredictionError>());

      notifier.dispose();
    });

    test('loadHistory populates history while preserving data', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo);
      await notifier.loadDashboard();

      await notifier.loadHistory();
      final loaded = notifier.state as PredictionLoaded;
      expect(loaded.history, hasLength(2));
      expect(repo.historyFetchCount, greaterThanOrEqualTo(2));

      notifier.dispose();
    });

    test('savePredictionToHistory returns error when not signed in', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo, userId: null);

      // No prediction loaded yet.
      final error = await notifier.savePredictionToHistory();
      expect(error, isNotNull);
      expect(error, contains('signed in'));

      notifier.dispose();
    });

    test('savePredictionToHistory returns error when no prediction', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo);

      final error = await notifier.savePredictionToHistory();
      expect(error, contains('No prediction'));

      notifier.dispose();
    });

    test('savePredictionToHistory saves and refreshes history', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo);
      await notifier.loadPredictionForMatch(1);

      final error = await notifier.savePredictionToHistory();
      expect(error, isNull);
      expect(repo.savePredictionCount, 1);

      final loaded = notifier.state as PredictionLoaded;
      expect(loaded.isSaving, isFalse);
      expect(loaded.lastSavedPrediction, isNotNull);
      expect(loaded.lastSavedPrediction!.matchId, 1);

      notifier.dispose();
    });

    test('voteOnPrediction updates vote counts and myVote', () async {
      final repo = FakePredictionRepository(myVote: 'up');
      final notifier = buildNotifier(repo);
      await notifier.loadPredictionForMatch(1);

      final error = await notifier.voteOnPrediction('up');
      expect(error, isNull);
      expect(repo.voteCount, 1);

      final loaded = notifier.state as PredictionLoaded;
      expect(loaded.voteCounts, isNotNull);
      expect(loaded.voteCounts!.upvotes, 10);
      expect(loaded.myVote, 'up');

      notifier.dispose();
    });

    test('voteOnPrediction returns error when not signed in', () async {
      final repo = FakePredictionRepository();
      final notifier = buildNotifier(repo, userId: null);

      final error = await notifier.voteOnPrediction('up');
      expect(error, contains('signed in'));

      notifier.dispose();
    });

    test('compareWithResult saves comparison and refreshes list', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo);
      await notifier.loadPredictionForMatch(1);

      final comparison = await notifier.compareWithResult(
        actualHomeScore: 2,
        actualAwayScore: 1,
      );
      expect(comparison, isNotNull);
      expect(repo.saveComparisonCount, 1);

      final loaded = notifier.state as PredictionLoaded;
      expect(loaded.comparisons, isNotEmpty);

      notifier.dispose();
    });

    test('compareWithResult returns null when no prediction loaded', () async {
      final repo = loadedPredictionRepository();
      final notifier = buildNotifier(repo);

      final comparison = await notifier.compareWithResult(
        actualHomeScore: 2,
        actualAwayScore: 1,
      );
      expect(comparison, isNull);

      notifier.dispose();
    });

    test('loadUpcomingMatches populates the upcoming matches list', () async {
      final repo = FakePredictionRepository();
      final notifier = buildNotifier(repo);

      await notifier.loadUpcomingMatches(buildPredictionUpcomingMatches());
      final loaded = notifier.state as PredictionLoaded;
      expect(loaded.upcomingMatches, hasLength(2));
      expect(loaded.upcomingMatches.first.id, 20);

      notifier.dispose();
    });

    test('clearError resets an error state to loaded', () async {
      final repo = FakePredictionRepository(throwOnFetch: true);
      final notifier = buildNotifier(repo);
      await notifier.loadPredictionForMatch(1);
      expect(notifier.state, isA<PredictionError>());

      notifier.clearError();
      expect(notifier.state, isA<PredictionLoaded>());

      notifier.dispose();
    });

    test('maps unknown exceptions to a friendly error', () async {
      final repo = FakePredictionRepository(throwOnFetch: true);
      final notifier = buildNotifier(repo);
      await notifier.loadPredictionForMatch(1);
      expect(notifier.state, isA<PredictionError>());
      expect((notifier.state as PredictionError).message, isNotEmpty);
      notifier.dispose();
    });
  });
}
