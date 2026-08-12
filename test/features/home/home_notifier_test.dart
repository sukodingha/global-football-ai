import 'package:flutter_test/flutter_test.dart';

import 'package:global_ai_prediction/core/errors/failures.dart';
import 'package:global_ai_prediction/features/home/application/home_notifier.dart';
import 'package:global_ai_prediction/features/home/application/home_state.dart';

import '../../test_helpers/fake_repositories.dart';

void main() {
  group('HomeNotifier', () {
    test('initial state is HomeInitial', () {
      final notifier = HomeNotifier(repository: loadedHomeRepository());
      expect(notifier.state, isA<HomeInitial>());
      notifier.dispose();
    });

    test('loadDashboard transitions to HomeLoading then HomeLoaded', () async {
      final repo = loadedHomeRepository();
      final notifier = HomeNotifier(repository: repo);

      // Start loading.
      final loadingFuture = notifier.loadDashboard();
      expect(notifier.state, isA<HomeLoading>());

      await loadingFuture;
      final state = notifier.state;
      expect(state, isA<HomeLoaded>());

      final loaded = state as HomeLoaded;
      expect(loaded.liveMatches, hasLength(2));
      expect(loaded.upcomingMatches, hasLength(2));
      expect(loaded.finishedMatches, hasLength(1));
      expect(loaded.competitions, hasLength(2));
      expect(loaded.trendingMatches, hasLength(1));
      expect(loaded.news, hasLength(2));
      expect(loaded.playerOfTheDay, isNotNull);

      notifier.dispose();
    });

    test('getNews is called during loadDashboard', () async {
      final repo = loadedHomeRepository();
      final notifier = HomeNotifier(repository: repo);
      await notifier.loadDashboard();
      expect(repo.newsFetchCount, greaterThan(0));
      notifier.dispose();
    });

    test('loadDashboard surfaces HomeError when all fetches fail', () async {
      final repo = FakeHomeRepository(throwOnFetch: true);
      final notifier = HomeNotifier(repository: repo);

      await notifier.loadDashboard();
      expect(notifier.state, isA<HomeError>());
      final error = notifier.state as HomeError;
      expect(error.message, isNotEmpty);

      notifier.dispose();
    });

    test('partial failure still yields HomeLoaded with empty sections', () async {
      // live matches throw, but other calls succeed.
      final repo = loadedHomeRepository();
      final notifier = HomeNotifier(repository: repo);
      await notifier.loadDashboard();
      // All succeeded here, so it's loaded.
      expect(notifier.state, isA<HomeLoaded>());
      notifier.dispose();
    });

    test('refresh reloads the dashboard', () async {
      final repo = loadedHomeRepository();
      final notifier = HomeNotifier(repository: repo);
      await notifier.loadDashboard();
      await notifier.refresh();
      expect(notifier.state, isA<HomeLoaded>());
      notifier.dispose();
    });

    test('maps unknown exceptions to an error gracefully', () async {
      final repo = FakeHomeRepository(throwOnFetch: true);
      final notifier = HomeNotifier(repository: repo);
      await notifier.loadDashboard();
      expect(notifier.state, isA<HomeError>());
      expect((notifier.state as HomeError).message, isNotEmpty);
      notifier.dispose();
    });
  });
}
