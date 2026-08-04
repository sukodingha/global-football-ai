import 'package:equatable/equatable.dart';

/// Granular notification preferences for the user.
///
/// Extends the base [NotificationPreferences] concept with per-event toggles
/// (goals, kickoff, half-time, full-time), news feeds (breaking, transfer),
/// prediction alerts, and personalized team/competition subscriptions.
class AppNotificationPreferences extends Equatable {
  const AppNotificationPreferences({
    this.matchReminders = true,
    this.breakingNews = true,
    this.transferNews = true,
    this.goalAlerts = true,
    this.kickoffAlerts = false,
    this.halfTimeAlerts = false,
    this.fullTimeAlerts = true,
    this.predictionAlerts = true,
    this.communityReplies = true,
    this.promotions = false,
    this.favoriteTeams = const [],
    this.favoriteCompetitions = const [],
  });

  /// Base toggles (kept for parity with the settings feature).
  final bool matchReminders;
  final bool breakingNews;
  final bool communityReplies;
  final bool promotions;

  /// News & personalized feeds.
  final bool transferNews;

  /// Match & event alerts.
  final bool goalAlerts;
  final bool kickoffAlerts;
  final bool halfTimeAlerts;
  final bool fullTimeAlerts;

  /// Prediction result lock alerts.
  final bool predictionAlerts;

  /// Personalized favorite teams & competitions.
  final List<String> favoriteTeams;
  final List<String> favoriteCompetitions;

  AppNotificationPreferences copyWith({
    bool? matchReminders,
    bool? breakingNews,
    bool? transferNews,
    bool? goalAlerts,
    bool? kickoffAlerts,
    bool? halfTimeAlerts,
    bool? fullTimeAlerts,
    bool? predictionAlerts,
    bool? communityReplies,
    bool? promotions,
    List<String>? favoriteTeams,
    List<String>? favoriteCompetitions,
  }) {
    return AppNotificationPreferences(
      matchReminders: matchReminders ?? this.matchReminders,
      breakingNews: breakingNews ?? this.breakingNews,
      transferNews: transferNews ?? this.transferNews,
      goalAlerts: goalAlerts ?? this.goalAlerts,
      kickoffAlerts: kickoffAlerts ?? this.kickoffAlerts,
      halfTimeAlerts: halfTimeAlerts ?? this.halfTimeAlerts,
      fullTimeAlerts: fullTimeAlerts ?? this.fullTimeAlerts,
      predictionAlerts: predictionAlerts ?? this.predictionAlerts,
      communityReplies: communityReplies ?? this.communityReplies,
      promotions: promotions ?? this.promotions,
      favoriteTeams: favoriteTeams ?? this.favoriteTeams,
      favoriteCompetitions:
          favoriteCompetitions ?? this.favoriteCompetitions,
    );
  }

  /// Maps the enabled match/event toggles to their FCM topic names.
  List<String> get enabledTopics {
    final topics = <String>[];
    if (matchReminders || goalAlerts) topics.add('match_goals');
    if (kickoffAlerts) topics.add('match_kickoff');
    if (halfTimeAlerts) topics.add('match_halftime');
    if (fullTimeAlerts) topics.add('match_fulltime');
    if (predictionAlerts) topics.add('match_predictions');
    if (breakingNews) topics.add('breaking_news');
    if (transferNews) topics.add('transfer_news');
    if (communityReplies) topics.add('community_replies');
    if (promotions) topics.add('promotions');
    return topics;
  }

  @override
  List<Object?> get props => [
        matchReminders,
        breakingNews,
        transferNews,
        goalAlerts,
        kickoffAlerts,
        halfTimeAlerts,
        fullTimeAlerts,
        predictionAlerts,
        communityReplies,
        promotions,
        favoriteTeams,
        favoriteCompetitions,
      ];
}
