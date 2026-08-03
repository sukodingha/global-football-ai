import 'package:flutter/material.dart';

import '../../domain/entities/standings_entity.dart';

/// Displays the competition standings table.
class StandingsView extends StatelessWidget {
  const StandingsView({
    super.key,
    required this.rows,
    this.competitionName = 'Standings',
  });

  final List<StandingsRowEntity> rows;
  final String competitionName;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No standings available.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            competitionName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const _HeaderRow(),
        ...rows.map((row) => _StandingsRow(row: row)),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 11, color: Colors.grey.shade600);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('#', style: style)),
          Expanded(
            child: Text('Team', style: style),
          ),
          SizedBox(width: 28, child: Text('P', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('W', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('D', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('L', style: style, textAlign: TextAlign.center)),
          SizedBox(width: 36, child: Text('Pts', style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _StandingsRow extends StatelessWidget {
  const _StandingsRow({required this.row});
  final StandingsRowEntity row;

  @override
  Widget build(BuildContext context) {
    final isTop = row.position <= 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${row.position}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTop ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (row.teamCrest != null) ...[
                  Image.network(
                    row.teamCrest!,
                    width: 18,
                    height: 18,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 18, height: 18),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    row.teamName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 28, child: Text('${row.playedGames}', textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('${row.won}', textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('${row.draw}', textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('${row.lost}', textAlign: TextAlign.center)),
          SizedBox(
            width: 36,
            child: Text(
              '${row.points}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
