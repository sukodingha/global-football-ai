import '../../../core/errors/failures.dart';
import '../entities/sport_event_entity.dart';

/// Result wrapper for multi-sport repository operations.
class MultiSportResult<T> {
  const MultiSportResult._(this.value, this.failure);
  const MultiSportResult.success(T value) : this._(value, null);
  const MultiSportResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}

/// Contract for the multi-sport real-time feed repository.
///
/// Provides live events for football, tennis, and basketball with automatic
/// status tracking (Live, Halftime, Full Time) and scored updates.
abstract class MultiSportRepository {
  /// Fetches currently live events for a given sport.
  Future<List<SportEventEntity>> getLiveEvents(SportType sport);

  /// Fetches today's events for a given sport (live + scheduled + finished).
  Future<List<SportEventEntity>> getTodayEvents(SportType sport);

  /// Subscribes to auto-updating live events for a sport.
  ///
  /// Emits a snapshot whenever the underlying feed changes (score updates,
  /// status transitions). Falls back to the fetched list if live streaming
  /// isn't available.
  Stream<List<SportEventEntity>> watchLiveEvents(SportType sport);

  /// All live events across supported sports (for the feed home).
  Future<Map<SportType, List<SportEventEntity>>> getLiveEventsAll();
}

