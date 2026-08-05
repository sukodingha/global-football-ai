import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../application/admin_providers.dart';
import '../../domain/entities/admin_revenue_entity.dart';

/// Tab for reviewing centralized moderation logs (flagged posts, banned
/// users, reported content).
class AdminModerationLogsPage extends ConsumerWidget {
  const AdminModerationLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(adminModerationLogsProvider);

    if (logs.isEmpty) {
      return const EmptyStateView(
        icon: Icons.shield_outlined,
        title: 'No moderation activity',
        message: 'Flagged posts, banned users, and reported content will '
            'appear here for review.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final log in logs) _ModerationLogTile(log: log),
      ],
    );
  }
}

class _ModerationLogTile extends StatelessWidget {
  const _ModerationLogTile({required this.log});
  final ModerationLogEntity log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (log.type) {
      'flagged_post' => Icons.flag_outlined,
      'banned_user' => Icons.block,
      'reported_content' => Icons.report_gmailerrorred_outlined,
      'report' => Icons.report_outlined,
      _ => Icons.info_outline,
    };
    final iconColor = switch (log.type) {
      'banned_user' => Colors.red,
      'reported_content' => Colors.orange,
      'flagged_post' => Colors.amber,
      _ => theme.colorScheme.primary,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(log.subject),
        subtitle: Text(
          '${log.typeLabel} · ${_formatDate(log.createdAt)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: _StatusChip(status: log.status),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(log.details),
          const SizedBox(height: 8),
          if (log.actionTaken != null) ...[
            Text(
              'Action taken: ${log.actionTaken}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (log.reportedById != null)
            Text(
              'Reported by: ${log.reportedById}',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return 'Today ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = status.toLowerCase();
    final color = switch (resolved) {
      'resolved' => Colors.green,
      'in_review' || 'reviewing' => Colors.orange,
      _ => Colors.blueGrey,
    };
    final label = switch (resolved) {
      'resolved' => 'Resolved',
      'in_review' || 'reviewing' => 'Reviewing',
      _ => 'Open',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
