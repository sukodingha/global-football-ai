import 'package:flutter/material.dart';

import '../../domain/entities/lineup_entity.dart';

/// Displays the match lineups for both teams in a two-column layout.
class LineupsView extends StatelessWidget {
  const LineupsView({
    super.key,
    required this.lineups,
    this.homeName = 'Home',
    this.awayName = 'Away',
  });

  final MatchLineupEntity lineups;
  final String homeName;
  final String awayName;

  @override
  Widget build(BuildContext context) {
    final hasHome = lineups.homeTeam.isNotEmpty;
    final hasAway = lineups.awayTeam.isNotEmpty;

    if (!hasHome && !hasAway) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Lineups not available yet.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Formation: ${lineups.formation}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TeamLineup(
                title: homeName,
                players: lineups.homeTeam,
                substitutes: lineups.homeSubstitutes,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TeamLineup(
                title: awayName,
                players: lineups.awayTeam,
                substitutes: lineups.awaySubstitutes,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TeamLineup extends StatelessWidget {
  const _TeamLineup({
    required this.title,
    required this.players,
    required this.substitutes,
  });

  final String title;
  final List<LineupPlayerEntity> players;
  final List<LineupPlayerEntity> substitutes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...players.map((p) => _PlayerTile(player: p)),
        if (substitutes.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Substitutes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          ...substitutes.map((p) => _PlayerTile(player: p, isSub: true)),
        ],
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.player, this.isSub = false});
  final LineupPlayerEntity player;
  final bool isSub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${player.number}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (player.isCaptain)
                  const Text(
                    '(C)',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
