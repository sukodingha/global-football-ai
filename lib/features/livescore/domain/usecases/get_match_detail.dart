import '../entities/match_detail_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches the full detail for a single match.
class GetMatchDetail implements UseCase<MatchDetailEntity, MatchIdParams> {
  const GetMatchDetail(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<MatchDetailEntity> call(MatchIdParams params) {
    return _repository.getMatchDetail(params.matchId);
  }
}
