import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/utils/constants.dart';
// --- TAMBAHKAN IMPORT INI ---
import 'package:untarest_app/screens/home/user_post_detail_page.dart';

class UserPostsGrid extends StatelessWidget {
  final String userId;
  const UserPostsGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getUserPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada foto yang di-upload.',
              style: TextStyle(color: Colors.black54, fontFamily: 'Poppins'),
            ),
          );
        }

        final posts = snapshot.data!.docs;

        return MasonryGridView.count(
          padding: const EdgeInsets.all(8),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            final imageUrl = post['imageUrl'];
            // --- AMBIL ID POST ---
            final postId = posts[index].id;

            // --- BUNGKUS DENGAN GESTUREDETECTOR ---
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPostDetailPage(postId: postId),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: Colors.grey[200]);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey));
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

