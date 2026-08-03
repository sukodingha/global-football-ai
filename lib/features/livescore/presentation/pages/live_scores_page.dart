import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../application/livescore_notifier.dart';
import '../../application/livescore_providers.dart';
import '../../application/livescore_state.dart';
import '../widgets/live_score_card.dart';

/// Live Scores page showing all currently in-play matches with
/// real-time updates.
class LiveScoresPage extends ConsumerStatefulWidget {
  const LiveScoresPage({super.key});

  @override
  ConsumerState<LiveScoresPage> createState() => _LiveScoresPageState();
}

class _LiveScoresPageState extends ConsumerState<LiveScoresPage> {
  @override
  void initState() {
    super.initState();
    // Kick off loading + live updates.
    Future.microtask(() {
      ref.read(livescoreNotifierProvider.notifier).loadLiveMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(livescoreNotifierProvider);
    final matches = ref.watch(liveMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scores'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(livescoreNotifierProvider.notifier).loadLiveMatches();
            },
          ),
        ],
      ),
      body: switch (state) {
        LivescoreInitial() || LivescoreLoading() =>
          const Center(child: CircularProgressIndicator()),
        LivescoreError(:final message) => _ErrorView(
            message: message,
            onRetry: () {
              ref.read(livescoreNotifierProvider.notifier).loadLiveMatches();
            },
          ),
        LivescoreLoaded() => matches.isEmpty
            ? const _EmptyView()
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(livescoreNotifierProvider.notifier)
                      .loadLiveMatches();
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return LiveScoreCard(
                      match: match,
                      onTap: () {
                        context.push(
                          '${AppConstants.routeMatchDetail}/${match.id}',
                        );
                      },
                    );
                  },
                ),
              ),
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No live matches right now.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
