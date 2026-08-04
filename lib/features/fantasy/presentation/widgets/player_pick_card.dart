import 'package:flutter/material.dart';

import '../../domain/entities/fantasy_player_entity.dart';

/// A draggable/selectable player card used in the transfer market and roster.
///
/// Shows the player's position, price, current fantasy points and (optionally)
/// a captain/vice-captain badge.
class PlayerPickCard extends StatelessWidget {
  const PlayerPickCard({
    super.key,
    required this.player,
    this.isInSquad = false,
    this.isCaptain = false,
    this.isViceCaptain = false,
    this.canRemove = false,
    this.onAdd,
    this.onRemove,
    this.onSetCaptain,
    this.onSetViceCaptain,
  });

  final FantasyPlayerEntity player;
  final bool isInSquad;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool canRemove;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onSetCaptain;
  final VoidCallback? onSetViceCaptain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _PositionAvatar(position: player.position, scheme: scheme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          style: theme.textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCaptain) ...[
                        const SizedBox(width: 6),
                        CaptainRoleBadge(label: 'C', multiplier: '2x'),
                      ],
                      if (isViceCaptain) ...[
                        const SizedBox(width: 6),
                        const CaptainRoleBadge(label: 'VC', multiplier: '1.5x'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${player.team} · ${player.position.name}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '£${player.price.toStringAsFixed(1)}M',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${player.totalPoints.toStringAsFixed(0)} pts',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(width: 8),
            if (isInSquad && canRemove)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline),
                color: scheme.error,
                tooltip: 'Remove from squad',
              )
            else if (!isInSquad)
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
                color: scheme.primary,
                tooltip: 'Add to squad',
              ),
          ],
        ),
      ),
    );
  }
}

/// Small badge showing captain/vice-captain role.
class CaptainRoleBadge extends StatelessWidget {
  const CaptainRoleBadge({super.key, required this.label, required this.multiplier});
  final String label;
  final String multiplier;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: label == 'C' ? scheme.primary : scheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Tooltip(
        message: '$label · $multiplier points',
        child: Text(
          label,
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PositionAvatar extends StatelessWidget {
  const _PositionAvatar({required this.position, required this.scheme});
  final FantasyPosition position;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (position) {
      FantasyPosition.goalkeeper => (Icons.sports_handball, 'GK'),
      FantasyPosition.defender => (Icons.shield_outlined, 'DEF'),
      FantasyPosition.midfielder => (Icons.sports_soccer, 'MID'),
      FantasyPosition.forward => (Icons.flash_on, 'FWD'),
    };
    return CircleAvatar(
      backgroundColor: scheme.secondaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSecondaryContainer),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
