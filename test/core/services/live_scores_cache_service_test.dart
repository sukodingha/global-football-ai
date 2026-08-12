import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:global_ai_prediction/core/services/live_scores_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveScoresCacheService', () {
    late LiveScoresCacheService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = LiveScoresCacheService();
    });

    test('returns null when no cache exists for a key', () async {
      final result = await service.getCachedMatches('missing');
      expect(result, isNull);
    });

    test('caches and retrieves matches', () async {
      final matches = <Map<String, dynamic>>[
        {'id': 'm1', 'home': 'Team A', 'away': 'Team B'},
        {'id': 'm2', 'home': 'Team C', 'away': 'Team D'},
      ];

      await service.cacheMatches('scores', matches);
      final result = await service.getCachedMatches('scores');

      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0]['home'], 'Team A');
    });

    test('convenience cacheLiveMatches/getCachedLiveMatches round-trips', () async {
      final matches = <Map<String, dynamic>>[
        {'id': 'live1', 'home': 'United', 'away': 'City'},
      ];

      await service.cacheLiveMatches(matches);
      final result = await service.getCachedLiveMatches();

      expect(result!.single['id'], 'live1');
    });

    test('evicts stale entries older than the TTL', () async {
      final prefs = await SharedPreferences.getInstance();
      final staleAt = DateTime.now()
          .subtract(const Duration(minutes: 10))
          .millisecondsSinceEpoch;

      prefs.setString(
        'live_scores_cache:stale',
        '{"cachedAt":$staleAt,"matches":[{"id":"old"}]}',
      );

      final result = await service.getCachedMatches('stale');
      expect(result, isNull);
      expect(prefs.getString('live_scores_cache:stale'), isNull);
    });

    test('returns null for corrupt JSON data', () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('live_scores_cache:corrupt', 'not json');

      final result = await service.getCachedMatches('corrupt');
      expect(result, isNull);
    });

    test('clearCache removes all live scores cache entries', () async {
      await service.cacheMatches('a', [
        {'id': '1'},
      ]);
      await service.cacheMatches('b', [
        {'id': '2'},
      ]);

      await service.clearCache();

      expect(await service.getCachedMatches('a'), isNull);
      expect(await service.getCachedMatches('b'), isNull);
    });
  });
}
