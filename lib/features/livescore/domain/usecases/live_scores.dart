import '../../../home/domain/entities/match_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches live matches.
class GetLiveMatches implements UseCase<Future<List<MatchEntity>>, NoParams> {
  const GetLiveMatches(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<List<MatchEntity>> call(NoParams params) {
    return _repository.getLiveMatches();
  }
}

/// Subscribes to real-time live score updates.
class WatchLiveScores implements UseCase<Stream<List<MatchEntity>>, NoParams> {
  const WatchLiveScores(this._repository);
  final LivescoreRepository _repository;

  @override
  Stream<List<MatchEntity>> call(NoParams params) {
    return _repository.watchLiveScores();
  }
}
