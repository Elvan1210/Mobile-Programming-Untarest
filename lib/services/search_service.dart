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
      return await loadDummyNews();
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

Future<List<NewsArticle>> loadDummyNews() async {
  // Data dummy yang sudah disesuaikan dengan nama file gambar Anda.
  final List<Map<String, dynamic>> dummyData = [
    {
      "title": "PREZIDEN UNTAR",
      "description": "Joget di sidang senat naik..",
      "image": "assets/images/img1_dummy.png"
    },
    {
      "title": "IT Girl Average Behaviour",
      "description": "IVE: Jang Won Young viral karena makan stroberi lucu",
      "image": "assets/images/img2_dummy.png"
    },
    {
      "title": "Naik Gaji Uhuy!",
      "description": "Indonesia: ... naik gaji 3 juta per hari",
      "image": "assets/images/img3_dummy.png"
    },
    {
      "title": "TBBT's Bernadette And Amy",
      "description": "Sistem pertemanan Bernadette dan Amy yang..",
      "image": "assets/images/img4_dummy.png"
    }
  ];

  return dummyData.map((json) {
    return NewsArticle(
      title: json['title']!,
      description: json['description']!,
      urlToImage: json['image']!,
      url: ""
    );
  }).toList();
}