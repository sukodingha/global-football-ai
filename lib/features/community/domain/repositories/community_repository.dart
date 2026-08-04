import '../../../core/errors/failures.dart';
import '../entities/comment_entity.dart';
import '../entities/community_post_entity.dart';
import '../entities/user_badge_entity.dart';

/// Result wrapper for community repository operations.
class CommunityResult<T> {
  const CommunityResult._(this.value, this.failure);
  const CommunityResult.success(T value) : this._(value, null);
  const CommunityResult.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}

/// Contract for the community wall repository.
///
/// Backed by Cloud Firestore for real-time posts, likes, comments, and
/// user profile badges.
abstract class CommunityRepository {
  /// Subscribes to the real-time community feed (newest first).
  Stream<List<CommunityPostEntity>> watchFeed({int limit = 50});

  /// Fetches a single snapshot of the feed.
  Future<List<CommunityPostEntity>> getFeed({int limit = 50});

  /// Creates a new post by [userId].
  Future<CommunityPostEntity> createPost({
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? analysisId,
    int? matchId,
    String? matchLabel,
  });

  /// Toggles a like on a post for [userId]. Returns the new like count and
  /// whether the post is now liked by the user.
  Future<(int, bool)> toggleLike({
    required String postId,
    required String userId,
  });

  /// Subscribes to real-time comments for a post.
  Stream<List<CommentEntity>> watchComments(String postId);

  /// Adds a comment to a post.
  Future<CommentEntity> addComment({
    required String postId,
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  });

  /// Fetches the badges for a user from their profile.
  Future<List<UserBadgeEntity>> getBadges(String userId);

  /// Fetches the badges of the current user (used for display).
  Future<List<UserBadgeEntity>> getMyBadges(String userId);
}
