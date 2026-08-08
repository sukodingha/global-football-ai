import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:global_football_ai/features/livescore/presentation/pages/sports_feed_page.dart';

import '../../test_helpers/fake_repositories.dart';

Widget _buildFeed(FakeMultiSportRepository repo) {
  return ProviderScope(
    overrides: multiSportRepositoryOverrides(repo),
    child: const MaterialApp(home: SportsFeedPage()),
  );
}

void main() {
  testWidgets('renders app bar title and tabs', (tester) async {
    await tester.pumpWidget(_buildFeed(loadedSportsRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Live Scores'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Tennis'), findsOneWidget);
    expect(find.text('Basketball'), findsOneWidget);
  });

  testWidgets('shows live events for the selected sport', (tester) async {
    final repo = loadedSportsRepository();
    await tester.pumpWidget(_buildFeed(repo));
    await tester.pumpAndSettle();

    // Football events should be visible by default.
    expect(find.text('Team One'), findsWidgets);
    expect(find.text('Team Two'), findsWidgets);
  });

  testWidgets('switching tabs selects another sport', (tester) async {
    final repo = loadedSportsRepository();
    await tester.pumpWidget(_buildFeed(repo));
    await tester.pumpAndSettle();

    // Tap the Tennis tab.
    await tester.tap(find.text('Tennis'));
    await tester.pumpAndSettle();

    // Tennis competitors should now be visible.
    expect(find.text('Player A'), findsOneWidget);
    expect(find.text('Player B'), findsOneWidget);
  });

  testWidgets('shows empty state when no live events', (tester) async {
    final repo = FakeMultiSportRepository(events: const {});
    await tester.pumpWidget(_buildFeed(repo));
    await tester.pumpAndSettle();

    expect(find.text('No live football events right now'), findsOneWidget);
  });

  testWidgets('shows error state when loading fails', (tester) async {
    final repo = FakeMultiSportRepository(throwOnFetch: true);
    await tester.pumpWidget(_buildFeed(repo));
    await tester.pumpAndSettle();

    expect(find.text('Oops, something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
