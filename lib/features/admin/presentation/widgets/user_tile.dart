import 'package:flutter/material.dart';

import '../../domain/entities/admin_user_entity.dart';
import 'role_badge.dart';

/// A single admin view of a user with actions.
class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.user,
    this.onBanToggle,
    this.onRoleChange,
    this.onSubscriptionEdit,
    this.showSubscription = false,
  });

  final AdminUserEntity user;
  final ValueChanged<bool?>? onBanToggle;
  final ValueChanged<UserRole?>? onRoleChange;
  final VoidCallback? onSubscriptionEdit;
  final bool showSubscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isBanned
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          child: user.photoUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.photoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person_outline),
                  ),
                )
              : const Icon(Icons.person_outline),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                RoleBadge(role: user.role),
                if (user.isBanned) ...[
                  const SizedBox(width: 6),
                  const _BannedChip(),
                ],
                if (showSubscription && user.isPremiumActive) ...[
                  const SizedBox(width: 6),
                  const _PremiumChip(),
                ],
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'ban' || 'unban':
                onBanToggle?.call(!user.isBanned);
              case 'promote_moderator':
                onRoleChange?.call(UserRole.moderator);
              case 'promote_admin':
                onRoleChange?.call(UserRole.admin);
              case 'demote':
                onRoleChange?.call(UserRole.user);
              case 'subscription':
                onSubscriptionEdit?.call();
            }
          },
          itemBuilder: (_) => [
            if (showSubscription)
              const PopupMenuItem(
                value: 'subscription',
                child: Text('Edit Subscription'),
              ),
            PopupMenuItem(
              value: user.isBanned ? 'unban' : 'ban',
              child: Text(user.isBanned ? 'Unban user' : 'Ban user'),
            ),
            if (user.role != UserRole.moderator)
              const PopupMenuItem(
                value: 'promote_moderator',
                child: Text('Promote to Moderator'),
              ),
            if (user.role != UserRole.admin)
              const PopupMenuItem(
                value: 'promote_admin',
                child: Text('Promote to Admin'),
              ),
            if (user.role != UserRole.user)
              const PopupMenuItem(
                value: 'demote',
                child: Text('Demote to User'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BannedChip extends StatelessWidget {
  const _BannedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'BANNED',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }
}

class _PremiumChip extends StatelessWidget {
  const _PremiumChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'PREMIUM',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      ),
    );
  }
}
