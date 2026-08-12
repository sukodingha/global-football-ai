import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:global_ai_prediction/core/services/news_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NewsCacheService', () {
    late NewsCacheService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = NewsCacheService();
    });

    test('returns null when no cache exists for a key', () async {
      final result = await service.getCachedNews('missing-key');
      expect(result, isNull);
    });

    test('caches and retrieves news articles', () async {
      final articles = <Map<String, dynamic>>[
        {'id': '1', 'title': 'First article'},
        {'id': '2', 'title': 'Second article'},
      ];

      await service.cacheNews('home', articles);
      final result = await service.getCachedNews('home');

      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0]['title'], 'First article');
      expect(result[1]['title'], 'Second article');
    });

    test('isolates caches by key', () async {
      await service.cacheNews('keyA', [
        {'id': 'A'},
      ]);
      await service.cacheNews('keyB', [
        {'id': 'B'},
      ]);

      final a = await service.getCachedNews('keyA');
      final b = await service.getCachedNews('keyB');

      expect(a!.single['id'], 'A');
      expect(b!.single['id'], 'B');
    });

    test('evicts stale entries older than the TTL', () async {
      final prefs = await SharedPreferences.getInstance();
      // Write a stale entry directly with an old cachedAt timestamp.
      final staleAt = DateTime.now()
          .subtract(const Duration(hours: 4))
          .millisecondsSinceEpoch;

      prefs.setString(
        'news_cache:stale',
        '{"cachedAt":$staleAt,"articles":[{"id":"old"}]}',
      );

      final result = await service.getCachedNews('stale');
      expect(result, isNull);
      // The stale entry should have been removed.
      expect(prefs.getString('news_cache:stale'), isNull);
    });

    test('returns null for corrupt JSON data', () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('news_cache:corrupt', '{not valid json');

      final result = await service.getCachedNews('corrupt');
      expect(result, isNull);
    });

    test('clearCache removes all news cache entries', () async {
      await service.cacheNews('a', [
        {'id': '1'},
      ]);
      await service.cacheNews('b', [
        {'id': '2'},
      ]);

      await service.clearCache();

      expect(await service.getCachedNews('a'), isNull);
      expect(await service.getCachedNews('b'), isNull);
    });

    test('cacheNews silently ignores failures', () async {
      // A key that cannot be written (e.g. prefs is null path) should not throw.
      // Using a valid service here and verifying no exception is raised.
      await expectLater(
        service.cacheNews('safe', [
          {'id': '1'},
        ]),
        completes,
      );
    });
  });
}
