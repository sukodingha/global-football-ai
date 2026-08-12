import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:global_ai_prediction/core/services/analytics_service.dart';

/// A fake [FirebaseAnalytics] that records calls for assertions.
class FakeAnalytics extends Fake implements FirebaseAnalytics {
  final List<String> screenViews = [];
  final List<Map<String, Object?>> events = [];

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    if (screenName != null) screenViews.add(screenName);
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add({'name': name, 'parameters': parameters});
  }
}

/// A fake [FirebasePerformance] that produces fake traces.
class FakePerformance extends Fake implements FirebasePerformance {
  final List<String> traceNames = [];

  @override
  Trace newTrace(String name) {
    traceNames.add(name);
    return FakeTrace();
  }
}

/// A fake [Trace] that records start/stop.
class FakeTrace implements Trace {
  bool started = false;
  bool stopped = false;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  void incrementMetric(String name, int value) {}

  @override
  void setMetric(String name, int value) {}

  @override
  int getMetric(String name) => 0;

  @override
  void putAttribute(String name, String value) {}

  @override
  void removeAttribute(String name) {}

  @override
  String? getAttribute(String name) => null;

  @override
  Map<String, String> getAttributes() => {};
}

void main() {
  group('AnalyticsService', () {
    late FakeAnalytics fakeAnalytics;
    late FakePerformance fakePerf;
    late AnalyticsService service;

    setUp(() {
      fakeAnalytics = FakeAnalytics();
      fakePerf = FakePerformance();
      service = AnalyticsService(analytics: fakeAnalytics, perf: fakePerf);
    });

    test('logScreen forwards to Firebase Analytics', () async {
      await service.logScreen('Home');
      expect(fakeAnalytics.screenViews, contains('Home'));
    });

    test('logEvent forwards name and parameters', () async {
      await service.logEvent('match_viewed', parameters: {
        'matchId': '123',
      });
      expect(fakeAnalytics.events, hasLength(1));
      expect(fakeAnalytics.events.single['name'], 'match_viewed');
    });

    test('startTrace creates a trace via FirebasePerformance', () {
      final trace = service.startTrace('load_dashboard');
      expect(fakePerf.traceNames, contains('load_dashboard'));
      expect(trace, isNotNull);
      expect(trace, isA<FakeTrace>());
    });

    test('trace helper returns the action result', () async {
      final result = await service.trace<int>('op', () async => 42);
      expect(result, 42);
      expect(fakePerf.traceNames, contains('op'));
    });

    test('trace helper rethrows on failure', () async {
      await expectLater(
        service.trace<int>('failing', () async => throw StateError('boom')),
        throwsStateError,
      );
    });

    test('does not throw when analytics logging fails', () async {
      final throwing = AnalyticsService(
        analytics: _ThrowingAnalytics(),
        perf: fakePerf,
      );
      await expectLater(throwing.logScreen('X'), completes);
      await expectLater(throwing.logEvent('Y'), completes);
    });

    test('startTrace returns null when performance throws', () {
      final svc = AnalyticsService(
        analytics: fakeAnalytics,
        perf: _ThrowingPerformance(),
      );
      expect(svc.startTrace('x'), isNull);
    });
  });
}

class _ThrowingAnalytics extends Fake implements FirebaseAnalytics {
  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    throw StateError('analytics down');
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    throw StateError('analytics down');
  }
}

class _ThrowingPerformance extends Fake implements FirebasePerformance {
  @override
  Trace newTrace(String name) {
    throw StateError('perf down');
  }
}
