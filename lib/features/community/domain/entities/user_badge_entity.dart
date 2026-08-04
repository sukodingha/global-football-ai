import 'package:equatable/equatable.dart';

/// A user profile badge (e.g. Early Adopter, Top Analyst, Premium Member).
class UserBadgeEntity extends Equatable {
  const UserBadgeEntity({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
  });

  final String id;
  final String name;

  /// Material icon name for display.
  final String icon;
  final String? description;

  @override
  List<Object?> get props => [id, name, icon, description];
}
