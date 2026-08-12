import '../entities/user_badge_entity.dart';
import '../repositories/community_repository.dart';
import 'usecase.dart';

/// Fetches the badges for a user.
class GetBadges implements UseCase<Future<List<UserBadgeEntity>>, BadgesParams> {
  const GetBadges(this._repository);
  final CommunityRepository _repository;

  @override
  Future<List<UserBadgeEntity>> call(BadgesParams params) {
    return _repository.getBadges(params.userId);
  }
}
