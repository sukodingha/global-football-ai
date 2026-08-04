import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';
import 'usecase.dart';

/// Verifies a transaction by reference and applies permission updates.
class VerifyTransaction
    implements UseCase<TransactionEntity, VerifyTransactionParams> {
  const VerifyTransaction(this._repository);
  final PaymentRepository _repository;

  @override
  Future<TransactionEntity> call(VerifyTransactionParams params) {
    return _repository.verifyTransaction(
      userId: params.userId,
      reference: params.reference,
    );
  }
}
