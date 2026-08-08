import 'dart:async';

import '../../../home/domain/entities/match_entity.dart';
import '../../domain/repositories/livescore_repository.dart';

/// Real-time live score update handler.
///
/// Produces a broadcast [Stream] of live match snapshots. The stream polls
/// the [LivescoreRepository] at a configurable interval, emitting a new
/// snapshot only when the live match data has changed (e.g. a goal was scored
/// or the match minute advanced). This models a real-time channel without
/// requiring a dedicated WebSocket endpoint.
class LiveUpdateStream {
  LiveUpdateStream({
    required LivescoreRepository repository,
    this.pollInterval = const Duration(seconds: 30),
  }) : _repository = repository;

  final LivescoreRepository _repository;
  final Duration pollInterval;

  final StreamController<List<MatchEntity>> _controller =
      StreamController<List<MatchEntity>>.broadcast();

Timer? _pollTimer;
  List<MatchEntity>? _lastSnapshot;
  DateTime? _lastEmit;

  /// Whether the stream is currently active.
  bool get isActive => _pollTimer != null;

  /// Subscribes to real-time live score updates.
  ///
  /// Emits an initial snapshot immediately, then refreshes on [pollInterval].
  Stream<List<MatchEntity>> get stream {
    _ensureStarted();
    return _controller.stream;
  }

  void _ensureStarted() {
    if (_pollTimer != null) return;

    _pollTimer = Timer.periodic(pollInterval, (_) {
      _poll();
    });

    // Emit an initial snapshot right away.
    _poll();
  }

  Future<void> _poll() async {
    try {
      final matches = await _repository.getLiveMatches();
      if (_hasChanged(matches)) {
        _lastSnapshot = matches;
        _lastEmit = DateTime.now();
        if (!_controller.isClosed) {
          _controller.add(matches);
        }
      }
    } catch (_) {
      // Network errors are swallowed for a live stream so the polling
      // continues silently; the UI can surface staleness via timestamps.
    }
  }

  /// Compares snapshots to avoid redundant emissions.
  bool _hasChanged(List<MatchEntity> incoming) {
    final last = _lastSnapshot;
    if (last == null) return true;
    if (last.length != incoming.length) return true;

    for (var i = 0; i < incoming.length; i++) {
      final a = last[i];
      final b = incoming[i];
      if (a.homeScore != b.homeScore ||
          a.awayScore != b.awayScore ||
          a.minute != b.minute ||
          a.status != b.status) {
        return true;
      }
    }
    return false;
  }

  /// Last emitted snapshot (for staleness display).
  List<MatchEntity>? get lastSnapshot => _lastSnapshot;

  /// Timestamp of the last successful emit.
  DateTime? get lastEmit => _lastEmit;

/// Stops the polling timer and closes the stream.
  Future<void> dispose() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _lastSnapshot = null;
    _lastEmit = null;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}

