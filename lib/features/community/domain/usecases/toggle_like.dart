import '../repositories/community_repository.dart';
import 'usecase.dart';

/// Toggles a like on a post.
class ToggleLike implements UseCase<Future<(int, bool)>, ToggleLikeParams> {
  const ToggleLike(this._repository);
  final CommunityRepository _repository;

  @override
  Future<(int, bool)> call(ToggleLikeParams params) {
    return _repository.toggleLike(
      postId: params.postId,
      userId: params.userId,
    );
  }
}
