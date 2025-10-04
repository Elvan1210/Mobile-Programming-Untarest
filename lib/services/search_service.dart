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
          (article.content.toLowerCase().contains(query.toLowerCase())) ||
          (article.title.toLowerCase().contains(query.toLowerCase()));
      
      bool matchesRegion;
      if (region == "all") {
        matchesRegion = true;
      } else if (region.toLowerCase() == "global") {
        // Global region shows trending posts with region: Global
        matchesRegion = article.region?.toLowerCase() == "global" && article.isTrending;
      } else {
        matchesRegion = article.region?.toLowerCase() == region.toLowerCase();
      }
      
      return matchesQuery && matchesRegion;
    }).toList();
  }
  
  // Get trending news for Global region
  Future<List<NewsArticle>> getTrendingNews() async {
    return searchNews("", region: "global");
  }
  
  // Get available regions from news data
  Future<List<String>> getAvailableRegions() async {
    final String jsonString =
        await rootBundle.loadString('assets/dummy_news/news.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List articles = data['articles'] ?? [];
    
    final Set<String> regions = {};
    for (var article in articles) {
      if (article['region'] != null) {
        regions.add(article['region']);
      }
    }
    
    final List<String> regionsList = regions.toList();
    regionsList.sort();
    
    // Ensure Global is at the beginning, but don't add if it already exists
    if (regionsList.contains("Global")) {
      regionsList.remove("Global");
    }
    regionsList.insert(0, "Global");
    
    return regionsList;
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
