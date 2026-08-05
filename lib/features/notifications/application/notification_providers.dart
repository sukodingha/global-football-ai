import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/dependency_injection.dart';
import '../../../core/services/notification_alert_engine.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/application/auth_providers.dart';
import '../../livescore/data/dependency_injection.dart';
import '../data/dependency_injection.dart';
import '../domain/entities/notification_alert_entity.dart';
import '../domain/entities/notification_preferences_entity.dart';
import 'notification_notifier.dart';
import 'notification_state.dart';

/// Provider for the [NotificationNotifier] controller.
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(
    repository: repository,
    notificationService: notificationService,
  );
});

/// Live alert engine (detects match events from live snapshots).
final notificationAlertEngineProvider =
    Provider<NotificationAlertEngine>((ref) {
  final engine = NotificationAlertEngine();
  ref.onDispose(engine.dispose);

  // Wire the engine to the real-time live match stream so Goal/Kickoff/
  // HalfTime/FullTime/Result alerts are detected automatically.
  final livescoreRepository = ref.watch(livescoreRepositoryProvider);
  engine.startListening(livescoreRepository.watchLiveScores());

  return engine;
});

/// Selector for the current notification preferences.
final notificationPreferencesProvider =
    Provider<AppNotificationPreferences>((ref) {
  final state = ref.watch(notificationNotifierProvider);
  if (state is NotificationLoaded) {
    return state.preferences;
  }
  return const AppNotificationPreferences();
});

/// Selector for the recent alerts.
final recentNotificationsProvider =
    Provider<List<NotificationAlertEntity>>((ref) {
  final state = ref.watch(notificationNotifierProvider);
  if (state is NotificationLoaded) {
    return state.alerts;
  }
  return const [];
});

/// Selector for the unread alert count.
final unreadNotificationsProvider = Provider<int>((ref) {
  final state = ref.watch(notificationNotifierProvider);
  if (state is NotificationLoaded) {
    return state.unreadCount;
  }
  return 0;
});

/// Controller that starts the notification notifier when first read.
final notificationControllerProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  final engine = ref.watch(notificationAlertEngineProvider);
  if (user != null) {
    ref.read(notificationNotifierProvider.notifier).start(
          userId: user.id,
          alertStream: engine.alerts,
        );
  }
  return null;
});
