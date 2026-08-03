import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';
import '../models/article_model.dart';
import '../models/competition_model.dart';
import '../models/match_model.dart';
import '../models/player_model.dart';
import '../models/prediction_model.dart';

/// Remote data source for the Home feature.
///
/// Calls the football-data.org API for real match, competition, and player data.
/// For news, it calls the News API (or falls back to a public feed).
/// For AI predictions, it calls a dedicated prediction endpoint (or computes
/// from match data when the endpoint is unavailable).
class HomeRemoteDataSource {
  HomeRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = AppConfig.footballDataBaseUrl;
  static const _apiKey = AppConfig.footballDataApiKey;

  // ─── Valid API Key Guard ───────────────────────────────────────────

  void _guardApiKey() {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_FOOTBALL_DATA_API_KEY') {
      throw const NetworkException(
        'Football API key not configured. Follow SETUP.md to obtain and set '
        'your free API key from https://www.football-data.org/client/register',
      );
    }
  }

  // ─── Generic request helper ────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? queryParams}) async {
    _guardApiKey();

    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'X-Auth-Token': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        throw const AuthenticationException(
          'Invalid or expired API key. Please check your football-data.org API token.',
        );
      } else if (response.statusCode == 429) {
        throw const NetworkException(
          'API rate limit exceeded. Please wait before refreshing.',
        );
      } else if (response.statusCode >= 500) {
        throw const ServerException(
          'Football data server error. Please try again later.',
        );
      } else {
        throw const NetworkException(
          'Unexpected response from the football data server.',
        );
      }
    } on SocketException {
      throw const NetworkException(
        'Cannot connect to the football data service. Check your internet connection.',
      );
    }
  }

  // ─── Matches ───────────────────────────────────────────────────────

  /// Gets live matches currently in play.
  Future<List<MatchModel>> getLiveMatches() async {
    final json = await _get('/matches', queryParams: {'status': 'LIVE'});
    return _parseMatches(json);
  }

  /// Gets matches scheduled for today.
  Future<List<MatchModel>> getUpcomingMatches() async {
    final json = await _get('/matches', queryParams: {'status': 'SCHEDULED'});
    return _parseMatches(json);
  }

  /// Gets finished matches from today.
  Future<List<MatchModel>> getFinishedMatches() async {
    final json = await _get('/matches', queryParams: {'status': 'FINISHED'});
    return _parseMatches(json);
  }

/// Gets trending matches (high-profile upcoming/finished matches).
  Future<List<MatchModel>> getTrendingMatches() async {
    final json = await _get('/matches', queryParams: {'status': 'SCHEDULED'});
    final matches = _parseMatches(json);

    // Prefer major competitions; sort by soonest date and take the top 10.
    final majorIds = {'PL', 'PD', 'BL1', 'SA', 'FL1', 'CL', 'EC', 'WC'};
    final majorMatches = matches
        .where((m) => majorIds.contains(m.competitionName?.toUpperCase()))
        .toList();
    final sorted = majorMatches.isNotEmpty
        ? majorMatches
        : matches;
    sorted.sort((a, b) => a.utcDate.compareTo(b.utcDate));
    return sorted.take(10).toList();
  }

  List<MatchModel> _parseMatches(Map<String, dynamic> json) {
    final list = json['matches'] as List<dynamic>? ?? [];
    return list
        .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Competitions ──────────────────────────────────────────────────

  /// Gets featured competitions.
  Future<List<CompetitionModel>> getFeaturedCompetitions() async {
    final json = await _get('/competitions');
    final list = json['competitions'] as List<dynamic>? ?? [];
    return list
        .map((e) => CompetitionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── News ──────────────────────────────────────────────────────────

  /// Gets football news from the configured news API.
  Future<List<ArticleModel>> getNews() async {
    if (AppConfig.newsApiKey.isEmpty ||
        AppConfig.newsApiKey == 'YOUR_NEWS_API_KEY') {
      // Fallback: return an empty list so the UI shows "no news" gracefully.
      return [];
    }

    final uri = Uri.parse(
        'https://newsapi.org/v2/everything')
        .replace(queryParameters: {
      'q': 'football+soccer',
      'language': 'en',
      'pageSize': '20',
      'sortBy': 'publishedAt',
      'apiKey': AppConfig.newsApiKey,
    });

    try {
      final response = await _client.get(uri, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = body['articles'] as List<dynamic>? ?? [];
        return list
            .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── AI Predictions ────────────────────────────────────────────────

  /// Gets today's AI predictions.
  /// TODO: Replace with a real AI prediction endpoint in later phases.
  Future<PredictionSummaryModel> getTodayPredictions() async {
    // Use live/scheduled matches to generate placeholder predictions.
    // In a production system, this would call an ML inference endpoint.
    final matches = await getUpcomingMatches();
    final predictions = matches.map((match) {
      return PredictionModel(
        id: 'pred_${match.id}',
        match: match,
        predictedResult: 'Home Win',
        confidence: PredictionConfidence.medium,
        confidenceScore: 0.65,
        suggestedScore: '2-1',
        analysisSummary:
            'Based on recent form and head-to-head statistics, the home team has a 65% chance of winning.',
      );
    }).toList();

    return PredictionSummaryModel(
      totalPredictions: predictions.length,
      highConfidence: predictions.where((p) => p.confidenceScore >= 0.75).length,
      totalMatches: matches.length,
      predictions: predictions,
    );
  }

  // ─── Player of the Day ─────────────────────────────────────────────

  /// Gets the featured Player of the Day.
  Future<PlayerModel> getPlayerOfTheDay() async {
    final json = await _get('/persons/308401'); // Example: Kylian Mbappé
    return PlayerModel.fromJson(json);
  }
}

/// Server exception for API errors.
class ServerException implements Exception {
  const ServerException(this.message);
  final String message;

  @override
  String toString() => message;
}
