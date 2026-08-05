import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../application/admin_providers.dart';
import '../widgets/post_moderation_tile.dart';

/// Tab for community moderation (pin/delete posts).
class AdminModerationPage extends ConsumerWidget {
  const AdminModerationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(adminPostsProvider);

    if (posts.isEmpty) {
      return const EmptyStateView(
        icon: Icons.forum_outlined,
        title: 'No posts to moderate',
        message: 'Community posts will appear here for moderation.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final post in posts)
          PostModerationTile(
            post: post,
            onTogglePin: () => ref
                .read(adminNotifierProvider.notifier)
                .setPostPinned(postId: post.id, pinned: !post.pinned),
            onDelete: () => _confirmDelete(context, ref, post),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, post) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(adminNotifierProvider.notifier)
                  .deletePost(postId: post.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
