import '../entities/community_post_entity.dart';
import '../repositories/community_repository.dart';
import 'usecase.dart';

/// Creates a new community post.
class CreatePost implements UseCase<Future<CommunityPostEntity>, CreatePostParams> {
  const CreatePost(this._repository);
  final CommunityRepository _repository;

  @override
  Future<CommunityPostEntity> call(CreatePostParams params) {
    return _repository.createPost(
      userId: params.userId,
      authorName: params.authorName,
      authorPhotoUrl: params.authorPhotoUrl,
      content: params.content,
      analysisId: params.analysisId,
      matchId: params.matchId,
      matchLabel: params.matchLabel,
    );
  }
}
