import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';
import 'usecase.dart';

/// Subscribes to real-time comments for a post.
class WatchComments
    implements UseCase<Stream<List<CommentEntity>>, CommentsParams> {
  const WatchComments(this._repository);
  final CommunityRepository _repository;

  @override
  Stream<List<CommentEntity>> call(CommentsParams params) {
    return _repository.watchComments(params.postId);
  }
}
