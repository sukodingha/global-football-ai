/// Base contract for use cases.
abstract class UseCase<Type, Params> {
  Type call(Params params);
}

/// Marker for use cases with no parameters.
class NoParams {
  const NoParams();
}

/// Params for operations keyed by a match id.
class MatchIdParams {
  const MatchIdParams(this.matchId);
  final int matchId;
}

/// Params for operations keyed by a competition id.
class CompetitionIdParams {
  const CompetitionIdParams(this.competitionId);
  final int competitionId;
}
