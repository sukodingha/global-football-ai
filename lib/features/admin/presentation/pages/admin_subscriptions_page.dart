import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../application/admin_providers.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../widgets/subscription_tile.dart';

/// Tab for tracking and managing user subscription/tier statuses.
class AdminSubscriptionsPage extends ConsumerWidget {
  const AdminSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);

    if (users.isEmpty) {
      return const EmptyStateView(
        icon: Icons.workspace_premium_outlined,
        title: 'No subscribers yet',
        message: 'User subscription tiers will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final user in users)
          SubscriptionTile(
            user: user,
            onEdit: () => _editSubscription(context, ref, user),
          ),
      ],
    );
  }

  Future<void> _editSubscription(
    BuildContext context,
    WidgetRef ref,
    AdminUserEntity user,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _SubscriptionEditDialog(user: user),
    );
    if (result != null) {
      ref.read(adminNotifierProvider.notifier).updateSubscription(
            userId: user.id,
            isPremium: result['isPremium'] as bool,
            planName: result['planName'] as String?,
            end: result['end'] as DateTime?,
          );
    }
  }
}

class _SubscriptionEditDialog extends StatefulWidget {
  const _SubscriptionEditDialog({required this.user});
  final AdminUserEntity user;

  @override
  State<_SubscriptionEditDialog> createState() =>
      _SubscriptionEditDialogState();
}

class _SubscriptionEditDialogState extends State<_SubscriptionEditDialog> {
  late bool _isPremium;
  late final TextEditingController _planController;

  @override
  void initState() {
    super.initState();
    _isPremium = widget.user.isPremium;
    _planController =
        TextEditingController(text: widget.user.premiumPlanName ?? 'premium');
  }

  @override
  void dispose() {
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Subscription'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Premium'),
            value: _isPremium,
            onChanged: (v) => setState(() => _isPremium = v),
          ),
          TextField(
            controller: _planController,
            decoration: const InputDecoration(labelText: 'Plan name'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'isPremium': _isPremium,
              'planName': _planController.text.trim().isEmpty
                  ? null
                  : _planController.text.trim(),
              'end': _isPremium ? DateTime.now().add(const Duration(days: 30)) : null,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
