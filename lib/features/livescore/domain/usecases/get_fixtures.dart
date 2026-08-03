import '../entities/fixture_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches fixtures for a competition or team.
class GetFixtures implements UseCase<List<FixtureEntity>, CompetitionIdParams> {
  const GetFixtures(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<List<FixtureEntity>> call(CompetitionIdParams params) {
    return _repository.getFixtures(params.competitionId);
  }
}
