import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/match_entity.dart';

/// Card for an upcoming/finished match.
class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match});
  final MatchEntity match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat('HH:mm').format(match.utcDate.toLocal());
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                match.homeTeam.name,
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                match.status.isFinished
                    ? '${match.homeScore ?? 0} - ${match.awayScore ?? 0}'
                    : time,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: Text(
                match.awayTeam.name,
                textAlign: TextAlign.right,
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
