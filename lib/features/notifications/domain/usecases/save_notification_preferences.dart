import '../repositories/notification_repository.dart';
import 'usecase.dart';

/// Persists the user's notification preferences to Firestore.
class SaveNotificationPreferences
    implements UseCase<Future<void>, SaveNotifPrefsParams> {
  const SaveNotificationPreferences(this._repository);
  final NotificationRepository _repository;

  @override
  Future<void> call(SaveNotifPrefsParams params) {
    return _repository.savePreferences(
      userId: params.userId,
      preferences: params.preferences,
    );
  }
}
