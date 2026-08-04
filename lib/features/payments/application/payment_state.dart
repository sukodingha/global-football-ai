import '../domain/entities/subscription_entity.dart';
import '../domain/entities/transaction_entity.dart';

/// Immutable state for the Payments feature.
sealed class PaymentState {
  const PaymentState();
}

/// Initial state.
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Loading state for a payment operation.
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Loaded state with subscription + transaction history.
class PaymentLoaded extends PaymentState {
  const PaymentLoaded({
    required this.subscription,
    this.transactions = const [],
    this.processing = false,
    this.currentTransaction,
  });

  final SubscriptionEntity subscription;
  final List<TransactionEntity> transactions;
  final bool processing;

  /// The pending/last initialized transaction (with checkout URL).
  final TransactionEntity? currentTransaction;

  bool get isPremium => subscription.isActive;

  PaymentLoaded copyWith({
    SubscriptionEntity? subscription,
    List<TransactionEntity>? transactions,
    bool? processing,
    TransactionEntity? currentTransaction,
  }) {
    return PaymentLoaded(
      subscription: subscription ?? this.subscription,
      transactions: transactions ?? this.transactions,
      processing: processing ?? this.processing,
      currentTransaction: currentTransaction ?? this.currentTransaction,
    );
  }
}

/// Error state with a user-safe message.
class PaymentError extends PaymentState {
  const PaymentError({required this.message});
  final String message;
}
</content>

