import 'package:equatable/equatable.dart';

/// Platform-wide analytics snapshot for the admin dashboard.
class AdminAnalyticsEntity extends Equatable {
  const AdminAnalyticsEntity({
    required this.totalUsers,
    required this.dailyActiveUsers,
    required this.monthlyActiveUsers,
    required this.totalPredictions,
    required this.correctPredictions,
    required this.totalPosts,
    required this.totalComments,
    required this.totalLeagues,
    required this.totalTeams,
    required this.engagementSeries,
    required this.accuracyTrend,
    required this.topCompetitionEngagement,
    this.generatedAt,
  });

  final int totalUsers;
  final int dailyActiveUsers;
  final int monthlyActiveUsers;
  final int totalPredictions;
  final int correctPredictions;
  final int totalPosts;
  final int totalComments;
  final int totalLeagues;
  final int totalTeams;

  /// Daily engagement series (e.g. last 7-30 days) for charting.
  final List<EngagementPoint> engagementSeries;

  /// Prediction accuracy trend over time.
  final List<AccuracyTrendPoint> accuracyTrend;

  /// Engagement by competition name -> count.
  final Map<String, int> topCompetitionEngagement;

  final DateTime? generatedAt;

  /// Overall prediction accuracy percentage (0-100).
  double get accuracyRate {
    if (totalPredictions == 0) return 0;
    return (correctPredictions / totalPredictions) * 100;
  }

  /// Engagement ratio (posts + comments) per active user.
  double get engagementPerUser {
    if (dailyActiveUsers == 0) return 0;
    return (totalPosts + totalComments) / dailyActiveUsers;
  }

  AdminAnalyticsEntity copyWith({
    int? totalUsers,
    int? dailyActiveUsers,
    int? monthlyActiveUsers,
    int? totalPredictions,
    int? correctPredictions,
    int? totalPosts,
    int? totalComments,
    int? totalLeagues,
    int? totalTeams,
    List<EngagementPoint>? engagementSeries,
    List<AccuracyTrendPoint>? accuracyTrend,
    Map<String, int>? topCompetitionEngagement,
    DateTime? generatedAt,
  }) {
    return AdminAnalyticsEntity(
      totalUsers: totalUsers ?? this.totalUsers,
      dailyActiveUsers: dailyActiveUsers ?? this.dailyActiveUsers,
      monthlyActiveUsers: monthlyActiveUsers ?? this.monthlyActiveUsers,
      totalPredictions: totalPredictions ?? this.totalPredictions,
      correctPredictions: correctPredictions ?? this.correctPredictions,
      totalPosts: totalPosts ?? this.totalPosts,
      totalComments: totalComments ?? this.totalComments,
      totalLeagues: totalLeagues ?? this.totalLeagues,
      totalTeams: totalTeams ?? this.totalTeams,
      engagementSeries: engagementSeries ?? this.engagementSeries,
      accuracyTrend: accuracyTrend ?? this.accuracyTrend,
      topCompetitionEngagement:
          topCompetitionEngagement ?? this.topCompetitionEngagement,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
        totalUsers,
        dailyActiveUsers,
        monthlyActiveUsers,
        totalPredictions,
        correctPredictions,
        totalPosts,
        totalComments,
        totalLeagues,
        totalTeams,
        engagementSeries,
        accuracyTrend,
        topCompetitionEngagement,
        generatedAt,
      ];
}

/// A single point in the engagement time series.
class EngagementPoint extends Equatable {
  const EngagementPoint({
    required this.date,
    required this.activeUsers,
    required this.actions,
  });

  final DateTime date;
  final int activeUsers;

  /// Number of user actions (posts, votes, comments, predictions) that day.
  final int actions;

  @override
  List<Object?> get props => [date, activeUsers, actions];
}

/// A single point in the prediction accuracy trend.
class AccuracyTrendPoint extends Equatable {
  const AccuracyTrendPoint({
    required this.period,
    required this.totalPredictions,
    required this.correctPredictions,
  });

  final String period;
  final int totalPredictions;
  final int correctPredictions;

  double get accuracy => totalPredictions == 0
      ? 0
      : (correctPredictions / totalPredictions) * 100;

  @override
  List<Object?> get props => [period, totalPredictions, correctPredictions];
}
