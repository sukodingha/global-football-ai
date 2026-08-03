import 'package:equatable/equatable.dart';

/// A football news article.
class ArticleEntity extends Equatable {
  const ArticleEntity({
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

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        publishedAt,
        source,
        imageUrl,
        url,
        category,
      ];
}
