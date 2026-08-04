import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../datasources/settings_remote_data_source.dart';

/// Implementation of [SettingsRepository].
///
/// Combines Firestore real-time sync with a secure local cache for offline
/// persistence and instant first render.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required SettingsRemoteDataSource remoteDataSource,
    required SettingsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final SettingsRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;

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
  Stream<UserSettingsEntity> watchSettings(String userId) {
    return _remoteDataSource.watchSettings(userId);
  }

  @override
  Future<UserSettingsEntity> getSettings(String userId) {
    return _safeCall(() async {
      try {
        final remote = await _remoteDataSource.getSettings(userId);
        await _localDataSource.cacheSettings(remote);
        return remote;
      } catch (_) {
        // Fall back to local cache when offline.
        final cached = await _localDataSource.getCachedSettings(userId);
        if (cached != null) return cached;
        rethrow;
      }
    });
  }

  @override
  Future<void> saveSettings(UserSettingsEntity settings) {
    return _safeCall(() async {
      await _remoteDataSource.saveSettings(settings);
      await _localDataSource.cacheSettings(settings);
    });
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) {
    return _safeCall(() async {
      await _remoteDataSource.updateProfile(
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      // Refresh and cache after an update.
      final settings = await _remoteDataSource.getSettings(userId);
      await _localDataSource.cacheSettings(settings);
    });
  }

  @override
  Future<void> updateFavoriteTeams({
    required String userId,
    required List<String> favoriteTeams,
  }) {
    return _safeCall(() async {
      await _remoteDataSource.updateFavoriteTeams(
        userId: userId,
        favoriteTeams: favoriteTeams,
      );
      final settings = await _remoteDataSource.getSettings(userId);
      await _localDataSource.cacheSettings(settings);
    });
  }

  @override
  Future<void> updateNotificationPreferences({
    required String userId,
    required NotificationPreferences preferences,
  }) {
    return _safeCall(() async {
      await _remoteDataSource.updateNotificationPreferences(
        userId: userId,
        preferences: preferences,
      );
      final settings = await _remoteDataSource.getSettings(userId);
      await _localDataSource.cacheSettings(settings);
    });
  }

  @override
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  }) {
    return _safeCall(() async {
      await _remoteDataSource.updateThemeMode(
        userId: userId,
        themeMode: themeMode,
      );
      final settings = await _remoteDataSource.getSettings(userId);
      await _localDataSource.cacheSettings(settings);
    });
  }
}
