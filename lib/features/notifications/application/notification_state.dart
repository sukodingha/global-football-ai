import '../domain/entities/notification_alert_entity.dart';
import '../domain/entities/notification_preferences_entity.dart';

/// Immutable state for the notifications feature.
sealed class NotificationState {
  const NotificationState();
}

/// Initial state.
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Initializing state.
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Loaded state with live preferences and recent alerts.
class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.preferences,
    this.alerts = const [],
    this.unreadCount = 0,
    this.saving = false,
    this.lastUpdated,
  });

  final AppNotificationPreferences preferences;

  /// Most recent alerts (match events, news, predictions).
  final List<NotificationAlertEntity> alerts;

  final int unreadCount;
  final bool saving;
  final DateTime? lastUpdated;

  NotificationLoaded copyWith({
    AppNotificationPreferences? preferences,
    List<NotificationAlertEntity>? alerts,
    int? unreadCount,
    bool? saving,
    DateTime? lastUpdated,
  }) {
    return NotificationLoaded(
      preferences: preferences ?? this.preferences,
      alerts: alerts ?? this.alerts,
      unreadCount: unreadCount ?? this.unreadCount,
      saving: saving ?? this.saving,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Error state with a user-safe message.
class NotificationError extends NotificationState {
  const NotificationError({required this.message});
  final String message;
}
