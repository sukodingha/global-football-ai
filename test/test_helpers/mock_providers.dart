import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fake_repositories.dart';

/// Builds a [ProviderContainer] with the home repository overridden.
ProviderContainer createHomeContainer(FakeHomeRepository repo) {
  return ProviderContainer(overrides: homeRepositoryOverrides(repo));
}

/// Builds a [ProviderContainer] with the multi-sport repository overridden.
ProviderContainer createSportsContainer(FakeMultiSportRepository repo) {
  return ProviderContainer(overrides: multiSportRepositoryOverrides(repo));
}

/// A [ProviderScope] wrapper used to override providers in widget tests.
/// Returns a [ProviderScope] with the given overrides.
ProviderScope buildProviderScope(List<Override> overrides, Widget child) {
  return ProviderScope(overrides: overrides, child: child);
}
