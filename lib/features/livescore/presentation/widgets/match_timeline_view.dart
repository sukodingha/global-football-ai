import 'package:flutter/material.dart';

import '../../domain/entities/match_timeline_entity.dart';

/// Displays the match timeline (goals, cards, substitutions, etc.)
/// as a vertical event list.
class MatchTimelineView extends StatelessWidget {
  const MatchTimelineView({
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
        child: Center(
          child: Text('No match events available yet.'),
        ),
      );
    }

    final sorted = [...events]..sort((a, b) {
        final aMin = a.additionalMinute != null
            ? a.minute + a.additionalMinute!
            : a.minute;
        final bMin = b.additionalMinute != null
            ? b.minute + b.additionalMinute!
            : b.minute;
        return aMin.compareTo(bMin);
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final event = sorted[index];
        final isHome = homeTeamId != null && event.teamId == homeTeamId;
        return _EventRow(event: event, isHome: isHome);
      },
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.isHome});
  final MatchEventEntity event;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final icon = _eventIcon(event.type);
    final color = _eventColor(event.type);

    final minute = event.additionalMinute != null
        ? "${event.minute}+${event.additionalMinute}'"
        : "${event.minute}'";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: isHome
                ? _content(context, icon, color, minute, alignRight: true)
                : const SizedBox(),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Expanded(
            child: isHome
                ? const SizedBox()
                : _content(context, icon, color, minute),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, IconData icon, Color color,
      String minute,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          event.playerName ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        ),
        Text(
          "$minute ${event.type.label}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  IconData _eventIcon(MatchEventType type) {
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
      case MatchEventType.missedPenalty:
        return Icons.close;
      case MatchEventType.varDecision:
        return Icons.screen_search_desktop;
      default:
        return Icons.info_outline;
    }
  }

  Color _eventColor(MatchEventType type) {
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
      case MatchEventType.missedPenalty:
        return Colors.redAccent;
      case MatchEventType.varDecision:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
