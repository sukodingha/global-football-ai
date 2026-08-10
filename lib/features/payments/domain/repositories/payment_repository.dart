import '../../../../core/errors/failures.dart';
import '../entities/payment_plan_entity.dart';
import '../entities/subscription_entity.dart';
import '../entities/transaction_entity.dart';

/// Result wrapper for payment repository operations.
class PaymentResult<T> {
  const PaymentResult._(this.value, this.failure);
  const PaymentResult.success(T value) : this._(value, null);
  const PaymentResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}

/// Contract for the payments repository.
///
/// Combines Paystack REST initialization/verification with Firestore
/// persistence of transactions and the user's subscription profile.
abstract class PaymentRepository {
  /// Initializes a Paystack transaction and returns a pending transaction
  /// with an authorization URL for hosted checkout.
  Future<TransactionEntity> initializeTransaction({
    required String userId,
    required PaymentPlanEntity plan,
    String? email,
  });

  /// Verifies a transaction by its reference and marks it success/failed.
  Future<TransactionEntity> verifyTransaction({
    required String userId,
    required String reference,
  });

  /// Returns the user's current subscription profile.
  Future<SubscriptionEntity> getSubscription(String userId);

  /// Watches the user's subscription profile for real-time updates.
  Stream<SubscriptionEntity> watchSubscription(String userId);

  /// Returns the user's transaction history (newest first).
  Future<List<TransactionEntity>> getTransactionHistory({
    required String userId,
    int limit = 50,
  });
}
