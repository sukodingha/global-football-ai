import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../home/domain/entities/match_entity.dart';
import '../../domain/entities/fixture_entity.dart';

/// Displays a list of fixtures (upcoming/scheduled matches).
class FixturesView extends StatelessWidget {
  const FixturesView({
    super.key,
    required this.fixtures,
  });

  final List<FixtureEntity> fixtures;

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No fixtures available.')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        final fixture = fixtures[index];
        return _FixtureTile(fixture: fixture);
      },
    );
  }
}

class _FixtureTile extends StatelessWidget {
  const _FixtureTile({required this.fixture});
  final FixtureEntity fixture;

  @override
  Widget build(BuildContext context) {
    final match = fixture.match;
    final time = DateFormat('EEE, MMM d • HH:mm').format(match.utcDate.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _TeamSide(
                    name: match.homeTeam.name,
                    crest: match.homeTeam.crest,
                    alignRight: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    match.status == MatchStatus.scheduled ? 'vs' : 'FT',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _TeamSide(
                    name: match.awayTeam.name,
                    crest: match.awayTeam.crest,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSide extends StatelessWidget {
  const _TeamSide({
    required this.name,
    required this.crest,
    this.alignRight = false,
  });

  final String name;
  final String? crest;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: alignRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (crest != null) ...[
          Image.network(
            crest!,
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const SizedBox(width: 20, height: 20),
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
    return row;
  }
}
