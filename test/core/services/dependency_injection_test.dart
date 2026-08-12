import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:global_ai_prediction/core/services/dependency_injection.dart';
import 'package:global_ai_prediction/core/services/live_scores_cache_service.dart';
import 'package:global_ai_prediction/core/services/news_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dependency Injection providers', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('newsCacheServiceProvider provides a NewsCacheService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(newsCacheServiceProvider);
      expect(service, isA<NewsCacheService>());
    });

    test('liveScoresCacheServiceProvider provides a LiveScoresCacheService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(liveScoresCacheServiceProvider);
      expect(service, isA<LiveScoresCacheService>());
    });

    test('newsCacheServiceProvider is a singleton for the same container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(newsCacheServiceProvider);
      final b = container.read(newsCacheServiceProvider);
      expect(a, same(b));
    });

    test('liveScoresCacheServiceProvider is a singleton', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(liveScoresCacheServiceProvider);
      final b = container.read(liveScoresCacheServiceProvider);
      expect(a, same(b));
    });

    test('newsCacheServiceProvider can be overridden with a custom value', () {
      final overridden = NewsCacheService();
      final container = ProviderContainer(
        overrides: [
          newsCacheServiceProvider.overrideWithValue(overridden),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(newsCacheServiceProvider);
      expect(service, same(overridden));
    });

    test('liveScoresCacheServiceProvider can be overridden', () {
      final overridden = LiveScoresCacheService();
      final container = ProviderContainer(
        overrides: [
          liveScoresCacheServiceProvider.overrideWithValue(overridden),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(liveScoresCacheServiceProvider);
      expect(service, same(overridden));
    });
  });
}
