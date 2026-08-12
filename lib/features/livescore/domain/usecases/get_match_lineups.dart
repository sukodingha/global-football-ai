import '../entities/lineup_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches the lineups for a match.
class GetMatchLineups implements UseCase<Future<MatchLineupEntity>, MatchIdParams> {
  const GetMatchLineups(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<MatchLineupEntity> call(MatchIdParams params) {
    return _repository.getMatchLineups(params.matchId);
  }
}
