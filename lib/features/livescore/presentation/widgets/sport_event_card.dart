import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/sport_event_entity.dart';

/// A live event card for any sport (football, tennis, basketball) showing
/// competitors, scores, status badges (LIVE / Halftime / FT), and the
/// current period or minute.
class SportEventCard extends StatelessWidget {
  const SportEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final SportEventEntity event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                  _StatusBadge(event: event),
                  const Spacer(),
                  Text(
                    event.competition ?? _sportLabel(event.sport),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Competitor(
                      name: event.home.name,
                      crest: event.home.logo,
                      alignRight: true,
                    ),
                  ),
                  _ScoreCenter(event: event),
                  Expanded(
                    child: _Competitor(
                      name: event.away.name,
                      crest: event.away.logo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _DetailLine(event: event),
            ],
          ),
        ),
      ),
    );
  }

  static String _sportLabel(SportType sport) => sport.label;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.event});
  final SportEventEntity event;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (event.status) {
      case SportEventStatus.live:
        color = Colors.red;
        break;
      case SportEventStatus.halftime:
        color = Colors.orange;
        break;
      case SportEventStatus.fulltime:
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.isLive) ...[
            const Icon(Icons.circle, size: 8, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            event.status.label,
            style: const TextStyle(
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

class _Competitor extends StatelessWidget {
  const _Competitor({
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
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
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

class _ScoreCenter extends StatelessWidget {
  const _ScoreCenter({required this.event});
  final SportEventEntity event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            _scoreText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (event.sport == SportType.tennis &&
              (event.home.setsWon != null || event.away.setsWon != null))
            Text(
              'Sets ${event.home.setsWon ?? 0}–${event.away.setsWon ?? 0}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (event.sport == SportType.football && event.isLive)
            Text(
              "${event.minute ?? 0}'",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  String get _scoreText {
    final h = event.home.score;
    final a = event.away.score;
    if (event.sport == SportType.tennis) {
      // Show current set games: games-to-games.
      final hg = h;
      final ag = a;
      return hg != null || ag != null ? '${hg ?? 0}–${ag ?? 0}' : 'vs';
    }
    return '${h ?? 0} – ${a ?? 0}';
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.event});
  final SportEventEntity event;

  @override
  Widget build(BuildContext context) {
    String detail = '';
    switch (event.sport) {
      case SportType.basketball:
        detail = event.currentPeriod ?? '';
        final quarters = _quarterSummary();
        if (quarters.isNotEmpty) detail = '$detail  •  $quarters';
        break;
      case SportType.tennis:
        detail = event.currentPeriod ?? '';
        break;
      case SportType.football:
        detail = event.isLive
            ? "${event.minute ?? 0}'"
            : DateFormat('EEE, MMM d HH:mm').format(event.startTime.toLocal());
        break;
    }

    if (detail.isEmpty) {
      detail = DateFormat('EEE, MMM d HH:mm').format(event.startTime.toLocal());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.schedule, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _quarterSummary() {
    final home = (event.eventDetails['homeQuarters'] as List<dynamic>? ?? [])
        .cast<int>();
    final away = (event.eventDetails['awayQuarters'] as List<dynamic>? ?? [])
        .cast<int>();
    if (home.isEmpty && away.isEmpty) return '';
    final parts = <String>[];
    for (var i = 0; i < home.length && i < away.length; i++) {
      parts.add('Q${i + 1} ${home[i]}-${away[i]}');
    }
    return parts.join('  ');
  }
}

