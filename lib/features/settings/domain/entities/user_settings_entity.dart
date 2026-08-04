import 'package:equatable/equatable.dart';

/// Notification preferences for the user.
class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.matchReminders = true,
    this.breakingNews = true,
    this.communityReplies = true,
    this.promotions = false,
  });

  final bool matchReminders;
  final bool breakingNews;
  final bool communityReplies;
  final bool promotions;

  NotificationPreferences copyWith({
    bool? matchReminders,
    bool? breakingNews,
    bool? communityReplies,
    bool? promotions,
  }) {
    return NotificationPreferences(
      matchReminders: matchReminders ?? this.matchReminders,
      breakingNews: breakingNews ?? this.breakingNews,
      communityReplies: communityReplies ?? this.communityReplies,
      promotions: promotions ?? this.promotions,
    );
  }

  @override
  List<Object?> get props => [
        matchReminders,
        breakingNews,
        communityReplies,
        promotions,
      ];
}

/// Domain entity representing a user's profile & custom settings.
///
/// Synced in real-time with Firestore and cached locally for offline access.
class UserSettingsEntity extends Equatable {
  const UserSettingsEntity({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.favoriteTeams = const [],
    this.notificationPreferences = const NotificationPreferences(),
    this.themeMode = 'system',
    this.language = 'en',
  });

  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final List<String> favoriteTeams;
  final NotificationPreferences notificationPreferences;

  /// 'system' | 'light' | 'dark'
  final String themeMode;

  /// ISO 639-1 language code (e.g. 'en', 'fr').
  final String language;

  UserSettingsEntity copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    List<String>? favoriteTeams,
    NotificationPreferences? notificationPreferences,
    String? themeMode,
    String? language,
  }) {
    return UserSettingsEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteTeams: favoriteTeams ?? this.favoriteTeams,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        favoriteTeams,
        notificationPreferences,
        themeMode,
        language,
      ];
}
