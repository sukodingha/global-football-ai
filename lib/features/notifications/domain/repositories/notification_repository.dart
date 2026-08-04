import '../../../../core/errors/failures.dart';
import '../entities/notification_preferences_entity.dart';

/// Contract for the notification preferences repository.
///
/// Backed by Firestore for real-time preferences sync of match/event alerts,
/// news feeds, and personalized team/competition subscriptions.
abstract class NotificationRepository {
  /// Watches the user's notification preferences in real time.
  Stream<AppNotificationPreferences> watchPreferences(String userId);

  /// Returns a single snapshot of the user's notification preferences.
  Future<AppNotificationPreferences> getPreferences(String userId);

  /// Persists the user's notification preferences to Firestore.
  Future<void> savePreferences({
    required String userId,
    required AppNotificationPreferences preferences,
  });
}
