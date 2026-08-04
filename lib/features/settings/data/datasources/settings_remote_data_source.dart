import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../models/user_settings_model.dart';

/// Cloud Firestore-backed data source for user settings.
///
/// Provides real-time sync of a user's profile & custom settings doc.
class SettingsRemoteDataSource {
  SettingsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  /// Watches the user's settings document in real time.
  Stream<UserSettingsEntity> watchSettings(String userId) {
    return _userDoc(userId).snapshots().map(
          (snap) => UserSettingsModel.fromJson(userId, snap.data()).toEntity(),
        );
  }

  /// Reads the user's settings document once.
  Future<UserSettingsEntity> getSettings(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      return UserSettingsModel.fromJson(userId, doc.data()).toEntity();
    } catch (e) {
      throw CacheException('Unable to load settings: $e');
    }
  }

  /// Persists the user's settings (merge) to Firestore.
  Future<void> saveSettings(UserSettingsEntity settings) async {
    try {
      await _userDoc(settings.userId).set(
        UserSettingsModel(
          userId: settings.userId,
          displayName: settings.displayName,
          avatarUrl: settings.avatarUrl,
          favoriteTeams: settings.favoriteTeams,
          notificationPreferences: settings.notificationPreferences,
          themeMode: settings.themeMode,
          language: settings.language,
        ).toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw CacheException('Unable to save settings: $e');
    }
  }

  /// Updates just the profile fields (display name + avatar).
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      await _userDoc(userId).set({
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      throw CacheException('Unable to update profile: $e');
    }
  }

  /// Updates the favorite teams list.
  Future<void> updateFavoriteTeams({
    required String userId,
    required List<String> favoriteTeams,
  }) async {
    try {
      await _userDoc(userId).set({
        'favoriteTeams': favoriteTeams,
      }, SetOptions(merge: true));
    } catch (e) {
      throw CacheException('Unable to update favorite teams: $e');
    }
  }

  /// Updates the notification preferences sub-document.
  Future<void> updateNotificationPreferences({
    required String userId,
    required NotificationPreferences preferences,
  }) async {
    try {
      await _userDoc(userId).set({
        'notificationPreferences': {
          'matchReminders': preferences.matchReminders,
          'breakingNews': preferences.breakingNews,
          'communityReplies': preferences.communityReplies,
          'promotions': preferences.promotions,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      throw CacheException('Unable to update notification preferences: $e');
    }
  }

  /// Updates the theme mode.
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  }) async {
    try {
      await _userDoc(userId).set({
        'themeMode': themeMode,
      }, SetOptions(merge: true));
    } catch (e) {
      throw CacheException('Unable to update theme mode: $e');
    }
  }
}
