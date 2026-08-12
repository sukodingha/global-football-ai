import   '../../../../core/errors/exceptions.dart';
import   '../../../../core/errors/failures.dart';
import '../../domain/entities/payment_plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_data_source.dart';
import '../datasources/paystack_api_data_source.dart';

/// Implementation of [PaymentRepository].
///
/// Uses Paystack for initialization/verification and Firestore for
/// transaction history and subscription/profile permission updates.
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({
    required PaystackApiDataSource apiDataSource,
    required PaymentLocalDataSource localDataSource,
  })  : _apiDataSource = apiDataSource,
        _localDataSource = localDataSource;

  final PaystackApiDataSource _apiDataSource;
  final PaymentLocalDataSource _localDataSource;

  Future<T> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  Failure _mapException(Exception e) {
    final message = e.toString();
    if (e is NetworkException || message.contains('network')) {
      return Failure.networkFailure(message: message);
    }
    if (e is AuthenticationException || message.contains('key')) {
      return Failure.serverFailure(message: message);
    }
    if (e is CacheException || message.contains('cache')) {
      return Failure.cacheFailure(message: message);
    }
    if (e is ServerException || message.contains('server') ||
        message.contains('Paystack') || message.contains('paystack')) {
      return Failure.serverFailure(message: message);
    }
    return Failure.unknown(message: message);
  }

  @override
  Future<TransactionEntity> initializeTransaction({
    required String userId,
    required PaymentPlanEntity plan,
    String? email,
  }) {
    return _safeCall(() => _apiDataSource.initializeTransaction(
          userId: userId,
          plan: plan,
          email: email,
        ));
  }

  @override
  Future<TransactionEntity> verifyTransaction({
    required String userId,
    required String reference,
  }) async {
    final result = await _safeCall(() async {
      // Look up the stored transaction to get plan/amount details.
      final history = await _localDataSource.getTransactions(userId);
      final stored = history.where((t) => t.reference == reference).firstOrNull;

      final base = stored ??
          TransactionEntity(
            reference: reference,
            userId: userId,
            planId: 'unknown',
            planName: 'Donation',
            amountKobo: 0,
            currency: 'NGN',
            status: TransactionStatus.pending,
            createdAt: DateTime.now(),
          );

      return _apiDataSource.verifyTransaction(
        userId: userId,
        reference: reference,
        planId: base.planId,
        planName: base.planName,
        amountKobo: base.amountKobo,
        currency: base.currency,
      );
    });

    // Apply permission updates on success.
    if (result.isSuccessful) {
      await _safeCall(() async {
        if (result.planId == 'premium_monthly' || result.planId == 'premium_yearly') {
          final now = DateTime.now();
          final end = result.planId == 'premium_yearly'
              ? now.add(const Duration(days: 365))
              : now.add(const Duration(days: 30));
          await _localDataSource.applyPremium(
            userId: userId,
            transaction: result,
            planId: result.planId,
            planName: result.planName,
            start: now,
            end: end,
          );
        } else {
          await _localDataSource.recordDonation(
            userId: userId,
            transaction: result,
          );
        }
      });
    }

    return result;
  }

  @override
  Future<SubscriptionEntity> getSubscription(String userId) {
    return _safeCall(() => _localDataSource.getSubscription(userId));
  }

  @override
  Stream<SubscriptionEntity> watchSubscription(String userId) {
    return _localDataSource.watchSubscription(userId);
  }

  @override
  Future<List<TransactionEntity>> getTransactionHistory({
    required String userId,
    int limit = 50,
  }) {
    return _safeCall(() => _localDataSource.getTransactions(userId, limit: limit));
  }
}
