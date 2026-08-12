import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';
import 'usecase.dart';

/// Adds a comment to a post.
class AddComment implements UseCase<Future<CommentEntity>, AddCommentParams> {
  const AddComment(this._repository);
  final CommunityRepository _repository;

  @override
  Future<CommentEntity> call(AddCommentParams params) {
    return _repository.addComment(
      postId: params.postId,
      userId: params.userId,
      authorName: params.authorName,
      authorPhotoUrl: params.authorPhotoUrl,
      content: params.content,
    );
  }
}
