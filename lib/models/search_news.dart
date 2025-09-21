class NewsArticle {
  final String title;
  final String urlToImage;
  final String url;
  final String description;

  NewsArticle({
    required this.title,
    required this.urlToImage,
    required this.url,
    required this.description,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
        title: json['title'] ?? '',
        urlToImage: json['image'] ?? json['urlToImage'] ?? '',
        url: json['url'] ?? '',
        description: json['description'] ?? '');
  }
}
