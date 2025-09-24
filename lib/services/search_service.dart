import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/search_news.dart';

class SearchService {
  Future<List<NewsArticle>> searchNews(String query,
      {String region = "all"}) async {
    final String jsonString =
        await rootBundle.loadString('assets/dummy_news/news.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List articles = data['articles'] ?? [];
    // Filter by query and optionally by region (if you add region field)
    return articles.map((json) => NewsArticle.fromJson(json)).where((article) {
      final matchesQuery = query.isEmpty ||
          article.title.toLowerCase().contains(query.toLowerCase()) ||
          article.description.toLowerCase().contains(query.toLowerCase());
      // If you add region field, filter here
      return matchesQuery;
    }).toList();
  }
}

Future<List<NewsArticle>> loadDummyNews() async {
  final String jsonString =
      await rootBundle.loadString('assets/dummy_news/news.json');
  final Map<String, dynamic> data = json.decode(jsonString);
  final List articles = data['articles'] ?? [];
  return articles.map((json) => NewsArticle.fromJson(json)).toList();
}
