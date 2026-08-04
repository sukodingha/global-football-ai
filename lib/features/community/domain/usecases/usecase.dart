import '../entities/community_post_entity.dart';

/// Base contract for community use cases.
abstract class UseCase<Type, Params> {
  Type call(Params params);
}

/// No parameters.
class NoParams {
  const NoParams();
}

/// Parameters for creating a post.
class CreatePostParams {
  const CreatePostParams({
    required this.userId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.analysisId,
    this.matchId,
    this.matchLabel,
  });

  final String userId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final String? analysisId;
  final int? matchId;
  final String? matchLabel;
}

/// Parameters for toggling a like.
class ToggleLikeParams {
  const ToggleLikeParams({required this.postId, required this.userId});
  final String postId;
  final String userId;
}

/// Parameters for adding a comment.
class AddCommentParams {
  const AddCommentParams({
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
  });

  final String postId;
  final String userId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
}

/// Parameters for fetching comments.
class CommentsParams {
  const CommentsParams(this.postId);
  final String postId;
}

/// Parameters for fetching badges.
class BadgesParams {
  const BadgesParams(this.userId);
  final String userId;
}
