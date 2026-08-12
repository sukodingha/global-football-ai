import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../models/user_settings_model.dart';

/// Secure local cache for user settings.
///
/// Persists the user's settings locally (encrypted) so the settings remain
/// available offline and render instantly on next launch.
class SettingsLocalDataSource {
  SettingsLocalDataSource({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  static String _key(String userId) => 'settings_$userId';

  /// Caches the settings JSON for the user.
  Future<void> cacheSettings(UserSettingsEntity settings) async {
    try {
      await _secureStorage.writeRaw(
        _key(settings.userId),
        jsonEncode(
          UserSettingsModel(
            userId: settings.userId,
            displayName: settings.displayName,
            avatarUrl: settings.avatarUrl,
            favoriteTeams: settings.favoriteTeams,
            notificationPreferences: settings.notificationPreferences,
            themeMode: settings.themeMode,
            language: settings.language,
          ).toJson(),
        ),
      );
    } catch (_) {
      throw const CacheException('Unable to cache user settings.');
    }
  }

  /// Reads the cached settings for the user, or null if none cached.
  Future<UserSettingsEntity?> getCachedSettings(String userId) async {
    try {
      final raw = await _secureStorage.readRaw(_key(userId));
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserSettingsModel.fromJson(userId, map).toEntity();
    } catch (_) {
      return null;
    }
  }

  /// Clears the cached settings for the user.
  Future<void> clearCache(String userId) async {
    try {
      await _secureStorage.deleteRaw(_key(userId));
    } catch (_) {
      // Best-effort clear.
    }
  }
}
