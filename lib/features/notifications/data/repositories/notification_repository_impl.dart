import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

/// Implementation of [NotificationRepository] backed by Firestore.
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required NotificationRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final NotificationRemoteDataSource _dataSource;

  Future<T> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  Failure _mapException(Exception e) {
    final message = e.toString();
    if (e is NetworkException || message.contains('network')) {
      return Failure.networkFailure(message: message);
    }
    if (e is CacheException || message.contains('cache')) {
      return Failure.cacheFailure(message: message);
    }
    return Failure.unknown(message: message);
  }

  @override
  Stream<AppNotificationPreferences> watchPreferences(String userId) {
    return _dataSource.watchPreferences(userId);
  }

  @override
  Future<AppNotificationPreferences> getPreferences(String userId) {
    return _safeCall(() => _dataSource.getPreferences(userId));
  }

  @override
  Future<void> savePreferences({
    required String userId,
    required AppNotificationPreferences preferences,
  }) {
    return _safeCall(() => _dataSource.savePreferences(
          userId: userId,
          preferences: preferences,
        ));
  }
}
