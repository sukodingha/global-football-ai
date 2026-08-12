import   '../../../../core/errors/exceptions.dart';
import   '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_analytics_entity.dart';
import '../../domain/entities/admin_audit_log_entity.dart';
import '../../domain/entities/admin_competition_entity.dart';
import '../../domain/entities/admin_prediction_entity.dart';
import '../../domain/entities/admin_revenue_entity.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../engine/analytics_engine.dart';

/// Implementation of [AdminRepository] backed by Firestore.
class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl({required AdminRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final AdminRemoteDataSource _dataSource;

  Future<T> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  Failure _mapException(Exception e) {
    final message = e.toString();
    if (e is NetworkException || message.contains('network')) {
      return Failure.networkFailure(message: message);
    }
    if (e is CacheException || message.contains('cache')) {
      return Failure.cacheFailure(message: message);
    }
    if (e is AuthenticationException || message.contains('permission')) {
      return Failure.serverFailure(
        message: 'You do not have permission to perform this action.',
      );
    }
    return Failure.unknown(message: message);
  }

  @override
  Future<List<AdminUserEntity>> listUsers({int limit = 100}) {
    return _safeCall(() => _dataSource.listUsers(limit: limit));
  }

  @override
  Future<void> setUserBanned({
    required String userId,
    required bool banned,
    String? reason,
  }) {
    return _safeCall(() => _dataSource.setUserBanned(
        userId: userId, banned: banned, reason: reason));
  }

  @override
  Future<void> setUserRole({
    required String userId,
    required UserRole role,
  }) {
    return _safeCall(() => _dataSource.setUserRole(userId: userId, role: role));
  }

  @override
  Future<List<AdminUserEntity>> listSubscriptions({int limit = 100}) {
    return _safeCall(() => _dataSource.listSubscriptions(limit: limit));
  }

  @override
  Future<void> updateSubscription({
    required String userId,
    required bool isPremium,
    String? planName,
    DateTime? end,
  }) {
    return _safeCall(() => _dataSource.updateSubscription(
        userId: userId, isPremium: isPremium, planName: planName, end: end));
  }

  @override
  Future<List<AdminCompetitionEntity>> listCompetitions({int limit = 100}) {
    return _safeCall(() => _dataSource.listCompetitions(limit: limit));
  }

  @override
  Future<AdminCompetitionEntity> createCompetition(AdminCompetitionEntity c) {
    return _safeCall(() => _dataSource.createCompetition(c));
  }

  @override
  Future<void> updateCompetition(AdminCompetitionEntity c) {
    return _safeCall(() => _dataSource.updateCompetition(c));
  }

  @override
  Future<void> setCompetitionFeatured({
    required String id,
    required bool featured,
  }) {
    return _safeCall(() => _dataSource.setCompetitionFlag(
        id: id, featured: featured, active: true));
  }

  @override
  Future<void> setCompetitionActive({
    required String id,
    required bool active,
  }) {
    return _safeCall(() => _dataSource.setCompetitionFlag(
        id: id, featured: false, active: active));
  }

  @override
  Future<List<AdminPredictionEntity>> listPredictions({int limit = 100}) {
    return _safeCall(() => _dataSource.listPredictions(limit: limit));
  }

  @override
  Future<void> verifyPrediction({
    required String predictionId,
    required String adminId,
    required String adminName,
  }) {
    return _safeCall(() => _dataSource.verifyPrediction(
        predictionId: predictionId,
        adminId: adminId,
        adminName: adminName));
  }

  @override
  Future<void> overridePrediction({
    required String predictionId,
    required String outcome,
    required String note,
    required String adminId,
    required String adminName,
  }) {
    return _safeCall(() => _dataSource.overridePrediction(
        predictionId: predictionId,
        outcome: outcome,
        note: note,
        adminId: adminId,
        adminName: adminName));
  }

  @override
  Future<List<CommunityModerationView>> listPostsForModeration({
    int limit = 100,
  }) {
    return _safeCall(() => _dataSource.listPostsForModeration(limit: limit));
  }

  @override
  Future<void> setPostPinned({
    required String postId,
    required bool pinned,
  }) {
    return _safeCall(() => _dataSource.setPostPinned(postId: postId, pinned: pinned));
  }

  @override
  Future<void> deletePost({required String postId}) {
    return _safeCall(() => _dataSource.deletePost(postId: postId));
  }

  @override
  Future<void> logAction({
    required String adminId,
    required String adminName,
    required String action,
    required String targetType,
    required String targetId,
    String? details,
  }) {
    return _safeCall(() => _dataSource.logAction(
        adminId: adminId,
        adminName: adminName,
        action: action,
        targetType: targetType,
        targetId: targetId,
        details: details));
  }

@override
  Future<List<AdminAuditLogEntity>> listAuditLogs({int limit = 50}) {
    return _safeCall(() => _dataSource.listAuditLogs(limit: limit));
  }

  // ─── Analytics & Revenue ──────────────────────────────────────────

  @override
  Future<AdminAnalyticsEntity> getAnalytics() {
    return _safeCall(() async {
      final raw = await _dataSource.fetchAnalyticsRawData();
      return const AdminAnalyticsEngine().buildAnalytics(
        users: raw.users,
        posts: raw.posts,
        predictions: raw.predictions,
        actions: raw.actions,
        totalLeagues: raw.totalLeagues,
        totalTeams: raw.totalTeams,
      );
    });
  }

  @override
  Future<AdminRevenueEntity> getRevenue() {
    return _safeCall(() async {
      final raw = await _dataSource.fetchRevenueRawData();
      return const AdminAnalyticsEngine().buildRevenue(
        transactions: raw.transactions,
        subscriptions: raw.subscriptions,
      );
    });
  }

  @override
  Future<List<ModerationLogEntity>> listModerationLogs({int limit = 100}) {
    return _safeCall(() => _dataSource.listModerationLogs(limit: limit));
  }

  @override
  Future<void> logModeration({
    required String type,
    required String subject,
    required String details,
    String? reportedById,
    String status = 'open',
    String? actionTaken,
  }) {
    return _safeCall(() => _dataSource.logModeration(
          type: type,
          subject: subject,
          details: details,
          reportedById: reportedById,
          status: status,
          actionTaken: actionTaken,
        ));
  }

  @override
  String generateReport({
    required AdminAnalyticsEntity analytics,
    required AdminRevenueEntity revenue,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Global Football AI - Platform Report');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    buffer.writeln('=== ANALYTICS ===');
    buffer.writeln('Total users,${analytics.totalUsers}');
    buffer.writeln('Daily active users,${analytics.dailyActiveUsers}');
    buffer.writeln('Monthly active users,${analytics.monthlyActiveUsers}');
    buffer.writeln('Total predictions,${analytics.totalPredictions}');
    buffer.writeln('Correct predictions,${analytics.correctPredictions}');
    buffer.writeln('Prediction accuracy %,${analytics.accuracyRate.toStringAsFixed(2)}');
    buffer.writeln('Total posts,${analytics.totalPosts}');
    buffer.writeln('Total comments,${analytics.totalComments}');
    buffer.writeln('Total leagues,${analytics.totalLeagues}');
    buffer.writeln('Total teams,${analytics.totalTeams}');
    buffer.writeln();
    buffer.writeln('=== REVENUE ===');
    buffer.writeln('Total revenue (NGN),${revenue.totalRevenueNaira.toStringAsFixed(2)}');
    buffer.writeln('Total transactions,${revenue.totalTransactions}');
    buffer.writeln('Successful transactions,${revenue.successfulTransactions}');
    buffer.writeln('Success rate %,${revenue.successRate.toStringAsFixed(2)}');
    buffer.writeln('Active subscriptions,${revenue.activeSubscriptions}');
    buffer.writeln('New subscriptions this month,${revenue.newSubscriptionsThisMonth}');
    buffer.writeln('Average transaction (NGN),${revenue.averageTransactionNaira.toStringAsFixed(2)}');
    buffer.writeln('Growth rate %,${revenue.growthRate?.toStringAsFixed(2) ?? 'N/A'}');
    buffer.writeln();
    buffer.writeln('=== ENGAGEMENT SERIES (date,activeUsers,actions) ===');
    for (final p in analytics.engagementSeries) {
      buffer.writeln(
          '${p.date.toIso8601String()},${p.activeUsers},${p.actions}');
    }
    buffer.writeln();
    buffer.writeln('=== REVENUE SERIES (date,revenueNGN,transactions) ===');
    for (final p in revenue.revenueSeries) {
      buffer.writeln(
          '${p.date.toIso8601String()},${p.revenueNaira.toStringAsFixed(2)},${p.transactionCount}');
    }
    return buffer.toString();
  }
}
