import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:global_ai_prediction/features/home/presentation/pages/home_page.dart';

import '../../test_helpers/fake_repositories.dart';

Widget _buildHome(FakeHomeRepository repo) {
  return ProviderScope(
    overrides: homeRepositoryOverrides(repo),
    child: const MaterialApp(home: HomePage()),
  );
}

/// Sets the test surface to a tall logical size so the scrollable dashboard
/// builds all of its sections (a lazy [ListView] only lays out children that
/// fit within the viewport).
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows loading indicator initially', (tester) async {
    // Delay fetches so the loading state is observable before it resolves.
    final repo = FakeHomeRepository(delay: const Duration(milliseconds: 100));
    await tester.pumpWidget(_buildHome(repo));
    await tester.pump();

    // The dashboard load is async; initially we see a spinner.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the async load complete and settle.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });

testWidgets('renders dashboard sections when loaded', (tester) async {
    _useTallSurface(tester);
    final repo = loadedHomeRepository();
    await tester.pumpWidget(_buildHome(repo));
    await tester.pumpAndSettle();

    // App bar title.
    expect(find.text('Global Football AI'), findsOneWidget);

    // Section headers.
    expect(find.text('Live Matches'), findsOneWidget);
    expect(find.text('Upcoming Matches'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Competitions'), findsOneWidget);
    expect(find.text('Player of the Day'), findsOneWidget);
    expect(find.text('Latest News'), findsOneWidget);

    // News article titles.
    expect(find.text('Big Transfer News'), findsOneWidget);
    expect(find.text('Match Preview'), findsOneWidget);

    // Player of the day.
    expect(find.text('Star Player'), findsOneWidget);
  });

  testWidgets('shows error state when load fails', (tester) async {
    final repo = FakeHomeRepository(throwOnFetch: true);
    await tester.pumpWidget(_buildHome(repo));
    await tester.pumpAndSettle();

    expect(find.text('Oops, something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('does not show empty sections when there is no data', (tester) async {
    final repo = FakeHomeRepository();
    await tester.pumpWidget(_buildHome(repo));
    await tester.pumpAndSettle();

    // No sections should be present since lists are empty.
    expect(find.text('Live Matches'), findsNothing);
    expect(find.text('Upcoming Matches'), findsNothing);
    expect(find.text('Latest News'), findsNothing);
  });
}
