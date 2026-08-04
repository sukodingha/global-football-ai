import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON cache helper for live score / match data.
///
/// Uses [SharedPreferences] for lightweight persistence with a short TTL so
/// the live scores UI can render instantly from cache while fresh data is
/// fetched. Keeps the app usable offline.
class LiveScoresCacheService {
  LiveScoresCacheService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const String _keyPrefix = 'live_scores_cache';
  static const Duration _ttl = Duration(minutes: 5);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Caches a list of match JSON maps under [key].
  Future<void> cacheMatches(
    String key,
    List<Map<String, dynamic>> matches,
  ) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
        '$_keyPrefix:$key',
        jsonEncode({
          'cachedAt': DateTime.now().millisecondsSinceEpoch,
          'matches': matches,
        }),
      );
    } catch (_) {
      // Best-effort cache.
    }
  }

  /// Returns cached matches if present and not expired.
  Future<List<Map<String, dynamic>>?> getCachedMatches(String key) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString('$_keyPrefix:$key');
      if (raw == null) return null;

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = map['cachedAt'] as int? ?? 0;
      if (DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(cachedAt),
      ) > _ttl) {
        await prefs.remove('$_keyPrefix:$key');
        return null;
      }

      final matches = map['matches'] as List<dynamic>? ?? [];
      return matches.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return null;
    }
  }

/// Convenience wrapper caching the default live scores feed.
  Future<void> cacheLiveMatches(List<Map<String, dynamic>> matches) =>
      cacheMatches('live', matches);

  /// Convenience wrapper returning the default live scores feed.
  Future<List<Map<String, dynamic>>?> getCachedLiveMatches() =>
      getCachedMatches('live');

  /// Clears all cached live score data.
  Future<void> clearCache() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith('$_keyPrefix:'))
          .toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (_) {
      // Best-effort clear.
    }
  }
}
