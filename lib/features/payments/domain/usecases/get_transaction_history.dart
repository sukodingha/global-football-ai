import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';
import 'usecase.dart';

/// Fetches the user's transaction history.
class GetTransactionHistory
    implements UseCase<Future<List<TransactionEntity>>, TransactionHistoryParams> {
  const GetTransactionHistory(this._repository);
  final PaymentRepository _repository;

  @override
  Future<List<TransactionEntity>> call(TransactionHistoryParams params) {
    return _repository.getTransactionHistory(
      userId: params.userId,
      limit: params.limit,
    );
  }
}
