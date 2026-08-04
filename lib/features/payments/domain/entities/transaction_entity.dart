import 'package:equatable/equatable.dart';

import 'payment_plan_entity.dart';

/// Status of a payment transaction.
enum TransactionStatus { pending, success, failed, abandoned }

/// A Paystack transaction (donation or subscription purchase).
class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.reference,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.amountKobo,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.accessCode,
    this.authorizationUrl,
    this.verifiedAt,
    this.paidAt,
  });

  final String reference;
  final String userId;
  final String planId;
  final String planName;
  final int amountKobo;
  final String currency;
  final TransactionStatus status;
  final DateTime createdAt;

  /// Paystack checkout access code (from initialize).
  final String? accessCode;

  /// Paystack hosted checkout URL.
  final String? authorizationUrl;

  final DateTime? verifiedAt;
  final DateTime? paidAt;

  double get amountNaira => amountKobo / 100;

  bool get isSuccessful => status == TransactionStatus.success;

  @override
  List<Object?> get props => [
        reference,
        userId,
        planId,
        planName,
        amountKobo,
        currency,
        status,
        createdAt,
        accessCode,
        authorizationUrl,
        verifiedAt,
        paidAt,
      ];
}

/// Immutable request to initialize a Paystack transaction.
class InitTransactionRequest {
  const InitTransactionRequest({
    required this.userId,
    required this.plan,
    this.email,
    this.metadata,
  });

  final String userId;
  final PaymentPlanEntity plan;
  final String? email;
  final Map<String, dynamic>? metadata;
}
