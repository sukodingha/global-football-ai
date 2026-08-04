import '../entities/notification_preferences_entity.dart';
import '../repositories/notification_repository.dart';
import 'usecase.dart';

/// Returns a single snapshot of the user's notification preferences.
class GetNotificationPreferences
    implements
        UseCase<Future<AppNotificationPreferences>, GetNotifPrefsParams> {
  const GetNotificationPreferences(this._repository);
  final NotificationRepository _repository;

  @override
  Future<AppNotificationPreferences> call(GetNotifPrefsParams params) {
    return _repository.getPreferences(params.userId);
  }
}
