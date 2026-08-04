import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../application/community_providers.dart';
import '../../application/community_state.dart';
import '../../domain/entities/community_post_entity.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/community_post_card.dart';
import '../widgets/post_composer.dart';

/// The community wall: a real-time, Facebook-style feed of posts.
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});
  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Start the feed once the user is available.
    ref.watch(communityFeedControllerProvider);

    final state = ref.watch(communityNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            tooltip: 'Appearance',
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: switch (state) {
        CommunityInitial() || CommunityLoading() =>
          const Center(child: CircularProgressIndicator()),
        CommunityError(:final message) => _ErrorView(message: message),
        CommunityLoaded() => _FeedView(
            posts: state.posts,
            currentUserId: user?.id ?? '',
            onLike: (post) {
              final uid = user?.id;
              if (uid == null) return;
              ref
                  .read(communityNotifierProvider.notifier)
                  .toggleLike(postId: post.id, userId: uid);
            },
            onCommentTap: (post) => _openComments(post),
          ),
      },
    );
  }

  void _openComments(CommunityPostEntity post) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => CommentSheet(post: post),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView({
    required this.posts,
    required this.currentUserId,
    required this.onLike,
    required this.onCommentTap,
  });

  final List<CommunityPostEntity> posts;
  final String currentUserId;
  final ValueChanged<CommunityPostEntity> onLike;
  final ValueChanged<CommunityPostEntity> onCommentTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const PostComposer(),
          const SizedBox(height: 4),
          if (posts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'No posts yet. Be the first to share!',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            for (final post in posts)
              CommunityPostCard(
                post: post,
                currentUserId: currentUserId,
                onLike: () => onLike(post),
                onCommentTap: () => onCommentTap(post),
              ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
