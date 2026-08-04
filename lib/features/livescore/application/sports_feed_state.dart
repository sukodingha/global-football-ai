import '../domain/entities/sport_event_entity.dart';

/// Immutable state for the multi-sport real-time feed.
sealed class SportsFeedState {
  const SportsFeedState();
}

/// Initial state.
class SportsFeedInitial extends SportsFeedState {
  const SportsFeedInitial();
}

/// Loading state for a specific sport.
class SportsFeedLoading extends SportsFeedState {
  const SportsFeedLoading({this.sport});
  final SportType? sport;
}

/// Loaded state with live events per sport.
class SportsFeedLoaded extends SportsFeedState {
  const SportsFeedLoaded({
    required this.events,
    this.selectedSport = SportType.football,
    this.lastUpdated,
    this.stale = false,
  });

  final Map<SportType, List<SportEventEntity>> events;
  final SportType selectedSport;
  final DateTime? lastUpdated;
  final bool stale;

  List<SportEventEntity> get selectedEvents =>
      events[selectedSport] ?? const [];

  int get totalLive =>
      events.values.fold(0, (sum, list) => sum + list.where((e) => e.isLive).length);

  SportsFeedLoaded copyWith({
    Map<SportType, List<SportEventEntity>>? events,
    SportType? selectedSport,
    DateTime? lastUpdated,
    bool? stale,
  }) {
    return SportsFeedLoaded(
      events: events ?? this.events,
      selectedSport: selectedSport ?? this.selectedSport,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      stale: stale ?? this.stale,
    );
  }
}

/// Error state with a user-safe message.
class SportsFeedError extends SportsFeedState {
  const SportsFeedError({
    required this.message,
    this.sport,
  });
  final String message;
  final SportType? sport;
}

