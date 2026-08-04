import 'package:flutter/material.dart';

import '../../domain/entities/fantasy_team_entity.dart';

/// A summary card for a fantasy team showing budget, points and squad count.
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
  });

  final FantasyTeamEntity team;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.shield_outlined, color: scheme.onPrimaryContainer),
        ),
        title: Text(team.name),
        subtitle: Text(
          '${team.players.length}/11 players · '
          '£${team.budgetRemaining.toStringAsFixed(1)}M left',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              team.totalPoints.toStringAsFixed(0),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            Text(
              'points',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
