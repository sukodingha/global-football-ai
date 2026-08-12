import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/payment_repository.dart';
import '../domain/usecases/get_subscription.dart';
import '../domain/usecases/get_transaction_history.dart';
import '../domain/usecases/initialize_transaction.dart';
import '../domain/usecases/verify_transaction.dart';
import '../domain/usecases/watch_subscription.dart';
import './datasources/payment_local_data_source.dart';
import './datasources/paystack_api_data_source.dart';
import './repositories/payment_repository_impl.dart';

/// Paystack REST API data source.
final paystackApiDataSourceProvider = Provider<PaystackApiDataSource>((ref) {
  return PaystackApiDataSource();
});

/// Firestore-backed payment local data source (transactions + subscription).
final paymentLocalDataSourceProvider = Provider<PaymentLocalDataSource>((ref) {
  return PaymentLocalDataSource();
});

/// Payment repository combining Paystack with Firestore persistence.
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    apiDataSource: ref.watch(paystackApiDataSourceProvider),
    localDataSource: ref.watch(paymentLocalDataSourceProvider),
  );
});

/// Use cases.
final initializeTransactionUseCaseProvider =
    Provider<InitializeTransaction>((ref) {
  return InitializeTransaction(ref.watch(paymentRepositoryProvider));
});

final verifyTransactionUseCaseProvider = Provider<VerifyTransaction>((ref) {
  return VerifyTransaction(ref.watch(paymentRepositoryProvider));
});

final getSubscriptionUseCaseProvider = Provider<GetSubscription>((ref) {
  return GetSubscription(ref.watch(paymentRepositoryProvider));
});

final watchSubscriptionUseCaseProvider = Provider<WatchSubscription>((ref) {
  return WatchSubscription(ref.watch(paymentRepositoryProvider));
});

final getTransactionHistoryUseCaseProvider =
    Provider<GetTransactionHistory>((ref) {
  return GetTransactionHistory(ref.watch(paymentRepositoryProvider));
});

