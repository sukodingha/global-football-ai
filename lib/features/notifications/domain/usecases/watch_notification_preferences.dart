import '../entities/notification_preferences_entity.dart';
import '../repositories/notification_repository.dart';
import 'usecase.dart';

/// Watches the user's notification preferences in real time.
class WatchNotificationPreferences
    implements
        UseCase<Stream<AppNotificationPreferences>, WatchNotifPrefsParams> {
  const WatchNotificationPreferences(this._repository);
  final NotificationRepository _repository;

  @override
  Stream<AppNotificationPreferences> call(WatchNotifPrefsParams params) {
    return _repository.watchPreferences(params.userId);
  }
}
