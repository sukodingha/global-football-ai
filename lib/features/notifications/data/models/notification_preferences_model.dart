import '../../domain/entities/notification_preferences_entity.dart';

/// Data-layer model for [AppNotificationPreferences].
class AppNotificationPreferencesModel extends AppNotificationPreferences {
  const AppNotificationPreferencesModel({
    super.matchReminders,
    super.breakingNews,
    super.transferNews,
    super.goalAlerts,
    super.kickoffAlerts,
    super.halfTimeAlerts,
    super.fullTimeAlerts,
    super.predictionAlerts,
    super.communityReplies,
    super.promotions,
    super.favoriteTeams,
    super.favoriteCompetitions,
  });

  /// Maps a Firestore JSON map to a [AppNotificationPreferencesModel].
  factory AppNotificationPreferencesModel.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return const AppNotificationPreferencesModel();
    }
    return AppNotificationPreferencesModel(
      matchReminders: json['matchReminders'] as bool? ?? true,
      breakingNews: json['breakingNews'] as bool? ?? true,
      transferNews: json['transferNews'] as bool? ?? true,
      goalAlerts: json['goalAlerts'] as bool? ?? true,
      kickoffAlerts: json['kickoffAlerts'] as bool? ?? false,
      halfTimeAlerts: json['halfTimeAlerts'] as bool? ?? false,
      fullTimeAlerts: json['fullTimeAlerts'] as bool? ?? true,
      predictionAlerts: json['predictionAlerts'] as bool? ?? true,
      communityReplies: json['communityReplies'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? false,
      favoriteTeams: (json['favoriteTeams'] as List<dynamic>? ?? const [])
          .cast<String>(),
      favoriteCompetitions:
          (json['favoriteCompetitions'] as List<dynamic>? ?? const [])
              .cast<String>(),
    );
  }

  /// Serializes to a Firestore JSON map nested under `notificationPreferences`.
  Map<String, dynamic> toJson() {
    return {
      'matchReminders': matchReminders,
      'breakingNews': breakingNews,
      'transferNews': transferNews,
      'goalAlerts': goalAlerts,
      'kickoffAlerts': kickoffAlerts,
      'halfTimeAlerts': halfTimeAlerts,
      'fullTimeAlerts': fullTimeAlerts,
      'predictionAlerts': predictionAlerts,
      'communityReplies': communityReplies,
      'promotions': promotions,
      'favoriteTeams': favoriteTeams,
      'favoriteCompetitions': favoriteCompetitions,
    };
  }

  /// Converts to the domain [AppNotificationPreferences].
  AppNotificationPreferences toEntity() {
    return AppNotificationPreferences(
      matchReminders: matchReminders,
      breakingNews: breakingNews,
      transferNews: transferNews,
      goalAlerts: goalAlerts,
      kickoffAlerts: kickoffAlerts,
      halfTimeAlerts: halfTimeAlerts,
      fullTimeAlerts: fullTimeAlerts,
      predictionAlerts: predictionAlerts,
      communityReplies: communityReplies,
      promotions: promotions,
      favoriteTeams: favoriteTeams,
      favoriteCompetitions: favoriteCompetitions,
    );
  }
}
