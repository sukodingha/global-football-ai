import '../entities/subscription_entity.dart';
import '../repositories/payment_repository.dart';
import 'usecase.dart';

/// Fetches the user's current subscription profile.
class GetSubscription implements UseCase<Future<SubscriptionEntity>, SubscriptionParams> {
  const GetSubscription(this._repository);
  final PaymentRepository _repository;

  @override
  Future<SubscriptionEntity> call(SubscriptionParams params) {
    return _repository.getSubscription(params.userId);
  }
}
