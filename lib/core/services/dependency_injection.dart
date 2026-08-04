import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';
import 'live_scores_cache_service.dart';
import 'news_cache_service.dart';
import 'notification_service.dart';

/// Push notification service (Firebase Cloud Messaging).
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
});

/// Analytics & performance tracking service.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// News cache service (SharedPreferences-backed).
final newsCacheServiceProvider = Provider<NewsCacheService>((ref) {
  return NewsCacheService();
});

/// Live scores cache service (SharedPreferences-backed).
final liveScoresCacheServiceProvider = Provider<LiveScoresCacheService>((ref) {
  return LiveScoresCacheService();
});
