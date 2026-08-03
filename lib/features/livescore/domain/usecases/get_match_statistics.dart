import '../entities/match_statistics_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches advanced statistics for a match.
class GetMatchStatistics
    implements UseCase<List<MatchStatisticEntity>, MatchIdParams> {
  const GetMatchStatistics(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<List<MatchStatisticEntity>> call(MatchIdParams params) {
    return _repository.getMatchStatistics(params.matchId);
  }
}
