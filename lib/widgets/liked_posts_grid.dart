import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

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
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada foto yang disukai!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Ambil daftar artikel yang disukai dari likedPosts collection
        final likedPostsData = likedSnapshot.data!.docs;
        final List<NewsArticle> likedArticles = [];
        
        for (var doc in likedPostsData) {
          final data = doc.data() as Map<String, dynamic>;
          // Create NewsArticle from stored liked post data
          likedArticles.add(NewsArticle(
            urlToImage: data['imageUrl'] ?? '',
            url: data['articleUrl'] ?? '',
            content: data['content'] ?? '',
            title: data['title'] ?? 'Liked Post',
            region: data['region'] ?? '',
          ));
        }

        return _buildInteractiveGrid(likedArticles, context);
      },
    );
  }

  Widget _buildInteractiveGrid(List<NewsArticle> articles, BuildContext context) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada artikel yang disukai",
          style: TextStyle(
            fontFamily: "Poppins", 
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(10),
      shrinkWrap: false, // Allow scrolling
      physics: const BouncingScrollPhysics(), // Enable scrolling
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildArticleCard(article, context);
      },
    );
  }

  Widget _buildArticleCard(NewsArticle article, BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailPage(article: article),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(article),
          ),
        ),
        // Three dots menu
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: (value) => _handleMenuAction(value, article, context),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Download', style: TextStyle(fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'unlike',
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Unlike', style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_border, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Save', style: TextStyle(fontFamily: 'Poppins', color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom actions overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<bool>(
                  stream: FirestoreService().isLikedStream(article.url),
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () => FirestoreService().toggleLike(
                        article.url,
                        imageUrl: article.urlToImage,
                        content: article.content,
                        title: article.title,
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => _showCommentDialog(article, context),
                  child: const Icon(
                    Icons.comment_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                StreamBuilder<bool>(
                  stream: FirestoreService().isSavedStream(article.url),
                  builder: (context, snapshot) {
                    final isSaved = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () => FirestoreService().toggleSave(
                        article.url,
                        article.urlToImage,
                        article.content,
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.yellow : Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(NewsArticle article) {
    if (article.urlToImage.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 40),
      );
    }

    final bool isNetworkImage = article.urlToImage.startsWith("http://") ||
        article.urlToImage.startsWith("https://");

    if (isNetworkImage) {
      return Image.network(
        article.urlToImage,
        fit: BoxFit.cover,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.asset(
        article.urlToImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      );
    }
  }

  void _handleMenuAction(String action, NewsArticle article, BuildContext context) {
    switch (action) {
      case 'download':
        _downloadImage(article, context);
        break;
      case 'unlike':
        FirestoreService().toggleLike(
          article.url,
          imageUrl: article.urlToImage,
          content: article.content,
          title: article.title,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from liked posts')),
        );
        break;
      case 'save':
        FirestoreService().toggleSave(article.url, article.urlToImage, article.content);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to saved posts')),
        );
        break;
    }
  }

  Future<void> _downloadImage(NewsArticle article, BuildContext context) async {
    try {
      // Check if permission is granted
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      Uint8List imageBytes;
      
      // Check if it's a network image or local asset
      final bool isNetworkImage = article.urlToImage.startsWith("http://") ||
          article.urlToImage.startsWith("https://");
      
      if (isNetworkImage) {
        // Download from network
        final dio = Dio();
        final response = await dio.get(
          article.urlToImage,
          options: Options(responseType: ResponseType.bytes),
        );
        imageBytes = Uint8List.fromList(response.data);
      } else {
        // Load from local assets
        final bundle = DefaultAssetBundle.of(context);
        final data = await bundle.load(article.urlToImage);
        imageBytes = data.buffer.asUint8List();
      }

      // Save to gallery using Gal
      await Gal.putImageBytes(
        imageBytes,
        album: 'Untarest',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image downloaded successfully!',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to download image: $e',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCommentDialog(NewsArticle article, BuildContext context) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment', style: TextStyle(fontFamily: 'Poppins')),
        content: TextField(
          controller: commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write a comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                FirestoreService().addComment(article.url, commentController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment added!')),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
