import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/sport_event_entity.dart';
import '../domain/repositories/multi_sport_repository.dart';
import 'sports_feed_state.dart';

/// Riverpod controller for the multi-sport real-time feed.
///
/// Manages live events for football, tennis, and basketball with automatic
/// score/status updates via a polling stream. Each sport subscribes to its
/// own real-time channel and the UI presents the selected sport's events.
class SportsFeedNotifier extends StateNotifier<SportsFeedState> {
  SportsFeedNotifier({required MultiSportRepository repository})
      : _repository = repository,
        super(const SportsFeedInitial());

  final MultiSportRepository _repository;

  final Map<SportType, StreamSubscription<List<SportEventEntity>>>
      _subscriptions = {};

  /// Loads the live feed for a single sport and starts its real-time stream.
  Future<void> loadSport(SportType sport) async {
    if (state is SportsFeedLoading && (state as SportsFeedLoading).sport == sport) {
      return;
    }
    state = SportsFeedLoading(sport: sport);
    try {
      final events = await _repository.getLiveEvents(sport);
      _updateSport(sport, events);
      _startLiveStream(sport);
    } on Failure catch (f) {
      state = SportsFeedError(message: f.message, sport: sport);
    } catch (_) {
      state = SportsFeedError(
        message: 'Unable to load live $sport events. Please try again.',
        sport: sport,
      );
    }
  }

  /// Loads live events for all sports at once.
  Future<void> loadAll() async {
    state = const SportsFeedLoading();
    try {
      final all = await _repository.getLiveEventsAll();
      final loaded = SportsFeedLoaded(
        events: all,
        lastUpdated: DateTime.now(),
      );
      state = loaded;
      for (final sport in SportType.values) {
        _startLiveStream(sport);
      }
    } on Failure catch (f) {
      state = SportsFeedError(message: f.message);
    } catch (_) {
      state = const SportsFeedError(
        message: 'Unable to load live events. Please try again.',
      );
    }
  }

  /// Selects a sport to show in the feed.
  void selectSport(SportType sport) {
    if (state is SportsFeedLoaded) {
      state = (state as SportsFeedLoaded).copyWith(selectedSport: sport);
    }
  }

  void _updateSport(SportType sport, List<SportEventEntity> events) {
    final current = state;
    if (current is SportsFeedLoaded) {
      final updated = Map<SportType, List<SportEventEntity>>.from(current.events);
      updated[sport] = events;
      state = current.copyWith(
        events: updated,
        lastUpdated: DateTime.now(),
        stale: false,
      );
    } else {
      state = SportsFeedLoaded(
        events: {sport: events},
        selectedSport: sport,
        lastUpdated: DateTime.now(),
      );
    }
  }

  void _startLiveStream(SportType sport) {
    _subscriptions[sport]?.cancel();
    _subscriptions[sport] = _repository.watchLiveEvents(sport).listen(
      (events) {
        _updateSport(sport, events);
      },
      onError: (Object error) {
        if (state is SportsFeedLoaded) {
          state = (state as SportsFeedLoaded).copyWith(stale: true);
        }
      },
    );
  }

  /// Refreshes the selected sport on demand.
  Future<void> refresh() async {
    final sport = state is SportsFeedLoaded
        ? (state as SportsFeedLoaded).selectedSport
        : SportType.football;
    await loadSport(sport);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
