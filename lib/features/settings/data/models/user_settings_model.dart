import '../../domain/entities/user_settings_entity.dart';

/// Data-layer model for [UserSettingsEntity].
class UserSettingsModel extends UserSettingsEntity {
  const UserSettingsModel({
    required super.userId,
    super.displayName,
    super.avatarUrl,
    super.favoriteTeams,
    super.notificationPreferences,
    super.themeMode,
    super.language,
  });

  /// Maps a Firestore JSON map to a [UserSettingsModel].
  factory UserSettingsModel.fromJson(
    String userId,
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return UserSettingsModel(userId: userId);
    }
    final prefs = json['notificationPreferences'] as Map<String, dynamic>? ??
        const {};
    return UserSettingsModel(
      userId: userId,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      favoriteTeams:
          (json['favoriteTeams'] as List<dynamic>? ?? const []).cast<String>(),
      notificationPreferences: NotificationPreferences(
        matchReminders: prefs['matchReminders'] as bool? ?? true,
        breakingNews: prefs['breakingNews'] as bool? ?? true,
        communityReplies: prefs['communityReplies'] as bool? ?? true,
        promotions: prefs['promotions'] as bool? ?? false,
      ),
      themeMode: json['themeMode'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
    );
  }

  /// Serializes to a Firestore JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'favoriteTeams': favoriteTeams,
      'notificationPreferences': {
        'matchReminders': notificationPreferences.matchReminders,
        'breakingNews': notificationPreferences.breakingNews,
        'communityReplies': notificationPreferences.communityReplies,
        'promotions': notificationPreferences.promotions,
      },
      'themeMode': themeMode,
      'language': language,
    };
  }

  /// Converts to the domain [UserSettingsEntity].
  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      favoriteTeams: favoriteTeams,
      notificationPreferences: notificationPreferences,
      themeMode: themeMode,
      language: language,
    );
  }
}
