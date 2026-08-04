import '../entities/community_post_entity.dart';
import '../repositories/community_repository.dart';
import 'usecase.dart';

/// Subscribes to the real-time community feed.
class WatchFeed implements UseCase<Stream<List<CommunityPostEntity>>, NoParams> {
  const WatchFeed(this._repository);
  final CommunityRepository _repository;

  @override
  Stream<List<CommunityPostEntity>> call(NoParams params) {
    return _repository.watchFeed();
  }
}
