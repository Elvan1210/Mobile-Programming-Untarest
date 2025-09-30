import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../models/search_news.dart';

class SearchService {
  final String _apiKey = '0702315d93b4449da653d0ea0531bfef';

  Future<List<NewsArticle>> searchNews(String query,
      {String region = "all"}) async {
    // Load dummy news
    final String jsonString =
        await rootBundle.loadString('assets/dummy_news/news.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List articles = data['articles'] ?? [];
    return articles.map((json) => NewsArticle.fromJson(json)).where((article) {
      final matchesQuery = query.isEmpty ||
          (article.content.toLowerCase().contains(query.toLowerCase()));
      final matchesRegion = region == "all" ||
          (article.region?.toLowerCase() == region.toLowerCase());
      return matchesQuery && matchesRegion;
    }).toList();
  }

  String _regionToCountry(String region) {
    switch (region.toLowerCase()) {
      case 'indonesia':
        return 'id';
      case 'usa':
        return 'us';
      case 'world':
      case 'all':
      default:
        return 'id'; // Default to Indonesia
    }
  }
}
