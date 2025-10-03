import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/widgets/news_feed_grid.dart';

class SavedPostsGrid extends StatelessWidget {
  const SavedPostsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Mengambil stream data dari savedPosts
      stream: FirestoreService().getSavedPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada foto yang disimpan!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final savedPostDocs = snapshot.data!.docs;
        final List<NewsArticle> savedArticles = savedPostDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return NewsArticle(
            urlToImage: data['imageUrl'] ?? '',
            url: data['articleUrl'] ?? '',
            content: data['content'] ?? '',
            title: data['title'] ?? '',
            region: data['region'] ?? '',
          );
        }).toList();

        return NewsFeedGrid(articles: savedArticles);
      },
    );
  }
}