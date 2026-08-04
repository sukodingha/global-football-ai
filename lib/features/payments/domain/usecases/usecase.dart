import '../entities/payment_plan_entity.dart';

/// Base contract for payment use cases.
abstract class UseCase<Type, Params> {
  Type call(Params params);
}

/// No parameters.
class NoParams {
  const NoParams();
}

/// Parameters for initializing a transaction.
class InitTransactionParams {
  const InitTransactionParams({
    required this.userId,
    required this.plan,
    this.email,
  });

  final String userId;
  final PaymentPlanEntity plan;
  final String? email;
}

/// Parameters for verifying a transaction.
class VerifyTransactionParams {
  const VerifyTransactionParams({
    required this.userId,
    required this.reference,
  });

  final String userId;
  final String reference;
}

/// Parameters for fetching a subscription.
class SubscriptionParams {
  const SubscriptionParams(this.userId);
  final String userId;
}

/// Parameters for fetching transaction history.
class TransactionHistoryParams {
  const TransactionHistoryParams({required this.userId, this.limit = 50});
  final String userId;
  final int limit;
}
