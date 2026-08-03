import '../entities/article_entity.dart';

/// Data model for a news article, mapped from the API.
class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.publishedAt,
    this.source,
    this.imageUrl,
    this.url,
    this.category,
  });

  final String id;
  final String title;
  final String summary;
  final DateTime publishedAt;
  final String? source;
  final String? imageUrl;
  final String? url;
  final String? category;

  /// Parses an article from a generic news API response.
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: (json['id'] ?? json['uuid'] ?? json['title'] ?? '').toString(),
      title: json['title'] as String? ?? 'Untitled',
      summary: json['summary'] ??
          json['description'] ??
          json['body'] ??
          'No summary available.',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ??
              json['published_at'] as String? ??
              '') ??
          DateTime.now(),
      source: json['source']?.toString(),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['urlToImage'],
      url: json['url']?.toString(),
      category: json['category']?.toString(),
    );
  }

  /// Converts to a domain entity.
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      title: title,
      summary: summary.toString(),
      publishedAt: publishedAt,
      source: source,
      imageUrl: imageUrl,
      url: url,
      category: category,
    );
  }
}
