import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';

/// A generic HTTP client for football data APIs.
///
/// Handles authentication headers, API-key validation, rate limiting,
/// error translation, and retry logic. This is the base of the
/// API abstraction layer, allowing different providers to share the
/// same transport and error-handling behaviour.
class FootballApiClient {
  FootballApiClient({
    http.Client? client,
    String? baseUrl,
    String? apiKey,
    this.providerName = 'football-data.org',
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.footballDataBaseUrl,
        _apiKey = apiKey ?? AppConfig.footballDataApiKey;

  final http.Client _client;
  final String _baseUrl;
  final String _apiKey;
  final String providerName;

  static const _maxRetries = 2;

  /// Guards against an unconfigured API key.
  void _guardApiKey() {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_FOOTBALL_DATA_API_KEY') {
      throw const NetworkException(
        'Football API key not configured. Follow SETUP.md to obtain and set '
        'your free API key from https://www.football-data.org/client/register',
      );
    }
  }

  /// Performs a GET request and returns the decoded JSON map.
  ///
  /// Retries the request up to [_maxRetries] times on transient network
  /// errors before surfacing a [NetworkException].
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    _guardApiKey();

    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _client.get(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'X-Auth-Token': _apiKey,
          },
        );
        return _handleResponse(response);
      } on SocketException {
        if (attempt == _maxRetries) {
          throw const NetworkException(
            'Cannot connect to the football data service. Check your internet connection.',
          );
        }
        await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));
      } on TimeoutException {
        if (attempt == _maxRetries) {
          throw const NetworkException(
            'The football data service timed out. Please try again.',
          );
        }
      }
    }
    throw const NetworkException('Unable to reach the football data service.');
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
      return <String, dynamic>{};
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
  }
}
