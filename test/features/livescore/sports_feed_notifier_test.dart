import 'package:flutter_test/flutter_test.dart';

import 'package:global_football_ai/features/livescore/application/sports_feed_notifier.dart';
import 'package:global_football_ai/features/livescore/application/sports_feed_state.dart';
import 'package:global_football_ai/features/livescore/domain/entities/sport_event_entity.dart';

import '../../test_helpers/fake_repositories.dart';
import 'fixtures/sports_feed_fixtures.dart';

void main() {
  group('SportsFeedNotifier', () {
    test('initial state is SportsFeedInitial', () {
      final notifier =
          SportsFeedNotifier(repository: loadedSportsRepository());
      expect(notifier.state, isA<SportsFeedInitial>());
      notifier.dispose();
    });

    test('loadAll produces SportsFeedLoaded with all sports', () async {
      final notifier = SportsFeedNotifier(repository: loadedSportsRepository());
      await notifier.loadAll();

      final state = notifier.state;
      expect(state, isA<SportsFeedLoaded>());
      final loaded = state as SportsFeedLoaded;
      expect(loaded.events.keys, containsAll(SportType.values));
      expect(loaded.events[SportType.football], hasLength(2));
      expect(loaded.events[SportType.tennis], hasLength(1));
      expect(loaded.events[SportType.basketball], hasLength(1));
      expect(loaded.selectedSport, SportType.football);
      expect(loaded.lastUpdated, isNotNull);

      notifier.dispose();
    });

    test('selectedEvents returns events for the selected sport', () async {
      final notifier = SportsFeedNotifier(repository: loadedSportsRepository());
      await notifier.loadAll();
      notifier.selectSport(SportType.tennis);

      final state = notifier.state as SportsFeedLoaded;
      expect(state.selectedSport, SportType.tennis);
      expect(state.selectedEvents, hasLength(1));
      expect(state.selectedEvents.first.sport, SportType.tennis);

      notifier.dispose();
    });

    test('totalLive counts only live events', () async {
      final repo = FakeMultiSportRepository(
        events: {
          SportType.football: [
            buildSportEvent(status: SportEventStatus.live),
            buildSportEvent(id: 'f2', status: SportEventStatus.scheduled),
          ],
        },
      );
      final notifier = SportsFeedNotifier(repository: repo);
      await notifier.loadAll();
      expect((notifier.state as SportsFeedLoaded).totalLive, 1);
      notifier.dispose();
    });

    test('loadAll surfaces SportsFeedError on failure', () async {
      final repo = FakeMultiSportRepository(throwOnFetch: true);
      final notifier = SportsFeedNotifier(repository: repo);
      await notifier.loadAll();
      expect(notifier.state, isA<SportsFeedError>());
      expect((notifier.state as SportsFeedError).message, isNotEmpty);
      notifier.dispose();
    });

    test('loadSport loads a single sport and starts its stream', () async {
      final repo = loadedSportsRepository();
      final notifier = SportsFeedNotifier(repository: repo);
      await notifier.loadSport(SportType.basketball);

      final state = notifier.state as SportsFeedLoaded;
      expect(state.events[SportType.basketball], hasLength(1));
      expect(state.selectedSport, SportType.basketball);

      notifier.dispose();
    });

    test('real-time stream updates the state', () async {
      final repo = loadedSportsRepository();
      final notifier = SportsFeedNotifier(repository: repo);
      await notifier.loadAll();

      // Emit an updated score for football.
      final updatedFootball = buildFootballEvents();
      updatedFootball[0] = updatedFootball[0].copyWith(
        home: buildCompetitor(id: 'h', name: 'Team One', score: 3),
      );
      repo.emit({
        SportType.football: updatedFootball,
        SportType.tennis: buildTennisEvents(),
        SportType.basketball: buildBasketballEvents(),
      });

      // Allow the stream to deliver.
      await Future<void>.delayed(Duration.zero);
      final state = notifier.state as SportsFeedLoaded;
      expect(state.events[SportType.football]!.first.home.score, 3);

      notifier.dispose();
    });
  });
}
