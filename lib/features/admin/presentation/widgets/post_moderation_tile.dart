import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/repositories/admin_repository.dart';

/// A community post row for moderation.
class PostModerationTile extends StatelessWidget {
  const PostModerationTile({
    super.key,
    required this.post,
    this.onTogglePin,
    this.onDelete,
  });

  final CommunityModerationView post;
  final VoidCallback? onTogglePin;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (post.pinned) ...[
                  const Icon(Icons.push_pin, size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    post.authorName,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  DateFormat('MMM d, HH:mm').format(post.createdAt.toLocal()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              post.content,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${post.likeCount} likes · ${post.commentCount} comments'
                  '${post.reportCount > 0 ? ' · ${post.reportCount} reports' : ''}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                IconButton(
                  tooltip: post.pinned ? 'Unpin' : 'Pin',
                  icon: Icon(
                    post.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: post.pinned ? Colors.red : null,
                  ),
                  onPressed: onTogglePin,
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
