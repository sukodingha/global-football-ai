import 'dart:async';

import '../../features/home/domain/entities/match_entity.dart';
import '../../features/notifications/domain/entities/notification_alert_entity.dart';

/// Detects football match events (Goal, Kickoff, Half Time, Full Time,
/// Result lock) by comparing successive live-match snapshots.
///
/// The engine consumes a broadcast stream of `List<MatchEntity>` snapshots
/// (typically from [LiveUpdateStream]) and emits a [NotificationAlertEntity]
/// each time a new event is detected. Events are deduplicated per
/// match + event type so a goal alert is only fired once.
class NotificationAlertEngine {
  /// Maps `matchId:eventType` to a sentinel so alerts are never duplicated.
  final Set<String> _emitted = {};

  /// The last snapshot received, used to diff across polls.
  Map<int, MatchEntity> _lastByMatch = {};

  /// Stream controller for detected alerts.
  final StreamController<NotificationAlertEntity> _controller =
      StreamController<NotificationAlertEntity>.broadcast();

  StreamSubscription<List<MatchEntity>>? _sourceSub;

  /// Subscribes to a live-match snapshot stream and emits alerts.
  void startListening(Stream<List<MatchEntity>> source) {
    stopListening();
    _sourceSub = source.listen(
      _process,
      onError: (_) {
        // Live stream errors are swallowed; the stream continues.
      },
    );
  }

  /// Processes a new snapshot, diffing against the previous one.
  void _process(List<MatchEntity> matches) {
    final byId = {for (final m in matches) m.id: m};

    // Detect state transitions for known matches and brand new matches.
    for (final match in matches) {
      final previous = _lastByMatch[match.id];
      _detectEvents(match, previous);
    }

    _lastByMatch = byId;
  }

  void _detectEvents(MatchEntity current, MatchEntity? previous) {
    if (previous == null) {
      return;
    }

    final label = '${current.homeTeam.name} vs ${current.awayTeam.name}';

    // Kickoff: scheduled -> inPlay/timed.
    if (!previous.status.isLive && current.status.isLive) {
      _emit(
        NotificationAlertType.kickoff,
        current.id,
        'Kickoff: $label',
        'The match has kicked off.',
        current,
      );
    }

    // Goal: score increased for either side.
    if ((current.homeScore ?? 0) > (previous.homeScore ?? 0)) {
      _emit(
        NotificationAlertType.goal,
        current.id,
        'GOAL! ${current.homeTeam.name} scores',
        '$label — ${_scoreline(current)}',
        current,
      );
    }
    if ((current.awayScore ?? 0) > (previous.awayScore ?? 0)) {
      _emit(
        NotificationAlertType.goal,
        current.id,
        'GOAL! ${current.awayTeam.name} scores',
        '$label — ${_scoreline(current)}',
        current,
      );
    }

    // Half Time: paused after being inPlay (minute >= 40 is a safe proxy).
    if (previous.status == MatchStatus.inPlay &&
        current.status == MatchStatus.paused) {
      _emit(
        NotificationAlertType.halfTime,
        current.id,
        'Half Time: $label',
        'The score is ${_scoreline(current)}.',
        current,
      );
    }

    // Full Time / Result lock.
    if (!current.status.isFinished && previous.status.isFinished == false) {
      // No-op guard to keep the handler shape explicit.
    }
    if (!previous.status.isFinished && current.status.isFinished) {
      _emit(
        NotificationAlertType.fullTime,
        current.id,
        'Full Time: $label',
        'Final score ${_scoreline(current)}.',
        current,
      );
      _emit(
        NotificationAlertType.result,
        current.id,
        'Result locked: $label',
        _resultText(current),
        current,
      );
    }
  }

  void _emit(
    NotificationAlertType type,
    int matchId,
    String title,
    String body,
    MatchEntity match,
  ) {
    final key = '$matchId:${type.name}';
    if (_emitted.contains(key)) return;
    _emitted.add(key);

    _controller.add(
      NotificationAlertEntity(
        id: key,
        type: type,
        title: title,
        body: body,
        matchId: matchId,
        createdAt: DateTime.now(),
      ),
    );
  }

  String _scoreline(MatchEntity match) =>
      '${match.homeTeam.name} ${match.homeScore ?? 0} - '
      '${match.awayScore ?? 0} ${match.awayTeam.name}';

  String _resultText(MatchEntity match) {
    final home = match.homeScore ?? 0;
    final away = match.awayScore ?? 0;
    if (home > away) return '${match.homeTeam.name} win.';
    if (away > home) return '${match.awayTeam.name} win.';
    return 'It finishes all square.';
  }

  /// The stream of detected alerts.
  Stream<NotificationAlertEntity> get alerts => _controller.stream;

  /// Whether the engine is actively consuming a source stream.
  bool get isActive => _sourceSub != null;

  /// Stops consuming the source stream.
  void stopListening() {
    _sourceSub?.cancel();
    _sourceSub = null;
  }

  /// Resets the deduplication cache (e.g. on a new day).
  void reset() {
    _emitted.clear();
  }

  /// Disposes the controller and stops listening.
  Future<void> dispose() async {
    stopListening();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
