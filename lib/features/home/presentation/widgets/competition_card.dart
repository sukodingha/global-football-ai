import 'package:flutter/material.dart';

import '../../domain/entities/competition_entity.dart';

/// Card for a competition in the horizontal carousel.
class CompetitionCard extends StatelessWidget {
  const CompetitionCard({super.key, required this.competition});
  final CompetitionEntity competition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (competition.emblem != null)
                Image.network(
                  competition.emblem!,
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events),
                )
              else
                const Icon(Icons.emoji_events, size: 40),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  competition.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (competition.country != null) ...[
                const SizedBox(height: 4),
                Text(
                  competition.country!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
