import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/admin_user_entity.dart';

/// A user row showing subscription/tier information.
class SubscriptionTile extends StatelessWidget {
  const SubscriptionTile({super.key, required this.user, this.onEdit});

  final AdminUserEntity user;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email;
    final end = user.premiumEnd;
    final dateStr = end != null
        ? DateFormat('MMM d, yyyy').format(end.toLocal())
        : '—';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          user.isPremiumActive ? Icons.workspace_premium : Icons.person_outline,
          color: user.isPremiumActive ? Colors.amber : theme.colorScheme.outline,
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              user.isPremium
                  ? '${user.premiumPlanName ?? 'Premium'} · expires $dateStr'
                  : 'Free tier · Donated ₦${user.donationsTotalNaira.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: onEdit != null
            ? IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              )
            : null,
      ),
    );
  }
}
