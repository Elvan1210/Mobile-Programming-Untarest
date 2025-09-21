import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/search_news.dart';

class SearchService {
  final String _apiKey = "bad89c41c7e43eab792aac37e58d0768";
  bool dummyNews = true; //toggle dummy news

  Future<List<NewsArticle>> searchNews(String query) async {
    if (dummyNews) {
      final jsonString =
          await rootBundle.loadString("assets/dummy_news/news.json");
      final data = json.decode(jsonString);
      final List articles = data['articles'];
      return articles.map((json) => NewsArticle.fromJson(json)).toList();
    }

    //ini untuk kalau pake API News yg asli,bkn dummy
    final url = Uri.parse(
      "https://gnews.io/api/v4/search?q=$query&lang=id&token=$_apiKey",
    );

    final response = await http.get(url);
    debugPrint("API Response status: ${response.statusCode}");
    debugPrint("API Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint(data.toString());
      final List articles = data['articles'];
      return articles.map((json) => NewsArticle.fromJson(json)).toList();
    } else {
      throw Exception("Gagal memuat trend");
    }
  }
}


Future<List<NewsArticle>> loadDummyNews() async{
  final String response = await rootBundle.loadString('assets/dummy_news/news.json');
  final data = jsonDecode(response);
  final List articles = data['articles'];
  return articles.map((e)=> NewsArticle.fromJson(e)).toList();
}