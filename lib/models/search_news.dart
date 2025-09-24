bool isNetworkImage(String url) {
  return url.startsWith('http://') || url.startsWith('https://');
}

class NewsArticle {
  final String urlToImage;
  final String url;
  final String content;
  final String? region;
  final bool isTrending;
  final bool isMeme;

  NewsArticle({
    required this.urlToImage,
    required this.url,
    required this.content,
    required this.region,
    this.isTrending = false,
    this.isMeme = false,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      urlToImage: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      content: json['content'] ?? '',
      region: json['region'],
      isTrending: json['isTrending'] ?? false,
      isMeme: json['isMeme'] ?? false,
    );
  }

  // For NewsAPI response
  factory NewsArticle.fromNewsApi(Map<String, dynamic> json, String region) {
    return NewsArticle(
      urlToImage: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      content: json['content'] ?? '',
      region: region,
      isTrending: false,
      isMeme: false,
    );
  }
}
