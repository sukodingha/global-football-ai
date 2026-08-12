import 'package:flutter/material.dart';

import '../../domain/entities/leaderboard_entry_entity.dart';

/// A leaderboard list rendering [LeaderboardEntryEntity]s with rank, team
/// name, user and total points.
class LeaderboardTable extends StatelessWidget {
  const LeaderboardTable({
    super.key,
    required this.entries,
    this.highlightTeamId,
  });

  final List<LeaderboardEntryEntity> entries;
  final String? highlightTeamId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isHighlighted = entry.teamId == highlightTeamId;
        final rankColor = switch (entry.rank) {
          1 => Colors.amber,
          2 => Colors.grey,
          3 => const Color(0xFFCD7F32),
          _ => scheme.outline,
        };

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isHighlighted ? scheme.primaryContainer : null,
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: rankColor.withOpacity(0.2),
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
            title: Text(entry.teamName),
            subtitle: Text(entry.userName),
            trailing: Text(
              entry.totalPoints.toStringAsFixed(0),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
