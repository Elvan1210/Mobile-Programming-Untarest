import 'package:flutter/material.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key});

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
      appBar: AppBar(title: Text("Post Detail")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/poster.png"),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Judul Postingan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      decoration:
                          InputDecoration(hintText: "Add a comment..."),
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
