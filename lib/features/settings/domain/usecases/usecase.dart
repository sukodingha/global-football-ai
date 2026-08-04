import '../entities/user_settings_entity.dart';

/// Base contract for settings use cases.
abstract class UseCase<Type, Params> {
  Type call(Params params);
}

/// Params for watching a user's settings.
class WatchSettingsParams {
  const WatchSettingsParams(this.userId);
  final String userId;
}

/// Params for getting a user's settings.
class GetSettingsParams {
  const GetSettingsParams(this.userId);
  final String userId;
}

/// Params for saving a user's settings.
class SaveSettingsParams {
  const SaveSettingsParams(this.settings);
  final UserSettingsEntity settings;
}

/// Params for updating profile fields.
class UpdateProfileParams {
  const UpdateProfileParams({
    required this.userId,
    this.displayName,
    this.avatarUrl,
  });
  final String userId;
  final String? displayName;
  final String? avatarUrl;
}

/// Params for updating favorite teams.
class UpdateFavoriteTeamsParams {
  const UpdateFavoriteTeamsParams({
    required this.userId,
    required this.favoriteTeams,
  });
  final String userId;
  final List<String> favoriteTeams;
}

/// Params for updating notification preferences.
class UpdateNotificationPreferencesParams {
  const UpdateNotificationPreferencesParams({
    required this.userId,
    required this.preferences,
  });
  final String userId;
  final NotificationPreferences preferences;
}

/// Params for updating theme mode.
class UpdateThemeModeParams {
  const UpdateThemeModeParams({
    required this.userId,
    required this.themeMode,
  });
  final String userId;
  final String themeMode;
}
