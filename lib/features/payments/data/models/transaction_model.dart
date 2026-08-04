import '../../domain/entities/transaction_entity.dart';

/// Serializes a [TransactionEntity] to/from JSON for Firestore persistence.
class TransactionModel {
  const TransactionModel({required this.entity});
  final TransactionEntity entity;

  Map<String, dynamic> toJson() {
    return {
      'reference': entity.reference,
      'userId': entity.userId,
      'planId': entity.planId,
      'planName': entity.planName,
      'amountKobo': entity.amountKobo,
      'currency': entity.currency,
      'status': entity.status.name,
      'createdAt': entity.createdAt.toIso8601String(),
      'accessCode': entity.accessCode,
      'authorizationUrl': entity.authorizationUrl,
      'verifiedAt': entity.verifiedAt?.toIso8601String(),
      'paidAt': entity.paidAt?.toIso8601String(),
    };
  }

  static TransactionEntity fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      reference: json['reference'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      amountKobo: (json['amountKobo'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'NGN',
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      accessCode: json['accessCode'] as String?,
      authorizationUrl: json['authorizationUrl'] as String?,
      verifiedAt:
          json['verifiedAt'] == null ? null : DateTime.tryParse(json['verifiedAt'] as String),
      paidAt: json['paidAt'] == null ? null : DateTime.tryParse(json['paidAt'] as String),
    );
  }

  static TransactionStatus _parseStatus(String value) {
    switch (value) {
      case 'success':
        return TransactionStatus.success;
      case 'failed':
        return TransactionStatus.failed;
      case 'abandoned':
        return TransactionStatus.abandoned;
      default:
        return TransactionStatus.pending;
    }
  }
}
