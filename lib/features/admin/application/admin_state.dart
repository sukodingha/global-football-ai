import '../domain/entities/admin_analytics_entity.dart';
import '../domain/entities/admin_audit_log_entity.dart';
import '../domain/entities/admin_competition_entity.dart';
import '../domain/entities/admin_prediction_entity.dart';
import '../domain/entities/admin_revenue_entity.dart';
import '../domain/entities/admin_user_entity.dart';
import '../domain/repositories/admin_repository.dart';

/// Immutable state for the admin dashboard feature.
sealed class AdminState {
  const AdminState();
}

/// Initial state.
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// Loading state.
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// Loaded state with all admin-managed collections + analytics.
class AdminLoaded extends AdminState {
  const AdminLoaded({
    required this.users,
    this.competitions = const [],
    this.predictions = const [],
    this.posts = const [],
    this.auditLogs = const [],
    this.moderationLogs = const [],
    this.analytics,
    this.revenue,
    this.busy = false,
  });

  final List<AdminUserEntity> users;
  final List<AdminCompetitionEntity> competitions;
  final List<AdminPredictionEntity> predictions;
  final List<CommunityModerationView> posts;
  final List<AdminAuditLogEntity> auditLogs;
  final List<ModerationLogEntity> moderationLogs;
  final AdminAnalyticsEntity? analytics;
  final AdminRevenueEntity? revenue;
  final bool busy;

  /// Users with privilege/subscription info (for the subscriptions tab).
  List<AdminUserEntity> get subscriptionView => users;

  AdminLoaded copyWith({
    List<AdminUserEntity>? users,
    List<AdminCompetitionEntity>? competitions,
    List<AdminPredictionEntity>? predictions,
    List<CommunityModerationView>? posts,
    List<AdminAuditLogEntity>? auditLogs,
    List<ModerationLogEntity>? moderationLogs,
    AdminAnalyticsEntity? analytics,
    AdminRevenueEntity? revenue,
    bool? busy,
  }) {
    return AdminLoaded(
      users: users ?? this.users,
      competitions: competitions ?? this.competitions,
      predictions: predictions ?? this.predictions,
      posts: posts ?? this.posts,
      auditLogs: auditLogs ?? this.auditLogs,
      moderationLogs: moderationLogs ?? this.moderationLogs,
      analytics: analytics ?? this.analytics,
      revenue: revenue ?? this.revenue,
      busy: busy ?? this.busy,
    );
  }
}

/// Error state with a user-safe message.
class AdminError extends AdminState {
  const AdminError({required this.message});
  final String message;
}
