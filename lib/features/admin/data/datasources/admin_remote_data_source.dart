import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../domain/entities/admin_audit_log_entity.dart';
import '../../domain/entities/admin_competition_entity.dart';
import '../../domain/entities/admin_prediction_entity.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/admin_audit_log_model.dart';
import '../models/admin_competition_model.dart';
import '../models/admin_prediction_model.dart';
import '../models/admin_user_model.dart';
import '../roles/admin_roles.dart';

/// Cloud Firestore-backed data source for the admin dashboard.
///
/// All read/write operations here target admin-managed collections and are
/// expected to be protected by Firestore security rules that only allow
/// authenticated users with an admin role.
class AdminRemoteDataSource {
  AdminRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _communityPosts =>
      _firestore.collection('community_posts');

  CollectionReference<Map<String, dynamic>> get _competitions =>
      _firestore.collection('admin_competitions');

  CollectionReference<Map<String, dynamic>> get _predictions =>
      _firestore.collection('admin_predictions');

  CollectionReference<Map<String, dynamic>> get _auditLogs =>
      _firestore.collection('admin_audit_logs');

  // ─── Users ────────────────────────────────────────────────────────

  Future<List<AdminUserEntity>> listUsers({int limit = 100}) async {
    try {
      final snapshot = await _users.limit(limit).get();
      return snapshot.docs.map(AdminUserModel.fromDoc).map((m) => m.entity).toList();
    } catch (e) {
      throw CacheException('Unable to list users: $e');
    }
  }

  Future<void> setUserBanned({
    required String userId,
    required bool banned,
    String? reason,
  }) async {
    try {
      await _users.doc(userId).update({
        'isBanned': banned,
        if (reason != null) 'banReason': reason,
        'bannedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw CacheException('Unable to update user ban status: $e');
    }
  }

  Future<void> setUserRole({
    required String userId,
    required UserRole role,
  }) async {
    try {
      await _users.doc(userId).update({
        AdminRoles.roleField: AdminRoles.toStorage(role),
      });
    } catch (e) {
      throw CacheException('Unable to update user role: $e');
    }
  }

  // ─── Subscriptions ────────────────────────────────────────────────

  Future<List<AdminUserEntity>> listSubscriptions({int limit = 100}) async {
    final snapshot = await _users.limit(limit).get();
    return snapshot.docs.map(AdminUserModel.fromDoc).map((m) => m.entity).toList();
  }

  Future<void> updateSubscription({
    required String userId,
    required bool isPremium,
    String? planName,
    DateTime? end,
  }) async {
    try {
      await _users.doc(userId).update({
        'premium': isPremium,
        if (planName != null) 'premiumPlanName': planName,
        if (end != null) 'premiumEnd': Timestamp.fromDate(end),
      });
    } catch (e) {
      throw CacheException('Unable to update subscription: $e');
    }
  }

  // ─── Competitions ─────────────────────────────────────────────────

  Future<List<AdminCompetitionEntity>> listCompetitions({int limit = 100}) async {
    try {
      final snapshot = await _competitions.limit(limit).get();
      return snapshot.docs
          .map(AdminCompetitionModel.fromDoc)
          .map((m) => m.entity)
          .toList();
    } catch (e) {
      throw CacheException('Unable to list competitions: $e');
    }
  }

  Future<AdminCompetitionEntity> createCompetition(AdminCompetitionEntity c) async {
    try {
      final ref = _competitions.doc();
      final entity = c.copyWith(id: ref.id);
      await ref.set(AdminCompetitionModel(entity: entity).toJson());
      return entity;
    } catch (e) {
      throw CacheException('Unable to create competition: $e');
    }
  }

  Future<void> updateCompetition(AdminCompetitionEntity c) async {
    try {
      await _competitions
          .doc(c.id)
          .set(AdminCompetitionModel(entity: c).toJson(), SetOptions(merge: true));
    } catch (e) {
      throw CacheException('Unable to update competition: $e');
    }
  }

  Future<void> setCompetitionFlag({
    required String id,
    required bool featured,
    required bool active,
  }) async {
    try {
      await _competitions.doc(id).update({'featured': featured, 'active': active});
    } catch (e) {
      throw CacheException('Unable to update competition flags: $e');
    }
  }

  // ─── Predictions ──────────────────────────────────────────────────

  Future<List<AdminPredictionEntity>> listPredictions({int limit = 100}) async {
    try {
      final snapshot = await _predictions.limit(limit).get();
      return snapshot.docs
          .map(AdminPredictionModel.fromDoc)
          .map((m) => m.entity)
          .toList();
    } catch (e) {
      throw CacheException('Unable to list predictions: $e');
    }
  }

  Future<void> verifyPrediction({
    required String predictionId,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _predictions.doc(predictionId).update({
        'auditStatus': PredictionAuditStatus.verified.name,
        'verifiedBy': adminName,
        'verifiedById': adminId,
        'verifiedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw CacheException('Unable to verify prediction: $e');
    }
  }

  Future<void> overridePrediction({
    required String predictionId,
    required String outcome,
    required String note,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _predictions.doc(predictionId).update({
        'auditStatus': PredictionAuditStatus.overridden.name,
        'overrideOutcome': outcome,
        'overrideNote': note,
        'verifiedBy': adminName,
        'verifiedById': adminId,
        'verifiedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw CacheException('Unable to override prediction: $e');
    }
  }

  // ─── Community Moderation ─────────────────────────────────────────

  Future<List<CommunityModerationView>> listPostsForModeration({
    int limit = 100,
  }) async {
    try {
      final snapshot = await _communityPosts
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CommunityModerationView(
          id: data['id'] as String? ?? doc.id,
          authorId: data['authorId'] as String? ?? '',
          authorName: data['authorName'] as String? ?? 'Unknown',
          content: data['content'] as String? ?? '',
          createdAt: _timestamp(data['createdAt']) ?? DateTime.now(),
          likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
          commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
          pinned: data['pinned'] as bool? ?? false,
          reportCount: (data['reportCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      throw CacheException('Unable to list posts: $e');
    }
  }

  Future<void> setPostPinned({
    required String postId,
    required bool pinned,
  }) async {
    try {
      await _communityPosts.doc(postId).update({'pinned': pinned});
    } catch (e) {
      throw CacheException('Unable to update post pin: $e');
    }
  }

  Future<void> deletePost({required String postId}) async {
    try {
      await _communityPosts.doc(postId).delete();
    } catch (e) {
      throw CacheException('Unable to delete post: $e');
    }
  }

  // ─── Audit Log ────────────────────────────────────────────────────

  Future<void> logAction({
    required String adminId,
    required String adminName,
    required String action,
    required String targetType,
    required String targetId,
    String? details,
  }) async {
    try {
      final ref = _auditLogs.doc();
      await ref.set(AdminAuditLogModel(
        entity: AdminAuditLogEntity(
          id: ref.id,
          adminId: adminId,
          adminName: adminName,
          action: action,
          targetType: targetType,
          targetId: targetId,
          timestamp: DateTime.now(),
          details: details,
        ),
      ).toJson());
    } catch (_) {
      // Audit logging is best-effort; do not fail the originating action.
    }
  }

  Future<List<AdminAuditLogEntity>> listAuditLogs({int limit = 50}) async {
    try {
      final snapshot = await _auditLogs
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map(AdminAuditLogModel.fromDoc)
          .map((m) => m.entity)
          .toList();
    } catch (e) {
      throw CacheException('Unable to list audit logs: $e');
    }
  }

  DateTime? _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
