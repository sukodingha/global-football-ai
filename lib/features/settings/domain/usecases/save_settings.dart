import '../entities/user_settings_entity.dart';
import '../repositories/settings_repository.dart';
import 'usecase.dart';

/// Saves a user's complete settings.
class SaveSettings implements UseCase<Future<void>, SaveSettingsParams> {
  const SaveSettings(this._repository);
  final SettingsRepository _repository;

  @override
  Future<void> call(SaveSettingsParams params) {
    return _repository.saveSettings(params.settings);
  }
}

/// Updates the user's profile (display name + avatar).
class UpdateProfile implements UseCase<Future<void>, UpdateProfileParams> {
  const UpdateProfile(this._repository);
  final SettingsRepository _repository;

  @override
  Future<void> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      userId: params.userId,
      displayName: params.displayName,
      avatarUrl: params.avatarUrl,
    );
  }
}

/// Updates the user's favorite teams.
class UpdateFavoriteTeams
    implements UseCase<Future<void>, UpdateFavoriteTeamsParams> {
  const UpdateFavoriteTeams(this._repository);
  final SettingsRepository _repository;

  @override
  Future<void> call(UpdateFavoriteTeamsParams params) {
    return _repository.updateFavoriteTeams(
      userId: params.userId,
      favoriteTeams: params.favoriteTeams,
    );
  }
}

/// Updates the user's notification preferences.
class UpdateNotificationPreferences
    implements
        UseCase<Future<void>, UpdateNotificationPreferencesParams> {
  const UpdateNotificationPreferences(this._repository);
  final SettingsRepository _repository;

  @override
  Future<void> call(UpdateNotificationPreferencesParams params) {
    return _repository.updateNotificationPreferences(
      userId: params.userId,
      preferences: params.preferences,
    );
  }
}

/// Updates the user's theme mode.
class UpdateThemeMode implements UseCase<Future<void>, UpdateThemeModeParams> {
  const UpdateThemeMode(this._repository);
  final SettingsRepository _repository;

  @override
  Future<void> call(UpdateThemeModeParams params) {
    return _repository.updateThemeMode(
      userId: params.userId,
      themeMode: params.themeMode,
    );
  }
}
