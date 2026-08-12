import '../entities/heatmap_entity.dart';
import '../repositories/livescore_repository.dart';
import 'usecase.dart';

/// Fetches heat map data for a match.
class GetMatchHeatmap
    implements UseCase<Future<List<HeatmapPointEntity>>, MatchIdParams> {
  const GetMatchHeatmap(this._repository);
  final LivescoreRepository _repository;

  @override
  Future<List<HeatmapPointEntity>> call(MatchIdParams params) {
    return _repository.getMatchHeatmap(params.matchId);
  }
}
