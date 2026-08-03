import 'package:flutter/material.dart';

import '../../domain/entities/match_timeline_entity.dart';

/// Tracks and displays goals, cards, and substitutions in a compact,
/// grouped summary.
class MatchEventsView extends StatelessWidget {
  const MatchEventsView({
    super.key,
    required this.events,
    this.homeTeamId,
    this.awayTeamId,
  });

  final List<MatchEventEntity> events;
  final int? homeTeamId;
  final int? awayTeamId;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No events recorded yet.')),
      );
    }

    final goals = events.where((e) =>
        e.type == MatchEventType.goal || e.type == MatchEventType.penalty ||
        e.type == MatchEventType.ownGoal).toList();
    final cards = events.where((e) =>
        e.type == MatchEventType.yellowCard ||
        e.type == MatchEventType.secondYellowCard ||
        e.type == MatchEventType.redCard).toList();
    final substitutions = events
        .where((e) => e.type == MatchEventType.substitution)
        .toList();

    return Column(
      children: [
        if (goals.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.sports_soccer,
            title: 'Goals',
            color: Colors.green,
            count: goals.length,
          ),
          ...goals.map((e) => _EventRow(event: e, isHome: e.teamId == homeTeamId)),
        ],
        if (cards.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.credit_card,
            title: 'Cards',
            color: Colors.amber,
            count: cards.length,
          ),
          ...cards.map((e) => _EventRow(event: e, isHome: e.teamId == homeTeamId)),
        ],
        if (substitutions.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.swap_horiz,
            title: 'Substitutions',
            color: Colors.blue,
            count: substitutions.length,
          ),
          ...substitutions.map((e) => _EventRow(event: e, isHome: e.teamId == homeTeamId)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.count,
  });

  final IconData icon;
  final String title;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.isHome});
  final MatchEventEntity event;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final icon = _icon(event.type);
    final color = _color(event.type);
    final minute = event.additionalMinute != null
        ? "${event.minute}+${event.additionalMinute}'"
        : "${event.minute}'";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: isHome
                ? Text(
                    '${event.playerName ?? 'Unknown'} ($minute)',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13),
                  )
                : const SizedBox(),
          ),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          Expanded(
            child: isHome
                ? const SizedBox()
                : Text(
                    '${event.playerName ?? 'Unknown'} ($minute)',
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }

  IconData _icon(MatchEventType type) {
    switch (type) {
      case MatchEventType.goal:
      case MatchEventType.penalty:
        return Icons.sports_soccer;
      case MatchEventType.ownGoal:
        return Icons.sports_soccer;
      case MatchEventType.yellowCard:
      case MatchEventType.secondYellowCard:
        return Icons.square;
      case MatchEventType.redCard:
        return Icons.square;
      case MatchEventType.substitution:
        return Icons.swap_horiz;
      default:
        return Icons.info_outline;
    }
  }

  Color _color(MatchEventType type) {
    switch (type) {
      case MatchEventType.goal:
      case MatchEventType.penalty:
        return Colors.green;
      case MatchEventType.ownGoal:
        return Colors.orange;
      case MatchEventType.yellowCard:
      case MatchEventType.secondYellowCard:
        return Colors.amber;
      case MatchEventType.redCard:
        return Colors.red;
      case MatchEventType.substitution:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
