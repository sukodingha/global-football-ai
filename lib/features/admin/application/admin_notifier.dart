import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/admin_analytics_entity.dart';
import '../domain/entities/admin_audit_log_entity.dart';
import '../domain/entities/admin_competition_entity.dart';
import '../domain/entities/admin_prediction_entity.dart';
import '../domain/entities/admin_revenue_entity.dart';
import '../domain/entities/admin_user_entity.dart';
import '../domain/repositories/admin_repository.dart';
import 'admin_state.dart';

/// Riverpod controller for the admin dashboard.
///
/// Loads users, competitions, predictions, posts, and audit logs, and
/// exposes mutation methods that also write to the audit log.
class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier({required AdminRepository repository})
      : _repository = repository,
        super(const AdminInitial());

  final AdminRepository _repository;

  /// The current admin identity (set when the dashboard is mounted).
  String? _adminId;
  String? _adminName;

  void setAdmin({required String adminId, required String adminName}) {
    _adminId = adminId;
    _adminName = adminName;
  }

/// Loads everything for the dashboard.
  Future<void> loadDashboard() async {
    state = const AdminLoading();
    try {
      final results = await Future.wait([
        _repository.listUsers(),
        _repository.listCompetitions(),
        _repository.listPredictions(),
        _repository.listPostsForModeration(),
        _repository.listAuditLogs(),
        _repository.getAnalytics(),
        _repository.getRevenue(),
        _repository.listModerationLogs(),
      ]);
      state = AdminLoaded(
        users: results[0] as List<AdminUserEntity>,
        competitions: results[1] as List<AdminCompetitionEntity>,
        predictions: results[2] as List<AdminPredictionEntity>,
        posts: results[3] as List<CommunityModerationView>,
        auditLogs: results[4] as List<AdminAuditLogEntity>,
        analytics: results[5] as AdminAnalyticsEntity,
        revenue: results[6] as AdminRevenueEntity,
        moderationLogs: results[7] as List<ModerationLogEntity>,
      );
    } on Failure catch (f) {
      state = AdminError(message: f.message);
    } catch (_) {
      state = const AdminError(message: 'Unable to load admin dashboard.');
    }
  }

  /// Refreshes only the analytics + revenue + moderation logs (lightweight).
  Future<void> refreshInsights() async {
    if (state is! AdminLoaded) return;
    try {
      final results = await Future.wait([
        _repository.getAnalytics(),
        _repository.getRevenue(),
        _repository.listModerationLogs(),
      ]);
      state = (state as AdminLoaded).copyWith(
        analytics: results[0] as AdminAnalyticsEntity,
        revenue: results[1] as AdminRevenueEntity,
        moderationLogs: results[2] as List<ModerationLogEntity>,
      );
    } on Failure catch (f) {
      state = AdminError(message: f.message);
    } catch (_) {
      state = const AdminError(message: 'Unable to refresh insights.');
    }
  }

  /// Generates a downloadable CSV report from the current insights.
  String generateReport() {
    if (state is! AdminLoaded) return '';
    final loaded = state as AdminLoaded;
    final analytics = loaded.analytics;
    final revenue = loaded.revenue;
    if (analytics == null || revenue == null) return '';
    return _repository.generateReport(analytics: analytics, revenue: revenue);
  }

  void _setBusy(bool busy) {
    if (state is AdminLoaded) {
      state = (state as AdminLoaded).copyWith(busy: busy);
    }
  }

  Future<void> _audit({
    required String action,
    required String targetType,
    required String targetId,
    String? details,
  }) async {
    final adminId = _adminId;
    final adminName = _adminName;
    if (adminId == null || adminName == null) return;
    await _repository.logAction(
      adminId: adminId,
      adminName: adminName,
      action: action,
      targetType: targetType,
      targetId: targetId,
      details: details,
    );
  }

  // ─── Users ────────────────────────────────────────────────────────

  Future<void> setUserBanned({
    required String userId,
    required bool banned,
    String? reason,
  }) async {
    _setBusy(true);
    try {
      await _repository.setUserBanned(
          userId: userId, banned: banned, reason: reason);
      await _refreshUsers();
      await _audit(
        action: banned ? 'ban_user' : 'unban_user',
        targetType: 'user',
        targetId: userId,
        details: reason,
      );
      if (banned) {
        await _repository.logModeration(
          type: 'banned_user',
          subject: 'User $userId',
          details: reason ?? 'Banned by admin',
          status: 'resolved',
          actionTaken: 'User banned',
        );
      }
    } finally {
      _setBusy(false);
    }
  }

  Future<void> setUserRole({
    required String userId,
    required UserRole role,
  }) async {
    _setBusy(true);
    try {
      await _repository.setUserRole(userId: userId, role: role);
      await _refreshUsers();
      await _audit(
        action: 'set_role',
        targetType: 'user',
        targetId: userId,
        details: role.label,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateSubscription({
    required String userId,
    required bool isPremium,
    String? planName,
    DateTime? end,
  }) async {
    _setBusy(true);
    try {
      await _repository.updateSubscription(
          userId: userId, isPremium: isPremium, planName: planName, end: end);
      await _refreshUsers();
      await _audit(
        action: 'update_subscription',
        targetType: 'user',
        targetId: userId,
        details: isPremium ? 'granted premium' : 'revoked premium',
      );
    } finally {
      _setBusy(false);
    }
  }

  // ─── Competitions ─────────────────────────────────────────────────

  Future<void> createCompetition(AdminCompetitionEntity c) async {
    _setBusy(true);
    try {
      await _repository.createCompetition(c);
      await _refreshCompetitions();
      await _audit(
        action: 'create_competition',
        targetType: 'competition',
        targetId: c.name,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateCompetition(AdminCompetitionEntity c) async {
    _setBusy(true);
    try {
      await _repository.updateCompetition(c);
      await _refreshCompetitions();
      await _audit(
        action: 'update_competition',
        targetType: 'competition',
        targetId: c.id,
        details: c.name,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> toggleCompetitionFeatured({required String id, required bool featured}) async {
    _setBusy(true);
    try {
      await _repository.setCompetitionFeatured(id: id, featured: featured);
      await _refreshCompetitions();
      await _audit(
        action: featured ? 'feature_competition' : 'unfeature_competition',
        targetType: 'competition',
        targetId: id,
      );
    } finally {
      _setBusy(false);
    }
  }

  // ─── Predictions ──────────────────────────────────────────────────

  Future<void> verifyPrediction({required String predictionId}) async {
    _setBusy(true);
    try {
      await _repository.verifyPrediction(
        predictionId: predictionId,
        adminId: _adminId ?? '',
        adminName: _adminName ?? 'Admin',
      );
      await _refreshPredictions();
      await _audit(
        action: 'verify_prediction',
        targetType: 'prediction',
        targetId: predictionId,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> overridePrediction({
    required String predictionId,
    required String outcome,
    required String note,
  }) async {
    _setBusy(true);
    try {
      await _repository.overridePrediction(
        predictionId: predictionId,
        outcome: outcome,
        note: note,
        adminId: _adminId ?? '',
        adminName: _adminName ?? 'Admin',
      );
      await _refreshPredictions();
      await _audit(
        action: 'override_prediction',
        targetType: 'prediction',
        targetId: predictionId,
        details: outcome,
      );
    } finally {
      _setBusy(false);
    }
  }

  // ─── Moderation ───────────────────────────────────────────────────

  Future<void> setPostPinned({required String postId, required bool pinned}) async {
    _setBusy(true);
    try {
      await _repository.setPostPinned(postId: postId, pinned: pinned);
      await _refreshPosts();
      await _audit(
        action: pinned ? 'pin_post' : 'unpin_post',
        targetType: 'post',
        targetId: postId,
      );
      await _repository.logModeration(
        type: 'flagged_post',
        subject: 'Post $postId',
        details: pinned ? 'Post pinned by admin' : 'Post unpinned by admin',
        status: 'resolved',
        actionTaken: pinned ? 'Post pinned' : 'Post unpinned',
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deletePost({required String postId}) async {
    _setBusy(true);
    try {
      await _repository.deletePost(postId: postId);
      await _refreshPosts();
      await _audit(
        action: 'delete_post',
        targetType: 'post',
        targetId: postId,
      );
      await _repository.logModeration(
        type: 'reported_content',
        subject: 'Post $postId',
        details: 'Post deleted by admin',
        status: 'resolved',
        actionTaken: 'Post deleted',
      );
    } finally {
      _setBusy(false);
    }
  }

  // ─── Refresh helpers ──────────────────────────────────────────────

  Future<void> _refreshUsers() async {
    if (state is! AdminLoaded) return;
    final users = await _repository.listUsers();
    state = (state as AdminLoaded).copyWith(users: users);
  }

  Future<void> _refreshCompetitions() async {
    if (state is! AdminLoaded) return;
    final competitions = await _repository.listCompetitions();
    state = (state as AdminLoaded).copyWith(competitions: competitions);
  }

  Future<void> _refreshPredictions() async {
    if (state is! AdminLoaded) return;
    final predictions = await _repository.listPredictions();
    state = (state as AdminLoaded).copyWith(predictions: predictions);
  }

  Future<void> _refreshPosts() async {
    if (state is! AdminLoaded) return;
    final posts = await _repository.listPostsForModeration();
    state = (state as AdminLoaded).copyWith(posts: posts);
  }
}
