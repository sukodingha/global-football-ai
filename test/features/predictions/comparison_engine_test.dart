import 'package:flutter_test/flutter_test.dart';

import 'package:global_ai_prediction/features/predictions/data/engine/comparison_engine.dart';
import 'package:global_ai_prediction/features/predictions/domain/entities/post_match_comparison_entity.dart';

import 'fixtures/prediction_fixtures.dart';

void main() {
  const engine = ComparisonEngine();

  group('ComparisonEngine', () {
    test('returns an all-correct comparison when the prediction matches', () {
      // buildPrediction predicts home 2-1, BTTS yes, over 2.5, over 9.5 corners,
      // under 4.5 cards.
      final prediction = buildPrediction();
      final result = engine.compare(
        prediction: prediction,
        actualHomeScore: 2,
        actualAwayScore: 1,
        actualCorners: 11,
        actualCards: 3,
      );

      expect(result, isA<PostMatchComparisonEntity>());
      expect(result.matchWinnerCorrect, isTrue);
      expect(result.doubleChanceCorrect, isTrue);
      expect(result.bttsCorrect, isTrue);
      expect(result.correctScoreCorrect, isTrue);
      expect(result.overUnderCorrect, isTrue);
      expect(result.cornersCorrect, isTrue);
      expect(result.cardsCorrect, isTrue);
      expect(result.correctPredictions, result.totalPredictions);
      expect(result.overallAccuracy, 100.0);
    });

test('flags incorrect markets against a conflicting result', () {
      // Prediction says home 2-1, but the actual result is away 0-3.
      final prediction = buildPrediction();
      final result = engine.compare(
        prediction: prediction,
        actualHomeScore: 0,
        actualAwayScore: 3,
        actualCorners: 5, // under 9.5 -> cornersPrediction over 9.5 is wrong
        actualCards: 6, // over 4.5 -> cardsPrediction under 4.5 is wrong
      );

      // Predicted 'home', actual away -> incorrect.
      expect(result.matchWinnerCorrect, isFalse);
      // Predicted 2-1, actual 0-3 -> incorrect.
      expect(result.correctScoreCorrect, isFalse);
      // Predicted BTTS yes, only away scored -> incorrect.
      expect(result.bttsCorrect, isFalse);
      // Predicted over 9.5 corners, actual 5 -> incorrect.
      expect(result.cornersCorrect, isFalse);
      // Predicted under 4.5 cards, actual 6 -> incorrect.
      expect(result.cardsCorrect, isFalse);
      expect(result.overallAccuracy, lessThan(100.0));
    });

    test('excludes corners and cards when actual data is not supplied', () {
      final prediction = buildPrediction();
      final result = engine.compare(
        prediction: prediction,
        actualHomeScore: 2,
        actualAwayScore: 1,
      );

      expect(result.cornersCorrect, isNull);
      expect(result.cardsCorrect, isNull);
      // Only the 5 core markets are evaluated.
      expect(result.totalPredictions, 5);
      expect(result.correctPredictions, 5);
      expect(result.overallAccuracy, 100.0);
    });

    test('BTTS is evaluated against whether both teams scored', () {
      final prediction = buildPrediction(bttsPrediction: true);
      // Both teams score -> BTTS yes is correct.
      final bothScored = engine.compare(
        prediction: prediction,
        actualHomeScore: 2,
        actualAwayScore: 1,
      );
      expect(bothScored.bttsCorrect, isTrue);

      // Only one team scores -> BTTS yes is incorrect.
      final oneScored = engine.compare(
        prediction: prediction,
        actualHomeScore: 2,
        actualAwayScore: 0,
      );
      expect(oneScored.bttsCorrect, isFalse);
    });

    test('over/under is evaluated against the total goal count', () {
      // Prediction: over 2.5.
      final prediction = buildPrediction(overUnderPrediction: true);
      final over = engine.compare(
        prediction: prediction,
        actualHomeScore: 3,
        actualAwayScore: 1, // 4 total -> over
      );
      expect(over.overUnderCorrect, isTrue);

      final under = engine.compare(
        prediction: prediction,
        actualHomeScore: 1,
        actualAwayScore: 1, // 2 total -> under
      );
      expect(under.overUnderCorrect, isFalse);
    });

test('double chance correct market covers the actual outcome', () {
      // Prediction double chance: homeOrAway (0.81) is the strongest market,
      // which is '12' — covering home AND away but NOT a draw.
      final prediction = buildPrediction();
      // Home win is covered.
      final homeWin = engine.compare(
        prediction: prediction,
        actualHomeScore: 2,
        actualAwayScore: 0,
      );
      expect(homeWin.doubleChanceCorrect, isTrue);

      // Away win is also covered by '12'.
      final awayWin = engine.compare(
        prediction: prediction,
        actualHomeScore: 0,
        actualAwayScore: 2,
      );
      expect(awayWin.doubleChanceCorrect, isTrue);

      // A draw is NOT covered by the strongest '12' market.
      final draw = engine.compare(
        prediction: prediction,
        actualHomeScore: 1,
        actualAwayScore: 1,
      );
      expect(draw.doubleChanceCorrect, isFalse);
    });

    test('summary string reports counts and accuracy', () {
      final prediction = buildPrediction();
      final result = engine.compare(
        prediction: prediction,
        actualHomeScore: 2,
        actualAwayScore: 1,
      );
      expect(result.summary, contains('${result.correctPredictions}'));
      expect(result.summary, contains('% accuracy'));
    });
  });
}
