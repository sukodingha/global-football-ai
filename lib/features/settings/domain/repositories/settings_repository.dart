import '../entities/user_settings_entity.dart';

/// Contract for the settings repository.
///
/// Combines a Firestore-backed remote data source for real-time sync with a
/// secure local cache for offline persistence.
abstract class SettingsRepository {
  /// Watches the user's settings in real time from Firestore.
  Stream<UserSettingsEntity> watchSettings(String userId);

  /// Returns the user's settings, falling back to the local cache.
  Future<UserSettingsEntity> getSettings(String userId);

  /// Persists the user's settings to Firestore and updates the local cache.
  Future<void> saveSettings(UserSettingsEntity settings);

  /// Updates the display name and avatar URL.
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  });

  /// Updates the user's favorite teams.
  Future<void> updateFavoriteTeams({
    required String userId,
    required List<String> favoriteTeams,
  });

  /// Updates the user's notification preferences.
  Future<void> updateNotificationPreferences({
    required String userId,
    required NotificationPreferences preferences,
  });

  /// Updates the user's theme mode ('system' | 'light' | 'dark').
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  });
}
