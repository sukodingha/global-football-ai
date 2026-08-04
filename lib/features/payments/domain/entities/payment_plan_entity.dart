import 'package:equatable/equatable.dart';

/// A purchasable plan (Premium membership or donation).
class PaymentPlanEntity extends Equatable {
  const PaymentPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.amountKobo,
    required this.currency,
    this.interval,
    this.features = const [],
    this.isPremium = false,
  });

  final String id;
  final String name;
  final String description;

  /// Amount in kobo (smallest unit of NGN).
  final int amountKobo;
  final String currency;

  /// Billing interval for subscriptions ('monthly' | 'yearly') or null for
  /// one-time donation.
  final String? interval;

  /// Feature list shown on the premium upsell.
  final List<String> features;

  /// Whether this plan grants premium membership.
  final bool isPremium;

  /// Amount in Naira (readable form).
  double get amountNaira => amountKobo / 100;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        amountKobo,
        currency,
        interval,
        features,
        isPremium,
      ];
}

/// Available premium plans.
class PremiumPlans {
  PremiumPlans._();

  static const PaymentPlanEntity monthly = PaymentPlanEntity(
    id: 'premium_monthly',
    name: 'Premium Monthly',
    description: 'Unlock all AI predictions, advanced analytics and ad-free experience.',
    amountKobo: 250000, // NGN 2,500
    currency: 'NGN',
    interval: 'monthly',
    isPremium: true,
    features: [
      'Unlimited AI predictions',
      'Advanced analytics dashboard',
      'Correct score + player props',
      'Ad-free experience',
      'Priority community support',
    ],
  );

  static const PaymentPlanEntity yearly = PaymentPlanEntity(
    id: 'premium_yearly',
    name: 'Premium Yearly',
    description: 'Two months free. Everything in monthly, billed annually.',
    amountKobo: 2500000, // NGN 25,000
    currency: 'NGN',
    interval: 'yearly',
    isPremium: true,
    features: [
      'Unlimited AI predictions',
      'Advanced analytics dashboard',
      'Correct score + player props',
      'Ad-free experience',
      '16% off vs monthly billing',
    ],
  );

  static const List<PaymentPlanEntity> all = [monthly, yearly];
}
