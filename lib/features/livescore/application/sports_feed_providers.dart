import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/sport_event_entity.dart';
import '../data/dependency_injection.dart';
import 'sports_feed_notifier.dart';
import 'sports_feed_state.dart';

/// Provider for the [SportsFeedNotifier] controller.
final sportsFeedNotifierProvider =
    StateNotifierProvider<SportsFeedNotifier, SportsFeedState>((ref) {
  final repository = ref.watch(multiSportRepositoryProvider);
  return SportsFeedNotifier(repository: repository);
});

/// Selector for the currently selected sport.
final selectedSportProvider = Provider<SportType>((ref) {
  final state = ref.watch(sportsFeedNotifierProvider);
  if (state is SportsFeedLoaded) {
    return state.selectedSport;
  }
  return SportType.football;
});

/// Selector for the events of the currently selected sport.
final selectedSportEventsProvider = Provider<List<SportEventEntity>>((ref) {
  final state = ref.watch(sportsFeedNotifierProvider);
  if (state is SportsFeedLoaded) {
    return state.selectedEvents;
  }
  return const [];
});

/// Selector for the total live event count across all sports.
final totalLiveEventsProvider = Provider<int>((ref) {
  final state = ref.watch(sportsFeedNotifierProvider);
  if (state is SportsFeedLoaded) {
    return state.totalLive;
  }
  return 0;
});
