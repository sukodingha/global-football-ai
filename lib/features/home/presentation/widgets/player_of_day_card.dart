import 'package:flutter/material.dart';

import '../../domain/entities/player_entity.dart';

/// Card displaying the featured Player of the Day.
class PlayerOfDayCard extends StatelessWidget {
  const PlayerOfDayCard({super.key, required this.player});
  final PlayerEntity player;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (player.photoUrl != null)
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(player.photoUrl!),
                onBackgroundImageError: (_, __) {},
              )
            else
              CircleAvatar(
                radius: 36,
                child: Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.position}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (player.team != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      player.team!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (player.rating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${player.rating!.toStringAsFixed(1)}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
