import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/notification_alert_entity.dart';
import '../domain/entities/notification_preferences_entity.dart';
import '../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

/// Riverpod controller for notification preferences & alerts.
///
/// Watches the user's notification preferences in real time (Firestore) and
/// collects inbound [NotificationAlertEntity] events from the live alert
/// engine so the UI can show recent alerts.
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationInitial());

  final NotificationRepository _repository;

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
    state = loaded.copyWith(
      alerts: [alert, ...loaded.alerts].take(50).toList(),
      unreadCount: loaded.unreadCount + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Marks all alerts as read.
  void markAllRead() {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;
    state = loaded.copyWith(unreadCount: 0);
  }

  /// Persists the notification preferences.
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
