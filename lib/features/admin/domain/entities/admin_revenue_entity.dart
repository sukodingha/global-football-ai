import 'package:equatable/equatable.dart';

/// Aggregate revenue & financial metrics for the admin dashboard.
class AdminRevenueEntity extends Equatable {
  const AdminRevenueEntity({
    required this.totalRevenueKobo,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.activeSubscriptions,
    required this.newSubscriptionsThisMonth,
    required this.revenueSeries,
    this.generatedAt,
  });

  final int totalRevenueKobo;
  final int totalTransactions;
  final int successfulTransactions;
  final int activeSubscriptions;
  final int newSubscriptionsThisMonth;

  /// Daily/period revenue series for charting.
  final List<RevenueDayPoint> revenueSeries;

  final DateTime? generatedAt;

  /// Total revenue in Naira.
  double get totalRevenueNaira => totalRevenueKobo / 100;

  /// Percentage of transactions that succeeded.
  double get successRate {
    if (totalTransactions == 0) return 0;
    return (successfulTransactions / totalTransactions) * 100;
  }

  /// Average transaction value in Naira.
  double get averageTransactionNaira {
    if (successfulTransactions == 0) return 0;
    return totalRevenueNaira / successfulTransactions;
  }

  /// Month-over-month revenue growth percentage.
  double? get growthRate {
    if (revenueSeries.length < 2) return null;
    final previous = revenueSeries[revenueSeries.length - 2].revenueKobo;
    final current = revenueSeries.last.revenueKobo;
    if (previous <= 0) return null;
    return ((current - previous) / previous) * 100;
  }

  AdminRevenueEntity copyWith({
    int? totalRevenueKobo,
    int? totalTransactions,
    int? successfulTransactions,
    int? activeSubscriptions,
    int? newSubscriptionsThisMonth,
    List<RevenueDayPoint>? revenueSeries,
    DateTime? generatedAt,
  }) {
    return AdminRevenueEntity(
      totalRevenueKobo: totalRevenueKobo ?? this.totalRevenueKobo,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      successfulTransactions:
          successfulTransactions ?? this.successfulTransactions,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      newSubscriptionsThisMonth:
          newSubscriptionsThisMonth ?? this.newSubscriptionsThisMonth,
      revenueSeries: revenueSeries ?? this.revenueSeries,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
        totalRevenueKobo,
        totalTransactions,
        successfulTransactions,
        activeSubscriptions,
        newSubscriptionsThisMonth,
        revenueSeries,
        generatedAt,
      ];
}

/// A single point in the revenue time series.
class RevenueDayPoint extends Equatable {
  const RevenueDayPoint({
    required this.date,
    required this.revenueKobo,
    required this.transactionCount,
  });

  final DateTime date;
  final int revenueKobo;
  final int transactionCount;

  double get revenueNaira => revenueKobo / 100;

  @override
  List<Object?> get props => [date, revenueKobo, transactionCount];
}

/// A moderation log entry (flagged post, banned user, reported content).
class ModerationLogEntity extends Equatable {
  const ModerationLogEntity({
    required this.id,
    required this.type,
    required this.subject,
    required this.details,
    required this.createdAt,
    this.reportedById,
    this.status = 'open',
    this.actionTaken,
  });

  final String id;

  /// One of: 'flagged_post', 'banned_user', 'reported_content', 'report'.
  final String type;
  final String subject;
  final String details;
  final DateTime createdAt;
  final String? reportedById;
  final String status;
  final String? actionTaken;

  String get typeLabel => switch (type) {
        'flagged_post' => 'Flagged Post',
        'banned_user' => 'Banned User',
        'reported_content' => 'Reported Content',
        'report' => 'Report',
        _ => type,
      };

  @override
  List<Object?> get props => [
        id,
        type,
        subject,
        details,
        createdAt,
        reportedById,
        status,
        actionTaken,
      ];
}
