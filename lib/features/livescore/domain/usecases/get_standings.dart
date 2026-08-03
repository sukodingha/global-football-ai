import '../entities/standings_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches standings for a competition.
class GetStandings implements UseCase<List<StandingsRowEntity>, CompetitionIdParams> {
  const GetStandings(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<List<StandingsRowEntity>> call(CompetitionIdParams params) {
    return _repository.getStandings(params.competitionId);
  }
}
