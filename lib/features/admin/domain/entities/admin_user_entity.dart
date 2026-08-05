import 'package:equatable/equatable.dart';

/// Roles available in the RBAC system.
enum UserRole {
  user,
  moderator,
  admin,
  superAdmin;

  /// Whether this role can access the admin dashboard.
  bool get isAdmin => this == admin || this == superAdmin;

  /// Whether this role can moderate content.
  bool get canModerate => this != user;

  String get label => switch (this) {
        UserRole.user => 'User',
        UserRole.moderator => 'Moderator',
        UserRole.admin => 'Admin',
        UserRole.superAdmin => 'Super Admin',
      };

  static UserRole fromString(String? value) {
    switch (value) {
      case 'moderator':
        return UserRole.moderator;
      case 'admin':
        return UserRole.admin;
      case 'superAdmin':
        return UserRole.superAdmin;
      default:
        return UserRole.user;
    }
  }
}

/// Admin-facing view of a user account.
class AdminUserEntity extends Equatable {
  const AdminUserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.user,
    this.isBanned = false,
    this.banReason,
    this.isPremium = false,
    this.premiumPlanName,
    this.premiumEnd,
    this.donationsTotalKobo = 0,
    this.badges = const [],
    this.createdAt,
    this.lastActiveAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final bool isBanned;
  final String? banReason;
  final bool isPremium;
  final String? premiumPlanName;
  final DateTime? premiumEnd;
  final int donationsTotalKobo;
  final List<String> badges;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  /// Whether this user's premium subscription is currently active.
  bool get isPremiumActive {
    if (!isPremium) return false;
    final end = premiumEnd;
    if (end == null) return true;
    return end.isAfter(DateTime.now());
  }

  double get donationsTotalNaira => donationsTotalKobo / 100;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        role,
        isBanned,
        banReason,
        isPremium,
        premiumPlanName,
        premiumEnd,
        donationsTotalKobo,
        badges,
        createdAt,
        lastActiveAt,
      ];

  AdminUserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    bool? isBanned,
    String? banReason,
    bool? isPremium,
    String? premiumPlanName,
    DateTime? premiumEnd,
    int? donationsTotalKobo,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return AdminUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      isPremium: isPremium ?? this.isPremium,
      premiumPlanName: premiumPlanName ?? this.premiumPlanName,
      premiumEnd: premiumEnd ?? this.premiumEnd,
      donationsTotalKobo: donationsTotalKobo ?? this.donationsTotalKobo,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
