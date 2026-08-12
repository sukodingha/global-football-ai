import 'package:flutter/material.dart';

import '../../domain/entities/admin_competition_entity.dart';

/// A single admin-managed competition row.
class CompetitionTile extends StatelessWidget {
  const CompetitionTile({
    super.key,
    required this.competition,
    this.onToggleFeatured,
    this.onToggleActive,
    this.onEdit,
  });

  final AdminCompetitionEntity competition;
  final ValueChanged<bool>? onToggleFeatured;
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: competition.emblem != null
                  ? ClipOval(
                      child: Image.network(
                        competition.emblem!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.emoji_events_outlined),
                      ),
                    )
                  : const Icon(Icons.emoji_events_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    '${competition.code} · ${competition.country ?? 'Global'}'
                    ' · MD${competition.currentMatchday ?? '?'}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _FlagChip(
                        label: competition.featured ? 'Featured' : 'Not Featured',
                        color: competition.featured ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      _FlagChip(
                        label: competition.active ? 'Active' : 'Inactive',
                        color: competition.active ? Colors.blue : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${competition.totalTeams} teams · '
                        '${competition.totalFixtures} fixtures',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'feature':
                    onToggleFeatured?.call(!competition.featured);
                  case 'activate':
                    onToggleActive?.call(!competition.active);
                  case 'edit':
                    onEdit?.call();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'feature',
                  child: Text(
                    competition.featured ? 'Unfeature' : 'Feature',
                  ),
                ),
                PopupMenuItem(
                  value: 'activate',
                  child: Text(competition.active ? 'Deactivate' : 'Activate'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
