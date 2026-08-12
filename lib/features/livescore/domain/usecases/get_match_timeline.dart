import '../entities/match_timeline_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches the timeline (events) for a match.
class GetMatchTimeline implements UseCase<Future<List<MatchEventEntity>>, MatchIdParams> {
  const GetMatchTimeline(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<List<MatchEventEntity>> call(MatchIdParams params) {
    return _repository.getMatchTimeline(params.matchId);
  }
}
