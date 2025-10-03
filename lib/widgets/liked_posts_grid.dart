import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/widgets/news_feed_grid.dart';

class LikedPostsGrid extends StatelessWidget {
  const LikedPostsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil daftar ID postingan yang disukai dari koleksi 'likedPosts'
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getLikedPosts(),
      builder: (context, likedSnapshot) {
        if (likedSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (likedSnapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
        }
        if (!likedSnapshot.hasData || likedSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada foto yang disukai!',
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

        // Ambil daftar postId dari likedPosts.
        final likedPostIds = likedSnapshot.data!.docs.map((doc) => doc.id).toList();

        // 2. Gunakan postId untuk mengambil data lengkap dari koleksi 'posts' utama.
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where(FieldPath.documentId, whereIn: likedPostIds)
              .snapshots(),
          builder: (context, postsSnapshot) {
            if (postsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (postsSnapshot.hasError) {
              return const Center(child: Text('Terjadi kesalahan saat memuat postingan.'));
            }
            if (!postsSnapshot.hasData || postsSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Postingan yang disukai tidak ditemukan.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              );
            }

            final postsDocs = postsSnapshot.data!.docs;
            final List<NewsArticle> likedArticles = postsDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return NewsArticle(
                urlToImage: data['urlToImage'] ?? '',
                url: data['articleUrl'] ?? '',
                content: data['content'] ?? '',
                title: data['title'] ?? '',
                region: '',
              );
            }).toList();

            return NewsFeedGrid(articles: likedArticles);
          },
        );
      },
    );
  }
}