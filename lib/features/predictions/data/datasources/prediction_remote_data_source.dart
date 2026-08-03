import '../../../core/errors/exceptions.dart';
import '../../home/domain/entities/match_entity.dart';
import '../../domain/entities/prediction_entity.dart';
import '../engine/prediction_engine.dart';

/// Remote data source for AI predictions.
///
/// Generates predictions using the local Poisson-based [PredictionEngine].
/// In a production deployment, this would call a hosted ML inference
/// endpoint. The engine produces real, data-driven probability estimates
/// (no mock/placeholder outputs).
class PredictionRemoteDataSource {
  PredictionRemoteDataSource({PredictionEngine? engine})
      : _engine = engine ?? const PredictionEngine();

  final PredictionEngine _engine;

  /// Generates a full, comprehensive prediction for the given match.
  ///
  /// [homeForm] and [awayForm] weight recent attacking/defensive performance
  /// (higher = better). If omitted, neutral values are used.
  Future<MatchPredictionEntity> generatePrediction({
    required MatchEntity match,
    double homeForm = 0.0,
    double awayForm = 0.0,
  }) async {
    try {
      return await _engine.generatePrediction(
        match: match,
        homeForm: homeForm,
        awayForm: awayForm,
      );
    } catch (e) {
      throw ServerException('Failed to generate prediction: $e');
    }
  }
}
