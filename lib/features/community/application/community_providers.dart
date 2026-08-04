import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../domain/entities/comment_entity.dart';
import '../domain/entities/community_post_entity.dart';
import '../domain/entities/user_badge_entity.dart';
import '../data/dependency_injection.dart';
import 'community_notifier.dart';
import 'community_state.dart';

/// Provider for the [CommunityNotifier] controller.
final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return CommunityNotifier(repository: repository);
});

/// Selector for the live community posts.
final communityPostsProvider = Provider<List<CommunityPostEntity>>((ref) {
  final state = ref.watch(communityNotifierProvider);
  if (state is CommunityLoaded) {
    return state.posts;
  }
  return const [];
});

/// Selector for comments on a specific post.
final commentsForPostProvider =
    Provider.family<List<CommentEntity>, String>((ref, postId) {
  final state = ref.watch(communityNotifierProvider);
  if (state is CommunityLoaded) {
    return state.commentsFor(postId);
  }
  return const [];
});

/// Selector for the current user's badges.
final myBadgesProvider = Provider<List<UserBadgeEntity>>((ref) {
  final state = ref.watch(communityNotifierProvider);
  if (state is CommunityLoaded) {
    return state.myBadges;
  }
  return const [];
});

/// Provider that starts the community feed for the current user when it is
/// first read.
final communityFeedControllerProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    ref.read(communityNotifierProvider.notifier).start(
          userId: user.id,
          myBadges: const [],
        );
  }
  return null;
});
