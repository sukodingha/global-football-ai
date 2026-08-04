import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';
import 'usecase.dart';

/// Initializes a Paystack transaction for a plan.
class InitializeTransaction
    implements UseCase<TransactionEntity, InitTransactionParams> {
  const InitializeTransaction(this._repository);
  final PaymentRepository _repository;

  @override
  Future<TransactionEntity> call(InitTransactionParams params) {
    return _repository.initializeTransaction(
      userId: params.userId,
      plan: params.plan,
      email: params.email,
    );
  }
}
