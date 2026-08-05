import '../models/analytics_models.dart';
import '../../domain/entities/admin_analytics_entity.dart';
import '../../domain/entities/admin_revenue_entity.dart';

/// Aggregates raw platform data into analytics and revenue metrics.
///
/// The engine is pure and deterministic: given raw snapshots (users, posts,
/// predictions, transactions, subscription profiles) it produces the derived
/// [AdminAnalyticsEntity] and [AdminRevenueEntity] used by the dashboard.
class AdminAnalyticsEngine {
  const AdminAnalyticsEngine();

  /// Builds a platform analytics snapshot from raw data.
  AdminAnalyticsEntity buildAnalytics({
    required List<RawUserMetric> users,
    required List<RawPostMetric> posts,
    required List<RawPredictionMetric> predictions,
    required List<RawActionMetric> actions,
    required int totalLeagues,
    required int totalTeams,
    DateTime? generatedAt,
  }) {
    final now = generatedAt ?? DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    final last30d = now.subtract(const Duration(days: 30));

    final dailyActive = <String>{
      for (final u in users)
        if (u.lastActiveAt?.isAfter(last24h) ?? false) u.userId,
    };
    final monthlyActive = <String>{
      for (final u in users)
        if (u.lastActiveAt?.isAfter(last30d) ?? false) u.userId,
    };

    final series = _buildEngagementSeries(users, actions, now);
    final trend = _buildAccuracyTrend(predictions);

    // Map competition -> engagement count.
    final compEngagement = <String, int>{};
    for (final p in predictions) {
      final key = p.competitionName.isEmpty
          ? 'General'
          : p.competitionName;
      compEngagement[key] = (compEngagement[key] ?? 0) + 1;
    }
    final topCompetition = {
      for (final e in (compEngagement.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)))
          .take(5))
        e.key: e.value,
    };

    final totalPredictions = predictions.length;
    final correctPredictions =
        predictions.where((p) => p.isCorrect ?? false).length;

    return AdminAnalyticsEntity(
      totalUsers: users.length,
      dailyActiveUsers: dailyActive.length,
      monthlyActiveUsers: monthlyActive.length,
      totalPredictions: totalPredictions,
      correctPredictions: correctPredictions,
      totalPosts: posts.length,
      totalComments: posts.fold<int>(0, (sum, p) => sum + p.commentCount),
      totalLeagues: totalLeagues,
      totalTeams: totalTeams,
      engagementSeries: series,
      accuracyTrend: trend,
      topCompetitionEngagement: topCompetition,
      generatedAt: now,
    );
  }

  /// Builds a revenue snapshot from raw transaction + subscription data.
  AdminRevenueEntity buildRevenue({
    required List<RawTransactionMetric> transactions,
    required List<RawSubscriptionMetric> subscriptions,
    DateTime? generatedAt,
  }) {
    final now = generatedAt ?? DateTime.now();

    final successful = transactions
        .where((t) => t.status == 'success')
        .toList();
    final totalRevenueKobo = successful.fold<int>(
        0, (sum, t) => sum + t.amountKobo);

    final activeSubscriptions = subscriptions
        .where((s) => s.isPremiumActive)
        .length;

    final monthStart = DateTime(now.year, now.month, 1);
    final newThisMonth = subscriptions
        .where((s) => (s.createdAt?.isAfter(monthStart) ?? false))
        .length;

    final series = _buildRevenueSeries(successful, now);

    return AdminRevenueEntity(
      totalRevenueKobo: totalRevenueKobo,
      totalTransactions: transactions.length,
      successfulTransactions: successful.length,
      activeSubscriptions: activeSubscriptions,
      newSubscriptionsThisMonth: newThisMonth,
      revenueSeries: series,
      generatedAt: now,
    );
  }

  /// Builds a daily engagement series for the last [days] days.
  List<EngagementPoint> _buildEngagementSeries(
    List<RawUserMetric> users,
    List<RawActionMetric> actions,
    DateTime now,
  ) {
    const days = 14;
    final points = <EngagementPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));

      final activeSet = <String>{
        for (final u in users)
          if ((u.lastActiveAt?.isAfter(day) ?? false) &&
              (u.lastActiveAt?.isBefore(next) ?? true))
            u.userId,
      };
      final actionsThatDay = actions
          .where((a) =>
              a.timestamp.isAfter(day) && a.timestamp.isBefore(next))
          .length;

      points.add(EngagementPoint(
        date: day,
        activeUsers: activeSet.length,
        actions: actionsThatDay,
      ));
    }
    return points;
  }

  /// Builds a weekly accuracy trend from prediction history.
  List<AccuracyTrendPoint> _buildAccuracyTrend(
    List<RawPredictionMetric> predictions,
  ) {
    final byWeek = <String, ({int total, int correct})>{};
    for (final p in predictions) {
      final date = p.createdAt;
      final weekStart = DateTime(date.year, date.month, date.day)
          .subtract(Duration(days: date.weekday - 1));
      final key = '${weekStart.year}-${_pad(weekStart.month)}-${_pad(weekStart.day)}';
      final current = byWeek[key] ?? (total: 0, correct: 0);
      byWeek[key] = (
        total: current.total + 1,
        correct: current.correct + ((p.isCorrect ?? false) ? 1 : 0),
      );
    }

    final entries = byWeek.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map((e) => AccuracyTrendPoint(
              period: e.key,
              totalPredictions: e.value.total,
              correctPredictions: e.value.correct,
            ))
        .toList();
  }

  /// Builds a daily revenue series for the last [days] days.
  List<RevenueDayPoint> _buildRevenueSeries(
    List<RawTransactionMetric> successful,
    DateTime now,
  ) {
    const days = 14;
    final points = <RevenueDayPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final dayTx = successful
          .where((t) => t.createdAt.isAfter(day) && t.createdAt.isBefore(next))
          .toList();
      final revenue = dayTx.fold<int>(0, (sum, t) => sum + t.amountKobo);
      points.add(RevenueDayPoint(
        date: day,
        revenueKobo: revenue,
        transactionCount: dayTx.length,
      ));
    }
    return points;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
