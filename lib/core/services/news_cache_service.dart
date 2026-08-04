import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON cache helper used by the Home feature to cache news articles.
///
/// Uses [SharedPreferences] for lightweight persistence. Keeps a TTL so stale
/// entries are evicted. Works offline and prevents redundant network calls.
class NewsCacheService {
  NewsCacheService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const String _keyPrefix = 'news_cache';
  static const Duration _ttl = Duration(hours: 3);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Caches a list of news article JSON maps under [key].
  Future<void> cacheNews(String key, List<Map<String, dynamic>> articles) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
        '$_keyPrefix:$key',
        jsonEncode({
          'cachedAt': DateTime.now().millisecondsSinceEpoch,
          'articles': articles,
        }),
      );
    } catch (_) {
      // Best-effort cache.
    }
  }

  /// Returns cached news articles if present and not expired.
  Future<List<Map<String, dynamic>>?> getCachedNews(String key) async {
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

      final articles = map['articles'] as List<dynamic>? ?? [];
      return articles
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Clears all cached news.
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
