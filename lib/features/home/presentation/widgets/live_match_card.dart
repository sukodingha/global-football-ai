import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../../domain/entities/match_entity.dart';

/// Card for a live match with current score.
class LiveMatchCard extends StatelessWidget {
  const LiveMatchCard({super.key, required this.match});
  final MatchEntity match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.homeTeam.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${match.minute ?? 0}\'',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    match.awayTeam.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            if (match.competitionName != null) ...[
              const SizedBox(height: 8),
              Text(
                match.competitionName!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
