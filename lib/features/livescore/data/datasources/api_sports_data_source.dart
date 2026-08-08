import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/sport_event_entity.dart';

/// Real-time multi-sport data source backed by API-Sports (api-sports.io).
///
/// Fetches live and today's events for football, tennis, and basketball.
/// The API key is read from [AppConfig.apiSportsKey]; the client guards
/// against an unconfigured key with a clear setup error, matching the
/// pattern used by [FootballApiClient].
class ApiSportsDataSource {
  ApiSportsDataSource({
    http.Client? client,
    String? baseUrl,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiSportsBaseUrl,
        _apiKey = apiKey ?? AppConfig.apiSportsKey;

  final http.Client _client;
  final String _baseUrl;
  final String _apiKey;

  void _guardApiKey() {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_SPORTS_KEY') {
      throw const NetworkException(
        'API-Sports key not configured. Obtain a key at '
        'https://www.api-sports.io and set it in lib/core/config/app_config.dart '
        '(apiSportsKey).',
      );
    }
  }

  /// Fetches "live" events for a [sport].
  Future<List<SportEventEntity>> getLiveEvents(SportType sport) {
    return _fetch(sport, status: 'live');
  }

  /// Fetches today's events (live, scheduled, finished) for a [sport].
  Future<List<SportEventEntity>> getTodayEvents(SportType sport) {
    return _fetch(sport);
  }

  Future<List<SportEventEntity>> _fetch(
    SportType sport, {
    String? status,
  }) async {
    _guardApiKey();

    final query = <String, String>{
      if (status != null) 'status': status,
      if (sport == SportType.football) 'timezone': 'UTC',
    };

    final path = switch (sport) {
      SportType.football => '/football/fixtures',
      SportType.tennis => '/tennis/fixtures',
      SportType.basketball => '/basketball/games',
    };

    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    try {
      final response = await _client.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: _apiKey,
        },
      );
      return _parseSportResponse(sport, response);
    } on NetworkException {
      rethrow;
    } on SocketException {
      throw const NetworkException(
        'Cannot connect to the live sports service. Check your internet connection.',
      );
    } on TimeoutException {
      throw const NetworkException(
        'The live sports service timed out. Please try again.',
      );
    }
  }

  /// Parses the API-Sports response envelope into [SportEventEntity]s.
  List<SportEventEntity> _parseSportResponse(
    SportType sport,
    http.Response response,
  ) {
    if (response.statusCode != 200) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AuthenticationException(
          'Invalid or expired API-Sports key. Please check apiSportsKey in '
          'lib/core/config/app_config.dart.',
        );
      }
      if (response.statusCode == 429) {
        throw const NetworkException(
          'API-Sports rate limit exceeded. Please wait before refreshing.',
        );
      }
      throw const ServerException(
        'Live sports server error. Please try again later.',
      );
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return const [];
    }

    // API-Sports envelope: {"get": "...", "results": n, "response": [...]}
    final results = body['response'] as List<dynamic>? ?? const [];

    return results
        .map((e) => _parseEvent(sport, e as Map<String, dynamic>))
        .whereType<SportEventEntity>()
        .toList();
  }

  SportEventEntity? _parseEvent(SportType sport, Map<String, dynamic> json) {
    try {
      switch (sport) {
        case SportType.football:
          return _parseFootball(json);
        case SportType.tennis:
          return _parseTennis(json);
        case SportType.basketball:
          return _parseBasketball(json);
      }
    } catch (_) {
      // Skip malformed events.
      return null;
    }
  }

  // ── Football ──────────────────────────────────────────────────────

  SportEventEntity _parseFootball(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>? ?? const {};
    final teams = json['teams'] as Map<String, dynamic>? ?? const {};
    final goals = json['goals'] as Map<String, dynamic>? ?? const {};
    final league = json['league'] as Map<String, dynamic>? ?? const {};

    final home = teams['home'] as Map<String, dynamic>? ?? const {};
    final away = teams['away'] as Map<String, dynamic>? ?? const {};

    final statusRaw =
        (fixture['status'] as Map<String, dynamic>? ?? const {})['short']
            ?.toString() ??
        'Scheduled';
    final status = SportEventStatus.fromApi(statusRaw);

    final minuteObj = (fixture['status'] as Map<String, dynamic>? ?? const {});
    // "elapsed" holds the minute for live matches.
    int? minute = (minuteObj['elapsed'] as num?)?.toInt();
    if ((minute ?? 0) == 0 && status.isLive) {
      minute = 1;
    }

    return SportEventEntity(
      id: fixture['id']?.toString() ?? '${DateTime.now().microsecondsSinceEpoch}',
      sport: SportType.football,
      status: status,
      startTime: DateTime.tryParse(
            fixture['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      home: SportCompetitor(
        id: home['id']?.toString() ?? '',
        name: home['name']?.toString() ?? 'Home',
        shortName: home['name']?.toString(),
        logo: home['logo']?.toString(),
        score: (goals['home'] as num?)?.toInt(),
      ),
      away: SportCompetitor(
        id: away['id']?.toString() ?? '',
        name: away['name']?.toString() ?? 'Away',
        shortName: away['name']?.toString(),
        logo: away['logo']?.toString(),
        score: (goals['away'] as num?)?.toInt(),
      ),
      competition: league['name']?.toString(),
      venue: ((fixture['venue'] as Map<String, dynamic>? ?? const {}))['name']
          ?.toString(),
      minute: minute,
      currentPeriod: statusRaw,
      eventDetails: <String, dynamic>{
        'score': {'home': goals['home'], 'away': goals['away']},
      },
      lastUpdated: DateTime.now(),
    );
  }

  // ── Tennis ────────────────────────────────────────────────────────

  SportEventEntity _parseTennis(Map<String, dynamic> json) {
    final players = json['players'] as Map<String, dynamic>? ?? const {};
    final homePlayer = players['home'] as Map<String, dynamic>? ?? const {};
    final awayPlayer = players['away'] as Map<String, dynamic>? ?? const {};
    final game = json['game'] as Map<String, dynamic>? ?? const {};
    final statusShort =
        (game['status'] as Map<String, dynamic>? ?? const {})['short']
            ?.toString() ??
        'Scheduled';

    // scores: each entry is a set, e.g. {"home": 6, "away": 4, "winner": "home"}
    final scores = json['scores'] as List<dynamic>? ?? const [];
    final setsHome = <int>[];
    final setsAway = <int>[];
    for (final s in scores) {
      final map = s as Map<String, dynamic>;
      final h = (map['home'] as num?)?.toInt();
      final a = (map['away'] as num?)?.toInt();
      if (h != null) setsHome.add(h);
      if (a != null) setsAway.add(a);
    }

    final setsWonHome = setsHome.where((g) => g > 0).length;
    // A set is won by the player with the larger game count.
    var setsHomeWon = 0;
    var setsAwayWon = 0;
    for (var i = 0; i < setsHome.length; i++) {
      final h = setsHome[i];
      final a = i < setsAway.length ? setsAway[i] : 0;
      if (h > a) setsHomeWon++;
      if (a > h) setsAwayWon++;
    }

    // Current term (set) games for display.
    final currentSetHome = scores.isNotEmpty ? setsHome.last : null;
    final currentSetAway = scores.isNotEmpty ? setsAway.last : null;

    return SportEventEntity(
      id:
          json['id']?.toString() ?? '${DateTime.now().microsecondsSinceEpoch}',
      sport: SportType.tennis,
      status: SportEventStatus.fromApi(statusShort),
      startTime: DateTime.tryParse(
            game['startTimestamp'] != null
                ? _tsToIso(game['startTimestamp'])
                : '',
          ) ??
          DateTime.now(),
      home: SportCompetitor(
        id: homePlayer['id']?.toString() ?? '',
        name: homePlayer['name']?.toString() ?? 'Player 1',
        logo: homePlayer['photo']?.toString(),
        score: currentSetHome,
        setsWon: setsHomeWon,
      ),
      away: SportCompetitor(
        id: awayPlayer['id']?.toString() ?? '',
        name: awayPlayer['name']?.toString() ?? 'Player 2',
        logo: awayPlayer['photo']?.toString(),
        score: currentSetAway,
        setsWon: setsAwayWon,
      ),
      competition: json['league']?.toString(),
      currentPeriod: 'Set ${setsHome.length.clamp(1, 10)}',
      eventDetails: <String, dynamic>{
        'setsHome': setsHome,
        'setsAway': setsAway,
        'homeCurrentGame': currentSetHome,
        'awayCurrentGame': currentSetAway,
        'statusDetail': statusShort,
      },
      lastUpdated: DateTime.now(),
    );
  }

  // ── Basketball ────────────────────────────────────────────────────

  SportEventEntity _parseBasketball(Map<String, dynamic> json) {
    final teams = json['teams'] as Map<String, dynamic>? ?? const {};
    final scores = json['scores'] as Map<String, dynamic>? ?? const {};
    final statusShort =
        (json['status'] as Map<String, dynamic>? ?? const {})['short']
            ?.toString() ??
        'Scheduled';

    final home = teams['home'] as Map<String, dynamic>? ?? const {};
    final away = teams['away'] as Map<String, dynamic>? ?? const {};

    final homeScore = scores['home'] as Map<String, dynamic>? ?? const {};
    final awayScore = scores['away'] as Map<String, dynamic>? ?? const {};

    int? homeTotal = (homeScore['total'] as num?)?.toInt();
    int? awayTotal = (awayScore['total'] as num?)?.toInt();
    homeTotal ??= (homeScore['points'] as num?)?.toInt();
    awayTotal ??= (awayScore['points'] as num?)?.toInt();

    // Quarter-by-quarter lines.
    final homeQuarters = <int>[];
    final awayQuarters = <int>[];
    const quarterKeys = ['quarter_1', 'quarter_2', 'quarter_3', 'quarter_4'];
    for (final key in quarterKeys) {
      final h = (homeScore[key] as num?)?.toInt();
      final a = (awayScore[key] as num?)?.toInt();
      if (h != null) homeQuarters.add(h);
      if (a != null) awayQuarters.add(a);
    }

    int? currentQuarter;
    final periodObj = json['period'] as Map<String, dynamic>? ?? const {};
    currentQuarter = (periodObj['current'] as num?)?.toInt();
    if (currentQuarter == null) {
      // Fall back to count of quarters played so far.
      currentQuarter = homeQuarters.length.clamp(1, 4);
    }

    return SportEventEntity(
      id: json['id']?.toString() ?? '${DateTime.now().microsecondsSinceEpoch}',
      sport: SportType.basketball,
      status: SportEventStatus.fromApi(statusShort),
      startTime: DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      home: SportCompetitor(
        id: home['id']?.toString() ?? '',
        name: home['name']?.toString() ?? 'Home',
        shortName: home['code']?.toString(),
        logo: home['logo']?.toString(),
        score: homeTotal,
      ),
      away: SportCompetitor(
        id: away['id']?.toString() ?? '',
        name: away['name']?.toString() ?? 'Away',
        shortName: away['code']?.toString(),
        logo: away['logo']?.toString(),
        score: awayTotal,
      ),
      competition: json['league']?.toString(),
      currentPeriod: 'Q$currentQuarter',
      eventDetails: <String, dynamic>{
        'homeQuarters': homeQuarters,
        'awayQuarters': awayQuarters,
        'period': currentQuarter,
      },
      lastUpdated: DateTime.now(),
    );
  }

  String _tsToIso(Object? ts) {
    final t = DateTime.fromMillisecondsSinceEpoch(
      ((ts as num?)?.toInt() ?? 0) * 1000,
    );
    return t.toIso8601String();
  }
}

