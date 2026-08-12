import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../domain/entities/payment_plan_entity.dart';
import '../domain/entities/subscription_entity.dart';
import '../domain/entities/transaction_entity.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/usecases/get_subscription.dart';
import '../domain/usecases/get_transaction_history.dart';
import '../domain/usecases/initialize_transaction.dart';
import '../domain/usecases/usecase.dart';
import '../domain/usecases/verify_transaction.dart';
import '../domain/usecases/watch_subscription.dart';
import 'payment_state.dart';

/// Riverpod controller for the Payments feature.
///
/// Manages subscription state, Paystack transaction initialization,
/// post-checkout verification, transaction history and real-time
/// subscription updates.
class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier({
    required PaymentRepository repository,
    required InitializeTransaction initializeTransaction,
    required VerifyTransaction verifyTransaction,
    required GetSubscription getSubscription,
    required WatchSubscription watchSubscription,
    required GetTransactionHistory getTransactionHistory,
  })  : _repository = repository,
        _initializeTransaction = initializeTransaction,
        _verifyTransaction = verifyTransaction,
        _getSubscription = getSubscription,
        _watchSubscription = watchSubscription,
        _getTransactionHistory = getTransactionHistory,
        super(const PaymentInitial());

  final PaymentRepository _repository;
  final InitializeTransaction _initializeTransaction;
  final VerifyTransaction _verifyTransaction;
  final GetSubscription _getSubscription;
  final WatchSubscription _watchSubscription;
  final GetTransactionHistory _getTransactionHistory;

  StreamSubscription<SubscriptionEntity>? _subscriptionSub;

  /// Loads the subscription profile and transaction history for [userId].
  Future<void> loadProfile(String userId) async {
    state = const PaymentLoading();
    try {
      final subscription = await _getSubscription(SubscriptionParams(userId));
      final transactions = await _getTransactionHistory(
        TransactionHistoryParams(userId: userId),
      );
      state = PaymentLoaded(
        subscription: subscription,
        transactions: transactions,
      );
      _startSubWatch(userId);
    } on Failure catch (f) {
      state = PaymentError(message: f.message);
    } catch (_) {
      state = const PaymentError(
        message: 'Unable to load payment profile. Please try again.',
      );
    }
  }

  void _startSubWatch(String userId) {
    _subscriptionSub?.cancel();
    _subscriptionSub = _watchSubscription(SubscriptionParams(userId)).listen(
      (subscription) {
        final s = state;
        if (s is PaymentLoaded) {
          state = s.copyWith(subscription: subscription);
        }
      },
      onError: (Object _) {
        // Keep last known state; subscription watch is best-effort.
      },
    );
  }

  /// Initializes a transaction for [plan] and returns the entity with the
  /// Paystack hosted checkout URL.
  Future<TransactionEntity?> initialize({
    required UserEntity user,
    required PaymentPlanEntity plan,
  }) async {
    final s = state;
    if (s is PaymentLoaded) {
      state = s.copyWith(processing: true);
    } else {
      state = const PaymentLoading();
    }
    try {
      final tx = await _initializeTransaction(
        InitTransactionParams(
          userId: user.id,
          plan: plan,
          email: user.email,
        ),
      );
      final loaded = _asLoaded;
      if (loaded != null) {
        state = loaded.copyWith(
          processing: false,
          currentTransaction: tx,
          transactions: [tx, ...loaded.transactions],
        );
      }
      return tx;
    } on Failure catch (f) {
      _markError(f.message);
    } catch (_) {
      _markError('Unable to initialize payment. Please try again.');
    }
    return null;
  }

  /// Verifies a transaction by [reference] after returning from checkout.
  Future<TransactionEntity?> verify(String userId, String reference) async {
    final s = state;
    if (s is PaymentLoaded) {
      state = s.copyWith(processing: true);
    }
    try {
      final tx = await _verifyTransaction(
        VerifyTransactionParams(userId: userId, reference: reference),
      );
      final loaded = _asLoaded;
      if (loaded != null) {
        final history = await _getTransactionHistory(
          TransactionHistoryParams(userId: userId),
        );
        state = loaded.copyWith(
          processing: false,
          transactions: history,
          currentTransaction: tx,
        );
      }
      return tx;
    } on Failure catch (f) {
      _markError(f.message);
    } catch (_) {
      _markError('Unable to verify payment. Please try again.');
    }
    return null;
  }

  /// Clears any error and returns to the loaded state.
  void clearError() {
    final loaded = _asLoaded;
    if (loaded != null && state is PaymentError) {
      state = loaded.copyWith(processing: false);
    }
  }

  PaymentLoaded? get _asLoaded {
    final s = state;
    if (s is PaymentLoaded) return s;
    return null;
  }

  void _markError(String message) {
    final loaded = _asLoaded;
    if (loaded != null) {
      state = PaymentError(message: message);
    } else {
      state = PaymentError(message: message);
    }
  }

  @override
  void dispose() {
    _subscriptionSub?.cancel();
    super.dispose();
  }
}

