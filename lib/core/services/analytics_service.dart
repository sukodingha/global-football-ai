import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

/// Analytics & performance tracking service.
///
/// Wraps Firebase Analytics for event logging and Firebase Performance for
/// tracing performance-critical operations (e.g. API fetches). All calls are
/// best-effort and never throw in production paths.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics, FirebasePerformance? perf})
      : _analytics = analytics ?? FirebaseAnalytics.instance,
        _perf = perf ?? FirebasePerformance.instance;

  final FirebaseAnalytics _analytics;
  final FirebasePerformance _perf;

  /// Logs a screen view event.
  Future<void> logScreen(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (_) {
      // Best-effort.
    }
  }

  /// Logs a custom event with optional parameters.
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Best-effort.
    }
  }

  /// Starts a performance trace for a given operation name.
  ///
  /// Returns a [Trace] that the caller should `.stop()` when done,
  /// or null if tracing is unavailable.
  Trace? startTrace(String name) {
    try {
      return _perf.newTrace(name);
    } catch (_) {
      return null;
    }
  }

  /// Convenience helper to trace an async operation and report its latency.
  Future<T> trace<T>(String name, Future<T> Function() action) async {
    final trace = startTrace(name);
    try {
      final result = await action();
      trace?.stop();
      return result;
    } catch (e) {
      trace?.stop();
      rethrow;
    }
  }
}
