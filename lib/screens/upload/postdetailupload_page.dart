import 'package:flutter/material.dart';
import 'package:untarest_app/models/search_news.dart';

class PostDetailUploadPage extends StatefulWidget {
  final NewsArticle article;

  const PostDetailUploadPage({super.key, required this.article});

  @override
  State<PostDetailUploadPage> createState() => _PostDetailUploadPageState();
}

class _PostDetailUploadPageState extends State<PostDetailUploadPage> {
  int likes = 0;
  bool isLiked = false;
  bool isSaved = false;

  List<String> comments = [];

  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Upload")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.article.urlToImage.isNotEmpty
                ? Image.network(
                    widget.article.urlToImage,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image,
                          size: 50, color: Colors.grey);
                    },
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.article, size: 100),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.article.content,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.article.url.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(widget.article.url),
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
                  icon: const Icon(Icons.comment),
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
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
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
                      decoration:
                          const InputDecoration(hintText: "Add a comment..."),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      setState(() {
                        if (_commentController.text.isNotEmpty) {
                          comments.add("me: ${_commentController.text}");
                          _commentController.clear();
                        }
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
