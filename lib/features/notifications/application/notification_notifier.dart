import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/notification_service.dart';
import '../domain/entities/notification_alert_entity.dart';
import '../domain/entities/notification_preferences_entity.dart';
import '../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

/// Riverpod controller for notification preferences & alerts.
///
/// Watches the user's notification preferences in real time (Firestore),
/// collects inbound [NotificationAlertEntity] events from the live alert
/// engine so the UI can show recent alerts, and displays production-ready
/// local push notifications (respecting the user's preferences) when events
/// are detected.
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier({
    required NotificationRepository repository,
    NotificationService? notificationService,
  })  : _repository = repository,
        _notificationService = notificationService,
        super(const NotificationInitial());

  final NotificationRepository _repository;
  final NotificationService? _notificationService;

  StreamSubscription<AppNotificationPreferences>? _prefsSub;
  StreamSubscription<NotificationAlertEntity>? _alertSub;

  /// Starts listening to the user's notification preferences and optional
  /// live alert stream.
  Future<void> start({
    required String userId,
    Stream<NotificationAlertEntity>? alertStream,
  }) async {
    state = const NotificationLoading();

    _prefsSub?.cancel();
    _prefsSub = _repository.watchPreferences(userId).listen(
          (prefs) => _updatePrefs(prefs),
          onError: (Object error) {
            if (error is Failure) {
              state = NotificationError(message: error.message);
            } else {
              state = const NotificationError(
                message: 'Unable to load notification preferences.',
              );
            }
          },
        );

    // One-shot initial load.
    try {
      final prefs = await _repository.getPreferences(userId);
      _updatePrefs(prefs);
    } on Failure catch (f) {
      state = NotificationError(message: f.message);
    } catch (_) {
      state = const NotificationError(
        message: 'Unable to load notification preferences.',
      );
    }

    // Attach to the alert stream if provided.
    if (alertStream != null) {
      _alertSub?.cancel();
      _alertSub = alertStream.listen(_onAlert);
    }
  }

  void _updatePrefs(AppNotificationPreferences prefs) {
    final current = state;
    if (current is NotificationLoaded) {
      state = current.copyWith(
        preferences: prefs,
        lastUpdated: DateTime.now(),
      );
    } else {
      state = NotificationLoaded(preferences: prefs);
    }
  }

  void _onAlert(NotificationAlertEntity alert) {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;

    // Only surface alerts the user has opted into.
    if (!_isEnabled(alert.type, loaded.preferences)) return;

    state = loaded.copyWith(
      alerts: [alert, ...loaded.alerts].take(50).toList(),
      unreadCount: loaded.unreadCount + 1,
      lastUpdated: DateTime.now(),
    );

    // Display a real local notification (works in foreground and, via FCM
    // topics, in background). The event id is hashed to a stable positive
    // int so the same event never duplicates a notification.
    final service = _notificationService;
    if (service != null) {
      service.showLocalNotification(
        id: _stableId(alert),
        title: alert.title,
        body: alert.body,
        payload:
            'type=${alert.type.name}&matchId=${alert.matchId ?? -1}',
      );
    }
  }

/// Maps an alert type to the matching user-preference toggle.
  bool _isEnabled(
    NotificationAlertType type,
    AppNotificationPreferences prefs,
  ) {
    switch (type) {
      case NotificationAlertType.goal:
        return prefs.goalAlerts;
      case NotificationAlertType.kickoff:
        return prefs.kickoffAlerts;
      case NotificationAlertType.halfTime:
        return prefs.halfTimeAlerts;
      case NotificationAlertType.fullTime:
        return prefs.fullTimeAlerts;
      case NotificationAlertType.result:
      case NotificationAlertType.prediction:
        return prefs.predictionAlerts;
      case NotificationAlertType.breakingNews:
        return prefs.breakingNews;
      case NotificationAlertType.transferNews:
        return prefs.transferNews;
    }
  }

  /// Produces a stable, deterministic positive notification id from an alert.
  int _stableId(NotificationAlertEntity alert) {
    return alert.id.hashCode.abs() % (1 << 31);
  }

  /// Marks all alerts as read.
  void markAllRead() {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;
    state = loaded.copyWith(unreadCount: 0);
  }

/// Persists the notification preferences and keeps the device's FCM topic
  /// subscriptions in sync so background pushes respect the user's choices.
  Future<void> savePreferences({
    required String userId,
    required AppNotificationPreferences preferences,
  }) async {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;
    state = loaded.copyWith(saving: true);

    try {
      await _repository.savePreferences(
        userId: userId,
        preferences: preferences,
      );

// Sync FCM topic subscriptions for this device (background delivery).
      final service = _notificationService;
      if (service != null) {
        final previousTopics = loaded.preferences.enabledTopics.toSet();
        final newTopics = preferences.enabledTopics.toSet();
        await service.unsubscribeFromTopics(
          previousTopics.difference(newTopics).toList(),
        );
        await service.subscribeToTopics(
          newTopics.difference(previousTopics).toList(),
        );
      }

      // The Firestore stream updates preferences in real time.
      state = (state as NotificationLoaded).copyWith(saving: false);
    } on Failure catch (f) {
      state = (state as NotificationLoaded).copyWith(saving: false);
      throw f;
    } catch (_) {
      state = (state as NotificationLoaded).copyWith(saving: false);
      throw const UnknownFailure();
    }
  }

  /// Clears the in-memory alerts list.
  void clearAlerts() {
    if (state is! NotificationLoaded) return;
    state = (state as NotificationLoaded).copyWith(alerts: const []);
  }

  @override
  void dispose() {
    _prefsSub?.cancel();
    _alertSub?.cancel();
    super.dispose();
  }
}
