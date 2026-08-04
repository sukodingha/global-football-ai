import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/dependency_injection.dart';
import '../../auth/application/auth_providers.dart';
import '../data/dependency_injection.dart';
import '../domain/entities/user_settings_entity.dart';
import 'settings_notifier.dart';
import 'settings_state.dart';

/// Provider for the [SettingsNotifier] controller.
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    repository: ref.watch(settingsRepositoryProvider),
    watchSettings: ref.watch(watchSettingsUseCaseProvider),
    getSettings: ref.watch(getSettingsUseCaseProvider),
    saveSettings: ref.watch(saveSettingsUseCaseProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});

/// Selector for the current user's settings.
final userSettingsProvider = Provider<UserSettingsEntity?>((ref) {
  final state = ref.watch(settingsNotifierProvider);
  if (state is SettingsLoaded) return state.settings;
  return null;
});

/// Selector for settings saving state.
final settingsSavingProvider = Provider<bool>((ref) {
  final state = ref.watch(settingsNotifierProvider);
  return state is SettingsLoaded && state.saving;
});

/// Provider that starts loading settings for the current user when read.
final settingsControllerProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    ref.read(settingsNotifierProvider.notifier).load(user.id);
  }
  return null;
});
