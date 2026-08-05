import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../application/admin_providers.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../widgets/user_tile.dart';

/// Tab for managing users (view, ban, promote, edit roles).
class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);

    if (users.isEmpty) {
      return const EmptyStateView(
        icon: Icons.people_outline,
        title: 'No users found',
        message: 'Registered users will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final user in users)
          UserTile(
            user: user,
            onBanToggle: (banned) {
              if (banned == null) return;
              ref
                  .read(adminNotifierProvider.notifier)
                  .setUserBanned(userId: user.id, banned: banned);
            },
            onRoleChange: (role) {
              if (role == null) return;
              ref
                  .read(adminNotifierProvider.notifier)
                  .setUserRole(userId: user.id, role: role);
            },
            onSubscriptionEdit: () => _editSubscription(context, ref, user),
          ),
      ],
    );
  }

  void _editSubscription(
    BuildContext context,
    WidgetRef ref,
    AdminUserEntity user,
  ) {
    // Full subscription editing is on the Subscriptions tab.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit subscription on the Subscriptions tab.')),
    );
  }
}
