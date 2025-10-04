import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class UserPostDetailPage extends StatefulWidget {
  final String postId;
  const UserPostDetailPage({super.key, required this.postId});

  @override
  State<UserPostDetailPage> createState() => _UserPostDetailPageState();
}

class _UserPostDetailPageState extends State<UserPostDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();

  void _postComment() {
    if (_commentController.text.trim().isNotEmpty) {
      _firestoreService.addUserPostComment(widget.postId, _commentController.text.trim());
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('d MMM y').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}h lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Postingan", style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getSingleUserPost(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text("Postingan ini tidak ditemukan."));
          }
          
          final postData = snapshot.data!.data() as Map<String, dynamic>;
          final List likes = postData['likes'] ?? [];
          final bool isLiked = likes.contains(_firestoreService.currentUserId);
          final timestamp = postData['timestamp'] as Timestamp?;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar
                      Image.network(
                        postData['imageUrl'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: MediaQuery.of(context).size.width,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(color: primaryColor))
                          );
                        },
                      ),
                      
                      // Tombol Aksi (Like, Comment)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.black,
                                size: 28,
                              ),
                              onPressed: () => _firestoreService.toggleUserPostLike(widget.postId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment_outlined, size: 28),
                              onPressed: () => _showCommentsBottomSheet(context),
                            ),
                          ],
                        ),
                      ),
                      
                      // Jumlah Suka
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '${likes.length} suka',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      // Username dan Deskripsi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              TextSpan(
                                text: '${postData['username']} ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: postData['description']),
                            ],
                          ),
                         ),
                      ),
                      
                      // Waktu Post
                      if (timestamp != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _formatTimestamp(timestamp.toDate()),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              const Divider(height: 1),

              // Input Komentar
              Container(
                padding: EdgeInsets.only(
                  left: 16, right: 8, top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    const CircleAvatar(radius: 18, child: Icon(Icons.person)), // Placeholder avatar
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration.collapsed(hintText: 'Tambahkan komentar...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: primaryColor),
                      onPressed: _postComment,
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text("Komentar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getUserPostComments(widget.postId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Belum ada komentar."));
                    }
                    return ListView(
                      controller: controller,
                      children: snapshot.data!.docs.map((doc) {
                        final commentData = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(commentData['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(commentData['text']),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

