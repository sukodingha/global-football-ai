import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/secure_storage_service.dart';
import '../../auth/data/dependency_injection.dart';
import '../domain/repositories/settings_repository.dart';
import 'datasources/settings_local_data_source.dart';
import 'datasources/settings_remote_data_source.dart';
import '../domain/usecases/get_settings.dart';
import '../domain/usecases/save_settings.dart';
import '../domain/usecases/watch_settings.dart';
import 'repositories/settings_repository_impl.dart';

/// Firestore-backed settings remote data source.
final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>(
  (ref) => SettingsRemoteDataSource(),
);

/// Secure-storage-backed settings local data source.
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSource(
    secureStorage: ref.watch(secureStorageServiceProvider),
  ),
);

/// Settings repository.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(
    remoteDataSource: ref.watch(settingsRemoteDataSourceProvider),
    localDataSource: ref.watch(settingsLocalDataSourceProvider),
  ),
);

/// Use cases.
final watchSettingsUseCaseProvider = Provider<WatchSettings>(
  (ref) => WatchSettings(ref.watch(settingsRepositoryProvider)),
);

final getSettingsUseCaseProvider = Provider<GetSettings>(
  (ref) => GetSettings(ref.watch(settingsRepositoryProvider)),
);

final saveSettingsUseCaseProvider = Provider<SaveSettings>(
  (ref) => SaveSettings(ref.watch(settingsRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfile>(
  (ref) => UpdateProfile(ref.watch(settingsRepositoryProvider)),
);

final updateFavoriteTeamsUseCaseProvider = Provider<UpdateFavoriteTeams>(
  (ref) => UpdateFavoriteTeams(ref.watch(settingsRepositoryProvider)),
);

final updateNotificationPreferencesUseCaseProvider =
    Provider<UpdateNotificationPreferences>(
  (ref) => UpdateNotificationPreferences(ref.watch(settingsRepositoryProvider)),
);

final updateThemeModeUseCaseProvider = Provider<UpdateThemeMode>(
  (ref) => UpdateThemeMode(ref.watch(settingsRepositoryProvider)),
);
