import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/prediction_providers.dart';
import '../../domain/entities/user_vote_entity.dart';

/// Interactive upvote/downvote widget for a prediction.
///
/// Reads the current vote counts and the user's own vote from the
/// [predictionNotifierProvider] and submits changes on tap.
class VoteWidget extends ConsumerWidget {
  const VoteWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(voteCountsProvider);
    final myVote = ref.watch(myVoteProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoteButton(
          icon: Icons.thumb_up_outlined,
          selectedIcon: Icons.thumb_up,
          selected: myVote == 'up',
          count: counts?.upvotes ?? 0,
          onTap: () => _vote(context, ref, 'up'),
        ),
        const SizedBox(width: 16),
        Text(
          '${counts?.totalVotes ?? 0} votes',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 16),
        _VoteButton(
          icon: Icons.thumb_down_outlined,
          selectedIcon: Icons.thumb_down,
          selected: myVote == 'down',
          count: counts?.downvotes ?? 0,
          onTap: () => _vote(context, ref, 'down'),
        ),
      ],
    );
  }

  Future<void> _vote(
    BuildContext context,
    WidgetRef ref,
    String vote,
  ) async {
    final message = await ref
        .read(predictionNotifierProvider.notifier)
        .voteOnPrediction(vote);
    if (message != null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
