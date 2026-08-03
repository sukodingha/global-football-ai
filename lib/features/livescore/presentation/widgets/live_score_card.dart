import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../home/domain/entities/match_entity.dart';

/// A single live match card showing teams, score, and match minute.
class LiveScoreCard extends StatelessWidget {
  const LiveScoreCard({
    super.key,
    required this.match,
    this.onTap,
  });

  final MatchEntity match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLive = match.status.isLive;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  if (isLive)
                    const _LiveBadge()
                  else
                    Text(
                      DateFormat('EEE, MMM d').format(match.utcDate.toLocal()),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const Spacer(),
                  if (match.competitionName != null)
                    Text(
                      match.competitionName!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Team(
                      name: match.homeTeam.name,
                      crest: match.homeTeam.crest,
                      alignRight: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLive && match.minute != null)
                          Text(
                            "${match.minute}'",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _Team(
                      name: match.awayTeam.name,
                      crest: match.awayTeam.crest,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Team extends StatelessWidget {
  const _Team({
    required this.name,
    required this.crest,
    this.alignRight = false,
  });

  final String name;
  final String? crest;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (crest != null) ...[
          Image.network(
            crest!,
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) => const SizedBox(width: 24, height: 24),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
