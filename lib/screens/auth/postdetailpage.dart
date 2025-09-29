import 'package:flutter/material.dart';
import 'package:untarest_app/models/search_news.dart';

class PostDetailPage extends StatefulWidget {
  final NewsArticle article; // <-- Add this

  const PostDetailPage({super.key, required this.article}); // <-- Add required

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int likes = 3700;
  bool isLiked = false;
  bool isSaved = false;

  List<String> comments = [
    "user123: Omagaa",
    "user223: Ini baru contoh tampilan",
  ];

  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.article.content)), // Use news title
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.article.urlToImage.isNotEmpty
                ? Image.network(
                    widget.article.urlToImage,
                    headers: {
                      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                    },
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.article, size: 100),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.article.content,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(widget.article.content),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                      likes += isLiked ? 1 : -1;
                    });
                  },
                ),
                Text("$likes Likes"),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  onPressed: () {
                    setState(() {
                      isSaved = !isSaved;
                    });
                  },
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Comments:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...comments.map((c) => ListTile(title: Text(c))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(hintText: "Add a comment..."),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      setState(() {
                        comments.add("me: ${_commentController.text}");
                        _commentController.clear();
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
