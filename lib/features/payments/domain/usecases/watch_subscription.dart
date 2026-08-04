import '../entities/subscription_entity.dart';
import '../repositories/payment_repository.dart';
import 'usecase.dart';

/// Subscribes to real-time subscription updates.
class WatchSubscription
    implements UseCase<Stream<SubscriptionEntity>, SubscriptionParams> {
  const WatchSubscription(this._repository);
  final PaymentRepository _repository;

  @override
  Stream<SubscriptionEntity> call(SubscriptionParams params) {
    return _repository.watchSubscription(params.userId);
  }
}
