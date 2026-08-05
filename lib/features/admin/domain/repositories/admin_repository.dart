import '../../../core/errors/failures.dart';
import '../entities/admin_analytics_entity.dart';
import '../entities/admin_audit_log_entity.dart';
import '../entities/admin_competition_entity.dart';
import '../entities/admin_prediction_entity.dart';
import '../entities/admin_revenue_entity.dart';
import '../entities/admin_user_entity.dart';

/// Contract for the admin dashboard repository.
///
/// Backed by Cloud Firestore. All operations are expected to be invoked
/// only by authenticated users with an admin role (enforced by the data
/// source and Firestore security rules).
abstract class AdminRepository {
  // ─── Users ────────────────────────────────────────────────────────

  /// Lists all users (admin view).
  Future<List<AdminUserEntity>> listUsers({int limit = 100});

  /// Bans (or unbans) a user by id.
  Future<void> setUserBanned({
    required String userId,
    required bool banned,
    String? reason,
  });

  /// Updates the role of a user.
  Future<void> setUserRole({
    required String userId,
    required UserRole role,
  });

  // ─── Subscriptions ────────────────────────────────────────────────

  /// Lists users with their subscription/tier status.
  Future<List<AdminUserEntity>> listSubscriptions({int limit = 100});

  /// Force-updates a user's premium subscription state.
  Future<void> updateSubscription({
    required String userId,
    required bool isPremium,
    String? planName,
    DateTime? end,
  });

  // ─── Competitions ─────────────────────────────────────────────────

  /// Lists all competitions (admin view).
  Future<List<AdminCompetitionEntity>> listCompetitions({int limit = 100});

  /// Creates a new competition.
  Future<AdminCompetitionEntity> createCompetition(AdminCompetitionEntity c);

  /// Updates an existing competition.
  Future<void> updateCompetition(AdminCompetitionEntity c);

  /// Toggles whether a competition is featured.
  Future<void> setCompetitionFeatured({required String id, required bool featured});

  /// Toggles whether a competition is active.
  Future<void> setCompetitionActive({required String id, required bool active});

  // ─── Predictions ──────────────────────────────────────────────────

  /// Lists all predictions for audit.
  Future<List<AdminPredictionEntity>> listPredictions({int limit = 100});

  /// Marks a prediction as verified.
  Future<void> verifyPrediction({
    required String predictionId,
    required String adminId,
    required String adminName,
  });

  /// Overrides a prediction with an admin-provided outcome.
  Future<void> overridePrediction({
    required String predictionId,
    required String outcome,
    required String note,
    required String adminId,
    required String adminName,
  });

  // ─── Community Moderation ─────────────────────────────────────────

  /// Lists community posts for moderation.
  Future<List<CommunityModerationView>> listPostsForModeration({int limit = 100});

  /// Pins (or unpins) a community post.
  Future<void> setPostPinned({required String postId, required bool pinned});

  /// Deletes a community post.
  Future<void> deletePost({required String postId});

  // ─── Audit Log ────────────────────────────────────────────────────

  /// Records an admin action to the audit log.
  Future<void> logAction({
    required String adminId,
    required String adminName,
    required String action,
    required String targetType,
    required String targetId,
    String? details,
  });

/// Fetches recent audit log entries.
  Future<List<AdminAuditLogEntity>> listAuditLogs({int limit = 50});

  // ─── Analytics & Insights ─────────────────────────────────────────

  /// Builds and returns the platform analytics snapshot (users, engagement,
  /// prediction accuracy).
  Future<AdminAnalyticsEntity> getAnalytics();

  /// Builds and returns the revenue dashboard snapshot (subscription metrics,
  /// payment volumes, growth).
  Future<AdminRevenueEntity> getRevenue();

  /// Fetches the centralized moderation log (flagged posts, banned users,
  /// reported content).
  Future<List<ModerationLogEntity>> listModerationLogs({int limit = 100});

  /// Records a moderation action to the log (best-effort).
  Future<void> logModeration({
    required String type,
    required String subject,
    required String details,
    String? reportedById,
    String status = 'open',
    String? actionTaken,
  });

  /// Generates a CSV report string from the provided analytics/revenue data.
  String generateReport({
    required AdminAnalyticsEntity analytics,
    required AdminRevenueEntity revenue,
  });
}

/// Lightweight moderation view of a community post.
class CommunityModerationView {
  const CommunityModerationView({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.pinned = false,
    this.reportCount = 0,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool pinned;
  final int reportCount;
}
