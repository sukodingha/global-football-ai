import '../../domain/entities/admin_user_entity.dart';

/// Role constants used for RBAC and Firestore security rules.
abstract class AdminRoles {
  AdminRoles._();

  static const String user = 'user';
  static const String moderator = 'moderator';
  static const String admin = 'admin';
  static const String superAdmin = 'superAdmin';

  static const List<String> all = [
    user,
    moderator,
    admin,
    superAdmin,
  ];

  /// The Firestore field that stores the user's role.
  static const String roleField = 'role';

  /// Whether a role string represents an admin.
  static bool isAdminRole(String role) => role == admin || role == superAdmin;

  /// Whether a role string can moderate content.
  static bool canModerateRole(String role) => role != user;

  /// Maps a [UserRole] enum to its string constant.
  static String toStorage(UserRole role) => switch (role) {
        UserRole.user => user,
        UserRole.moderator => moderator,
        UserRole.admin => admin,
        UserRole.superAdmin => superAdmin,
      };
}
