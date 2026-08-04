import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notification_preferences.dart';
import '../../domain/usecases/save_notification_preferences.dart';
import '../../domain/usecases/watch_notification_preferences.dart';
import 'datasources/notification_remote_data_source.dart';
import 'repositories/notification_repository_impl.dart';

/// Firestore-backed notification preferences remote data source.
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
  (ref) => NotificationRemoteDataSource(),
);

/// Notification preferences repository.
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    dataSource: ref.watch(notificationRemoteDataSourceProvider),
  ),
);

/// Use cases.
final watchNotificationPreferencesUseCaseProvider =
    Provider<WatchNotificationPreferences>(
  (ref) => WatchNotificationPreferences(
    ref.watch(notificationRepositoryProvider),
  ),
);

final getNotificationPreferencesUseCaseProvider =
    Provider<GetNotificationPreferences>(
  (ref) => GetNotificationPreferences(
    ref.watch(notificationRepositoryProvider),
  ),
);

final saveNotificationPreferencesUseCaseProvider =
    Provider<SaveNotificationPreferences>(
  (ref) => SaveNotificationPreferences(
    ref.watch(notificationRepositoryProvider),
  ),
);
