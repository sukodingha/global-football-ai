import 'dart:async';

import '../../domain/entities/sport_event_entity.dart';
import '../../domain/repositories/multi_sport_repository.dart';
import '../datasources/api_sports_data_source.dart';

/// Implementation of [MultiSportRepository].
///
/// Combines the [ApiSportsDataSource] REST feed with an internal polling
/// [MultiSportLiveStream] that emits updates whenever the live data changes,
/// providing real-time score and status tracking (LIVE / Halftime / FT).
class MultiSportRepositoryImpl implements MultiSportRepository {
  MultiSportRepositoryImpl({required ApiSportsDataSource dataSource})
      : _dataSource = dataSource;

  final ApiSportsDataSource _dataSource;

  final Map<SportType, MultiSportLiveStream> _streams = {};

  @override
  Future<List<SportEventEntity>> getLiveEvents(SportType sport) {
    return _dataSource.getLiveEvents(sport);
  }

  @override
  Future<List<SportEventEntity>> getTodayEvents(SportType sport) async {
    try {
      return await _dataSource.getTodayEvents(sport);
    } catch (_) {
      // Fall back to live-only if today's feed is unavailable.
      return _dataSource.getLiveEvents(sport);
    }
  }

  @override
  Future<Map<SportType, List<SportEventEntity>>> getLiveEventsAll() async {
    final results = <SportType, List<SportEventEntity>>{};
    for (final sport in SportType.values) {
      try {
        results[sport] = await getLiveEvents(sport);
      } catch (_) {
        results[sport] = const [];
      }
    }
    return results;
  }

  @override
  Stream<List<SportEventEntity>> watchLiveEvents(SportType sport) {
    return _streams
        .putIfAbsent(sport, () => MultiSportLiveStream(this, sport))
        .stream;
  }
}

/// Polling real-time stream that emits when live events change.
class MultiSportLiveStream {
  MultiSportLiveStream(this._repository, this._sport)
      : _controller = StreamController<List<SportEventEntity>>.broadcast();

  final MultiSportRepositoryImpl _repository;
  final SportType _sport;
  final StreamController<List<SportEventEntity>> _controller;

  Timer? _timer;
  List<SportEventEntity>? _lastSnapshot;

  static const Duration _pollInterval = Duration(seconds: 20);

  Stream<List<SportEventEntity>> get stream {
    _start();
    return _controller.stream;
  }

  void _start() {
    if (_timer != null) return;
    _poll();
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final events = await _repository.getLiveEvents(_sport);
      if (_hasChanged(events)) {
        _lastSnapshot = events;
        if (!_controller.isClosed) {
          _controller.add(events);
        }
      }
    } catch (_) {
      // Swallow transient errors; polling continues.
    }
  }

  bool _hasChanged(List<SportEventEntity> incoming) {
    final last = _lastSnapshot;
    if (last == null) return true;
    if (last.length != incoming.length) return true;
    for (var i = 0; i < incoming.length; i++) {
      final a = last[i];
      final b = incoming[i];
      if (a.status != b.status ||
          a.home.score != b.home.score ||
          a.away.score != b.away.score ||
          a.minute != b.minute ||
          a.currentPeriod != b.currentPeriod ||
          a.home.setsWon != b.home.setsWon ||
          a.away.setsWon != b.away.setsWon) {
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _lastSnapshot = null;
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}

