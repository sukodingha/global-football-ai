import '../domain/entities/admin_audit_log_entity.dart';
import '../domain/entities/admin_competition_entity.dart';
import '../domain/entities/admin_prediction_entity.dart';
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

/// Loaded state with all admin-managed collections.
class AdminLoaded extends AdminState {
  const AdminLoaded({
    required this.users,
    this.competitions = const [],
    this.predictions = const [],
    this.posts = const [],
    this.auditLogs = const [],
    this.busy = false,
  });

  final List<AdminUserEntity> users;
  final List<AdminCompetitionEntity> competitions;
  final List<AdminPredictionEntity> predictions;
  final List<CommunityModerationView> posts;
  final List<AdminAuditLogEntity> auditLogs;
  final bool busy;

  /// Users with privilege/subscription info (for the subscriptions tab).
  List<AdminUserEntity> get subscriptionView => users;

  AdminLoaded copyWith({
    List<AdminUserEntity>? users,
    List<AdminCompetitionEntity>? competitions,
    List<AdminPredictionEntity>? predictions,
    List<CommunityModerationView>? posts,
    List<AdminAuditLogEntity>? auditLogs,
    bool? busy,
  }) {
    return AdminLoaded(
      users: users ?? this.users,
      competitions: competitions ?? this.competitions,
      predictions: predictions ?? this.predictions,
      posts: posts ?? this.posts,
      auditLogs: auditLogs ?? this.auditLogs,
      busy: busy ?? this.busy,
    );
  }
}

/// Error state with a user-safe message.
class AdminError extends AdminState {
  const AdminError({required this.message});
  final String message;
}
