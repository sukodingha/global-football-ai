import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/community_post_entity.dart';

/// A single post card on the community wall with author, badges, content,
/// like/comment counts, and action buttons.
class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onCommentTap,
    this.showFullTime = true,
  });

  final CommunityPostEntity post;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onCommentTap;
  final bool showFullTime;

  bool get _isMine => post.authorId == currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(
                  photoUrl: post.authorPhotoUrl,
                  name: post.authorName,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isMine) ...[
                            const SizedBox(width: 4),
                            Text(
                              '• You',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, HH:mm')
                            .format(post.createdAt.toLocal()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (post.authorBadges.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final badgeId in post.authorBadges)
                              _BadgeChip(badgeId: badgeId),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (post.matchLabel != null) ...[
              _MatchChip(label: post.matchLabel!),
              const SizedBox(height: 8),
            ],
            Text(
              post.content,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 4),
            Row(
              children: [
                _ActionButton(
                  icon: post.likedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: post.likedByMe ? Colors.red : null,
                  label: '${post.likeCount}',
                  onTap: onLike,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentCount}',
                  onTap: onCommentTap,
                ),
                const Spacer(),
                if (showFullTime)
                  IconButton(
                    tooltip: 'Report',
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onPressed: () {},
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.name});
  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(20);
    if (photoUrl != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          photoUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(theme),
        ),
      );
    }
    return _fallback(theme);
  }

  Widget _fallback(ThemeData theme) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.badgeId});
  final String badgeId;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (badgeId) {
      'early_adopter' => (Icons.rocket_launch, 'Early Adopter'),
      'top_analyst' => (Icons.insights, 'Top Analyst'),
      'premium_member' => (Icons.workspace_premium, 'Premium'),
      'contributor' => (Icons.forum, 'Contributor'),
      _ => (Icons.star, badgeId),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.amber[800]),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.amber[900]),
          ),
        ],
      ),
    );
  }
}

class _MatchChip extends StatelessWidget {
  const _MatchChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_soccer, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color ?? Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

