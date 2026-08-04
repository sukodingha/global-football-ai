import 'package:equatable/equatable.dart';

/// The user's current subscription/permission state.
class SubscriptionEntity extends Equatable {
  const SubscriptionEntity({
    required this.userId,
    this.planId,
    this.planName,
    this.isPremium = false,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.autoRenew = true,
    this.donationsTotalKobo = 0,
  });

  final String userId;
  final String? planId;
  final String? planName;
  final bool isPremium;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool autoRenew;

  /// Total lifetime donations in kobo.
  final int donationsTotalKobo;

  /// Total donations in Naira.
  double get donationsTotalNaira => donationsTotalKobo / 100;

  /// Whether the premium subscription is currently active.
  bool get isActive {
    if (!isPremium) return false;
    final end = currentPeriodEnd;
    if (end == null) return true;
    return end.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [
        userId,
        planId,
        planName,
        isPremium,
        currentPeriodStart,
        currentPeriodEnd,
        autoRenew,
        donationsTotalKobo,
      ];
}
