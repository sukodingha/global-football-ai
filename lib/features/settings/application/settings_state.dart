import '../domain/entities/user_settings_entity.dart';

/// Immutable state for the Settings feature.
sealed class SettingsState {
  const SettingsState();
}

/// Initial state.
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading state.
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Loaded state with the user's settings.
class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.settings,
    this.saving = false,
  });

  final UserSettingsEntity settings;
  final bool saving;

  SettingsLoaded copyWith({
    UserSettingsEntity? settings,
    bool? saving,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      saving: saving ?? this.saving,
    );
  }
}

/// Error state with a user-safe message.
class SettingsError extends SettingsState {
  const SettingsError({required this.message});
  final String message;
}
