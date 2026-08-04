import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/comment_entity.dart';
import '../domain/entities/community_post_entity.dart';
import '../domain/entities/user_badge_entity.dart';
import '../domain/repositories/community_repository.dart';
import 'community_state.dart';

/// Riverpod controller for the community wall.
///
/// Subscribes to the real-time feed and comment streams, and drives
/// optimistic like toggling.
class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier({required CommunityRepository repository})
      : _repository = repository,
        super(const CommunityInitial());

  final CommunityRepository _repository;

  StreamSubscription<List<CommunityPostEntity>>? _feedSubscription;
  final Map<String, StreamSubscription<List<CommentEntity>>> _commentSubs = {};

  /// Starts listening to the real-time feed and loads the current user's
  /// badges.
  Future<void> start({
    required String userId,
    required List<UserBadgeEntity> myBadges,
  }) async {
    state = const CommunityLoading();
    _feedSubscription?.cancel();
    _feedSubscription = _repository.watchFeed().listen(
      (posts) {
        _updatePosts(posts);
      },
      onError: (Object error) {
        if (error is Failure) {
          state = CommunityError(message: error.message);
        } else {
          state = const CommunityError(
            message: 'Unable to load the community feed.',
          );
        }
      },
    );

    // Load initial snapshot + badges.
    try {
      final posts = await _repository.getFeed();
      _updatePosts(posts, badges: myBadges);
    } on Failure catch (f) {
      state = CommunityError(message: f.message);
    } catch (_) {
      state = const CommunityError(
        message: 'Unable to load the community feed.',
      );
    }
  }

  void _updatePosts(List<CommunityPostEntity> posts, {List<UserBadgeEntity>? badges}) {
    final current = state;
    if (current is CommunityLoaded) {
      state = current.copyWith(
        posts: posts,
        myBadges: badges ?? current.myBadges,
        lastUpdated: DateTime.now(),
      );
    } else {
      state = CommunityLoaded(
        posts: posts,
        myBadges: badges ?? const [],
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Creates a new post.
  Future<void> createPost({
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? analysisId,
    int? matchId,
    String? matchLabel,
  }) async {
    if (state is! CommunityLoaded) return;
    state = (state as CommunityLoaded).copyWith(posting: true);
    try {
      await _repository.createPost(
        userId: userId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
        analysisId: analysisId,
        matchId: matchId,
        matchLabel: matchLabel,
      );
      // The feed subscription picks up the new post automatically.
      state = (state as CommunityLoaded).copyWith(posting: false);
    } on Failure catch (f) {
      state = (state as CommunityLoaded).copyWith(posting: false);
      throw f;
    } catch (_) {
      state = (state as CommunityLoaded).copyWith(posting: false);
      throw const UnknownFailure();
    }
  }

  /// Toggles a like on a post (optimistic).
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    if (state is! CommunityLoaded) return;
    final loaded = state as CommunityLoaded;

    // Optimistic update.
    final posts = loaded.posts
        .map(
          (p) => p.id == postId
              ? p.copyWith(
                  likeCount: p.likedByMe ? p.likeCount - 1 : p.likeCount + 1,
                  likedByMe: !p.likedByMe,
                )
              : p,
        )
        .toList();
    state = loaded.copyWith(posts: posts);

    try {
      await _repository.toggleLike(postId: postId, userId: userId);
    } on Failure {
      // Revert optimistic update on failure.
      final reverted = posts
          .map(
            (p) => p.id == postId
                ? p.copyWith(
                    likeCount: p.likedByMe ? p.likeCount - 1 : p.likeCount + 1,
                    likedByMe: !p.likedByMe,
                  )
                : p,
          )
          .toList();
      if (state is CommunityLoaded) {
        state = (state as CommunityLoaded).copyWith(posts: reverted);
      }
    } catch (_) {
      final reverted = posts
          .map(
            (p) => p.id == postId
                ? p.copyWith(
                    likeCount: p.likedByMe ? p.likeCount - 1 : p.likeCount + 1,
                    likedByMe: !p.likedByMe,
                  )
                : p,
          )
          .toList();
      if (state is CommunityLoaded) {
        state = (state as CommunityLoaded).copyWith(posts: reverted);
      }
    }
  }

  /// Starts listening to comments for a post.
  void watchComments(String postId) {
    _commentSubs[postId]?.cancel();
    _commentSubs[postId] = _repository.watchComments(postId).listen(
      (comments) {
        if (state is! CommunityLoaded) return;
        final loaded = state as CommunityLoaded;
        final commentsMap = Map<String, List<CommentEntity>>.from(loaded.comments);
        commentsMap[postId] = comments;
        state = loaded.copyWith(comments: commentsMap);
      },
      onError: (Object _) {
        // Ignore comment stream errors; the main feed surfaces issues.
      },
    );
  }

  /// Adds a comment to a post.
  Future<void> addComment({
    required String postId,
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    if (state is! CommunityLoaded) return;
    state = (state as CommunityLoaded).copyWith(commentingPostId: postId);
    try {
      await _repository.addComment(
        postId: postId,
        userId: userId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
      );
      // The comment stream updates the list.
      state = (state as CommunityLoaded).copyWith(commentingPostId: null);
    } on Failure catch (f) {
      state = (state as CommunityLoaded).copyWith(commentingPostId: null);
      throw f;
    } catch (_) {
      state = (state as CommunityLoaded).copyWith(commentingPostId: null);
      throw const UnknownFailure();
    }
  }

  /// Stops listening to comments for a post (e.g. on sheet close).
  void stopWatchingComments(String postId) {
    _commentSubs.remove(postId)?.cancel();
  }

  @override
  void dispose() {
    _feedSubscription?.cancel();
    for (final sub in _commentSubs.values) {
      sub.cancel();
    }
    _commentSubs.clear();
    super.dispose();
  }
}
