import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:untarest_app/models/search_news.dart';

class NewsFeedGrid extends StatelessWidget {
  final List<NewsArticle> articles;

  const NewsFeedGrid({super.key, required this.articles});

  bool isNetworkImage(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada vibes di sini",
          style: TextStyle(fontFamily: "Poppins", fontSize: 16),
        ),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(10),
      shrinkWrap: false,
      physics: const BouncingScrollPhysics(),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return GestureDetector(
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
            child: article.urlToImage.isNotEmpty
                ? (isNetworkImage(article.urlToImage)
                    ? Image.network(
                        article.urlToImage,
                        fit: BoxFit.cover,
                        headers: {
                          'User-Agent':
                              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey);
                        },
                      )
                    : Image.asset(article.urlToImage, fit: BoxFit.cover))
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),
        );
      },
    );
  }
}
