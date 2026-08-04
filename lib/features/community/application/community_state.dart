import '../domain/entities/comment_entity.dart';
import '../domain/entities/community_post_entity.dart';
import '../domain/entities/user_badge_entity.dart';

/// Immutable state for the community feature.
sealed class CommunityState {
  const CommunityState();
}

/// Initial state.
class CommunityInitial extends CommunityState {
  const CommunityInitial();
}

/// Loading state.
class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

/// Loaded state with the real-time feed and badges.
class CommunityLoaded extends CommunityState {
  const CommunityLoaded({
    required this.posts,
    this.comments = const {},
    this.myBadges = const [],
    this.posting = false,
    this.commentingPostId,
    this.lastUpdated,
  });

  final List<CommunityPostEntity> posts;

  /// PostId -> live comments.
  final Map<String, List<CommentEntity>> comments;

  /// The current user's badges.
  final List<UserBadgeEntity> myBadges;

  final bool posting;
  final String? commentingPostId;
  final DateTime? lastUpdated;

  List<CommentEntity> commentsFor(String postId) =>
      comments[postId] ?? const [];

  CommunityLoaded copyWith({
    List<CommunityPostEntity>? posts,
    Map<String, List<CommentEntity>>? comments,
    List<UserBadgeEntity>? myBadges,
    bool? posting,
    String? commentingPostId,
    DateTime? lastUpdated,
  }) {
    return CommunityLoaded(
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      myBadges: myBadges ?? this.myBadges,
      posting: posting ?? this.posting,
      commentingPostId: commentingPostId ?? this.commentingPostId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Error state with a user-safe message.
class CommunityError extends CommunityState {
  const CommunityError({required this.message});
  final String message;
}
