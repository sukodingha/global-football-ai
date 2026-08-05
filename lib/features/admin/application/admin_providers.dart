import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/dependency_injection.dart';
import '../data/roles/admin_roles.dart';
import '../domain/entities/admin_analytics_entity.dart';
import '../domain/entities/admin_competition_entity.dart';
import '../domain/entities/admin_prediction_entity.dart';
import '../domain/entities/admin_revenue_entity.dart';
import '../domain/entities/admin_user_entity.dart';
import '../domain/repositories/admin_repository.dart';
import 'admin_notifier.dart';
import 'admin_state.dart';

/// Provider for the [AdminNotifier] controller.
final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminNotifier(repository: repository);
});

/// Selector for the admin-loaded users.
final adminUsersProvider = Provider<List<AdminUserEntity>>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.users;
  return const [];
});

/// Selector for competitions.
final adminCompetitionsProvider = Provider<List<AdminCompetitionEntity>>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.competitions;
  return const [];
});

/// Selector for predictions.
final adminPredictionsProvider = Provider<List<AdminPredictionEntity>>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.predictions;
  return const [];
});

/// Selector for community posts (moderation).
final adminPostsProvider = Provider<List<CommunityModerationView>>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.posts;
  return const [];
});

/// Selector for audit logs.
final adminAuditLogsProvider = Provider<List<dynamic>>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.auditLogs;
  return const [];
});

/// Selector for the analytics snapshot.
final adminAnalyticsProvider = Provider<AdminAnalyticsEntity?>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.analytics;
  return null;
});

/// Selector for the revenue snapshot.
final adminRevenueProvider = Provider<AdminRevenueEntity?>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.revenue;
  return null;
});

/// Selector for the centralized moderation log.
final adminModerationLogsProvider =
    Provider<List<ModerationLogEntity>>((ref) {
  final state = ref.watch(adminNotifierProvider);
  if (state is AdminLoaded) return state.moderationLogs;
  return const [];
});

/// Whether the admin dashboard is busy with a mutation.
final adminBusyProvider = Provider<bool>((ref) {
  final state = ref.watch(adminNotifierProvider);
  return state is AdminLoaded && state.busy;
});

/// The current user's role string, read in real time from their Firestore
/// `users/{uid}` profile document. Falls back to `AdminRoles.user` when the
/// document is missing or the user is not authenticated.
final currentUserRoleProvider = StreamProvider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(AdminRoles.user);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .snapshots()
      .map((snap) {
    return snap.data()?[AdminRoles.roleField] as String? ?? AdminRoles.user;
  });
});

/// Whether the currently authenticated user is an admin/mod (RBAC guard).
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider).value;
  if (role == null) return false;
  return AdminRoles.isAdminRole(role);
});

/// Whether the currently authenticated user can moderate content (RBAC guard).
final canModerateProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider).value;
  if (role == null) return false;
  return AdminRoles.canModerateRole(role);
});
