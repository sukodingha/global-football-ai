import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/notification_service.dart';
import '../domain/entities/user_settings_entity.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/usecases/get_settings.dart';
import '../domain/usecases/save_settings.dart';
import '../domain/usecases/watch_settings.dart';
import 'settings_state.dart';

/// Riverpod controller managing the user's settings.
///
/// Syncs settings in real time with Firestore, persists locally, and exposes
/// granular update methods for profile, favorite teams, notifications, and
/// theme mode.
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier({
    required SettingsRepository repository,
    required WatchSettings watchSettings,
    required GetSettings getSettings,
    required SaveSettings saveSettings,
    NotificationService? notificationService,
  })  : _repository = repository,
        _watchSettings = watchSettings,
        _getSettings = getSettings,
        _saveSettings = saveSettings,
        _notificationService = notificationService,
        super(const SettingsInitial());

  final SettingsRepository _repository;
  final WatchSettings _watchSettings;
  final GetSettings _getSettings;
  final SaveSettings _saveSettings;
  final NotificationService? _notificationService;

  StreamSubscription<UserSettingsEntity>? _subscription;

/// Loads the settings for [userId], starts the real-time watch, and
  /// initializes push notifications (permission, token sync, topic subs).
  Future<void> load(String userId) async {
    state = const SettingsLoading();
    try {
      final settings = await _getSettings(GetSettingsParams(userId));
      state = SettingsLoaded(settings: settings);
      _startWatch(userId);
      _initNotifications(userId, settings.notificationPreferences);
    } on Failure catch (f) {
      state = SettingsError(message: f.message);
    } catch (_) {
      state = const SettingsError(
        message: 'Unable to load settings. Please try again.',
      );
    }
  }

  /// Requests notification permission, syncs the FCM token, and subscribes to
  /// topics that match the user's current notification preferences.
  Future<void> _initNotifications(
    String userId,
    NotificationPreferences preferences,
  ) async {
    final service = _notificationService;
    if (service == null) return;
    try {
      await service.requestPermission();
      await service.syncTokenToFirestore(userId);
      await service.subscribeToTopics(_topicsFor(preferences));
    } catch (_) {
      // Best-effort; notifications are optional.
    }
  }

  /// Maps notification preferences to the corresponding FCM topics.
  List<String> _topicsFor(NotificationPreferences p) => [
        if (p.matchReminders) NotificationTopics.matchReminders,
        if (p.breakingNews) NotificationTopics.breakingNews,
        if (p.communityReplies) NotificationTopics.communityReplies,
        if (p.promotions) NotificationTopics.promotions,
      ];

  void _startWatch(String userId) {
    _subscription?.cancel();
    _subscription = _watchSettings(WatchSettingsParams(userId)).listen(
      (settings) {
        final s = state;
        if (s is SettingsLoaded) {
          state = s.copyWith(settings: settings);
        } else {
          state = SettingsLoaded(settings: settings);
        }
      },
      onError: (Object _) {
        // Keep last known state; watch is best-effort.
      },
    );
  }

  /// Updates the user's profile (display name + avatar).
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    await _runUpdate(() => _repository.updateProfile(
          userId: userId,
          displayName: displayName,
          avatarUrl: avatarUrl,
        ));
  }

  /// Updates the user's favorite teams.
  Future<void> updateFavoriteTeams({
    required String userId,
    required List<String> favoriteTeams,
  }) async {
    await _runUpdate(() => _repository.updateFavoriteTeams(
          userId: userId,
          favoriteTeams: favoriteTeams,
        ));
  }

/// Updates the user's notification preferences and syncs FCM topic
  /// subscriptions so the device only receives enabled notification types.
  Future<void> updateNotificationPreferences({
    required String userId,
    required NotificationPreferences preferences,
  }) async {
    await _runUpdate(() async {
      await _repository.updateNotificationPreferences(
        userId: userId,
        preferences: preferences,
      );
      await _syncTopics(preferences);
    });
  }

  /// Subscribes to enabled topics and unsubscribes from disabled ones.
  Future<void> _syncTopics(NotificationPreferences preferences) async {
    final service = _notificationService;
    if (service == null) return;
    try {
      final enabled = _topicsFor(preferences);
      const all = [
        NotificationTopics.matchReminders,
        NotificationTopics.breakingNews,
        NotificationTopics.communityReplies,
        NotificationTopics.promotions,
      ];
      final disabled = all.where((t) => !enabled.contains(t)).toList();
      await service.subscribeToTopics(enabled);
      await service.unsubscribeFromTopics(disabled);
    } catch (_) {
      // Best-effort; topic sync is optional.
    }
  }

  /// Updates the user's theme mode.
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  }) async {
    await _runUpdate(() => _repository.updateThemeMode(
          userId: userId,
          themeMode: themeMode,
        ));
  }

  Future<void> _runUpdate(Future<void> Function() action) async {
    final s = state;
    if (s is SettingsLoaded) {
      state = s.copyWith(saving: true);
    }
    try {
      await action();
      final loaded = state;
      if (loaded is SettingsLoaded) {
        state = loaded.copyWith(saving: false);
      }
    } on Failure catch (f) {
      state = SettingsError(message: f.message);
    } catch (_) {
      state = const SettingsError(
        message: 'Unable to save settings. Please try again.',
      );
    }
  }

  /// Clears any error state.
  void clearError() {
    final s = state;
    if (s is SettingsError) {
      state = const SettingsInitial();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
