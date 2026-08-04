import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../data/dependency_injection.dart';
import '../domain/entities/subscription_entity.dart';
import '../domain/entities/transaction_entity.dart';
import 'payment_notifier.dart';
import 'payment_state.dart';

/// Provider for the [PaymentNotifier] controller.
final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(
    repository: ref.watch(paymentRepositoryProvider),
    initializeTransaction: ref.watch(initializeTransactionUseCaseProvider),
    verifyTransaction: ref.watch(verifyTransactionUseCaseProvider),
    getSubscription: ref.watch(getSubscriptionUseCaseProvider),
    watchSubscription: ref.watch(watchSubscriptionUseCaseProvider),
    getTransactionHistory: ref.watch(getTransactionHistoryUseCaseProvider),
  );
});

/// Selector for the current subscription profile.
final subscriptionProvider = Provider<SubscriptionEntity?>((ref) {
  final state = ref.watch(paymentNotifierProvider);
  if (state is PaymentLoaded) return state.subscription;
  return null;
});

/// Selector for whether the user has an active premium subscription.
final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionProvider);
  return sub?.isActive ?? false;
});

/// Selector for the user's transaction history.
final transactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final state = ref.watch(paymentNotifierProvider);
  if (state is PaymentLoaded) return state.transactions;
  return const [];
});

/// Selector for whether a payment operation is in progress.
final paymentProcessingProvider = Provider<bool>((ref) {
  final state = ref.watch(paymentNotifierProvider);
  return state is PaymentLoaded && state.processing;
});

/// Selector for the last initialized transaction (checkout URL).
final currentTransactionProvider = Provider<TransactionEntity?>((ref) {
  final state = ref.watch(paymentNotifierProvider);
  if (state is PaymentLoaded) return state.currentTransaction;
  return null;
});

