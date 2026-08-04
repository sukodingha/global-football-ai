import '../entities/notification_preferences_entity.dart';

/// Base contract for notification use cases.
abstract class UseCase<Type, Params> {
  Type call(Params params);
}

/// Params for watching a user's notification preferences.
class WatchNotifPrefsParams {
  const WatchNotifPrefsParams(this.userId);
  final String userId;
}

/// Params for fetching a user's notification preferences.
class GetNotifPrefsParams {
  const GetNotifPrefsParams(this.userId);
  final String userId;
}

/// Params for saving a user's notification preferences.
class SaveNotifPrefsParams {
  const SaveNotifPrefsParams({
    required this.userId,
    required this.preferences,
  });
  final String userId;
  final AppNotificationPreferences preferences;
}
