import 'package:flutter/material.dart';

import '../../domain/entities/fantasy_league_entity.dart';

/// A card presenting a fantasy league with its visibility, member count and
/// join code.
class LeagueCard extends StatelessWidget {
  const LeagueCard({
    super.key,
    required this.league,
    this.isSelected = false,
    this.onTap,
    this.trailing,
  });

  final FantasyLeagueEntity league;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.primary, width: 2),
            )
          : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            league.isPublic ? Icons.public : Icons.lock_outline,
            color: scheme.onPrimaryContainer,
          ),
        ),
        title: Text(league.name),
        subtitle: Text(
          '${league.memberCount} member${league.memberCount == 1 ? '' : 's'}'
          ' · Code ${league.code}',
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}
