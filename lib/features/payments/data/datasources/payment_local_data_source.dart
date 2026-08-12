import 'package:cloud_firestore/cloud_firestore.dart';

import   '../../../../core/errors/exceptions.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Cloud Firestore-backed local data source for payments.
///
/// Persists transactions and the user's subscription profile, and applies
/// permission updates (e.g. premium badge) when a subscription is active.
class PaymentLocalDataSource {
  PaymentLocalDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> _transactions(String userId) =>
      _userDoc(userId).collection('transactions');

  // ─── Transactions ─────────────────────────────────────────────────

  Future<void> saveTransaction({
    required String userId,
    required TransactionEntity transaction,
  }) async {
    try {
      await _transactions(userId)
          .doc(transaction.reference)
          .set(TransactionModel(entity: transaction).toJson());
    } catch (e) {
      throw CacheException('Unable to save transaction: $e');
    }
  }

  Future<List<TransactionEntity>> getTransactions(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _transactions(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw CacheException('Unable to load transactions: $e');
    }
  }

  // ─── Subscription ─────────────────────────────────────────────────

  Future<SubscriptionEntity> getSubscription(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      return _subscriptionFromDoc(userId, doc.data());
    } catch (e) {
      throw CacheException('Unable to load subscription: $e');
    }
  }

  Stream<SubscriptionEntity> watchSubscription(String userId) {
    return _userDoc(userId).snapshots().map(
          (snap) => _subscriptionFromDoc(userId, snap.data()),
        );
  }

  /// Applies a premium subscription and updates the user's profile badges.
  Future<void> applyPremium({
    required String userId,
    required TransactionEntity transaction,
    required String planId,
    required String planName,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      await saveTransaction(userId: userId, transaction: transaction);

      final doc = _userDoc(userId);
      await doc.set({
        'premium': true,
        'premiumPlan': planId,
        'premiumPlanName': planName,
        'premiumStart': Timestamp.fromDate(start),
        'premiumEnd': Timestamp.fromDate(end),
        'badges': FieldValue.arrayUnion(['premium_member']),
      }, SetOptions(merge: true));
    } catch (e) {
      throw CacheException('Unable to apply premium: $e');
    }
  }

  /// Records a donation and adds a contributor badge.
  Future<void> recordDonation({
    required String userId,
    required TransactionEntity transaction,
  }) async {
    try {
      await saveTransaction(userId: userId, transaction: transaction);
      await _userDoc(userId).update({
        'donationsTotalKobo': FieldValue.increment(transaction.amountKobo),
        'badges': FieldValue.arrayUnion(['contributor']),
      });
    } catch (e) {
      throw CacheException('Unable to record donation: $e');
    }
  }

  SubscriptionEntity _subscriptionFromDoc(
    String userId,
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      return SubscriptionEntity(userId: userId);
    }
    return SubscriptionEntity(
      userId: userId,
      planId: data['premiumPlan'] as String?,
      planName: data['premiumPlanName'] as String?,
      isPremium: data['premium'] as bool? ?? false,
      currentPeriodStart: _timestamp(data['premiumStart']),
      currentPeriodEnd: _timestamp(data['premiumEnd']),
      autoRenew: data['autoRenew'] as bool? ?? true,
      donationsTotalKobo: (data['donationsTotalKobo'] as num?)?.toInt() ?? 0,
    );
  }

  DateTime? _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
