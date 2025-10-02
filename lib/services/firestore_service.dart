import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // --- FUNGSI BARU UNTUK UPDATE DATA USER ---
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true)); // Gunakan merge:true agar tidak menimpa data lama
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> createUserDocument({
    required User user,
    required String username,
  }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username.toLowerCase(),
        'email': user.email,
        'namaLengkap': '',
        'nim': '',
        'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<String?> getEmailFromUsername(String username) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        return result.docs.first.data()['email'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting email from username: $e');
      return null;
    }
  }

  String _getPostId(String articleUrl) {
    return articleUrl.hashCode.abs().toString();
  }

  Future<void> toggleLike(String articleUrl) async {
    if (currentUserId == null) return;

    final postId = _getPostId(articleUrl);
    final postRef = _firestore.collection('posts').doc(postId);
    final userLikeRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('likedPosts')
        .doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        final userLikeDoc = await transaction.get(userLikeRef);

        if (userLikeDoc.exists) {
          transaction.delete(userLikeRef);
          if (postDoc.exists) {
            final currentLikes = postDoc.data()?['likes'] ?? 0;
            transaction.update(postRef, {'likes': currentLikes - 1});
          }
        } else {
          transaction.set(userLikeRef, {
            'postId': postId,
            'articleUrl': articleUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });

          if (postDoc.exists) {
            final currentLikes = postDoc.data()?['likes'] ?? 0;
            transaction.update(postRef, {'likes': currentLikes + 1});
          } else {
            transaction.set(postRef, {
              'postId': postId,
              'articleUrl': articleUrl,
              'likes': 1,
              'saves': 0,
              'commentCount': 0,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  Future<bool> isLiked(String articleUrl) async {
    if (currentUserId == null) return false;

    final postId = _getPostId(articleUrl);
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('likedPosts')
        .doc(postId)
        .get();

    return doc.exists;
  }

  Stream<int> getLikesCount(String articleUrl) {
    final postId = _getPostId(articleUrl);
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.data()?['likes'] ?? 0);
  }

  Future<void> toggleSave(String articleUrl, String imageUrl, String content) async {
    if (currentUserId == null) return;

    final postId = _getPostId(articleUrl);
    final postRef = _firestore.collection('posts').doc(postId);
    final userSaveRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('savedPosts')
        .doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        final userSaveDoc = await transaction.get(userSaveRef);

        if (userSaveDoc.exists) {
          transaction.delete(userSaveRef);
          if (postDoc.exists) {
            final currentSaves = postDoc.data()?['saves'] ?? 0;
            transaction.update(postRef, {'saves': currentSaves - 1});
          }
        } else {
          transaction.set(userSaveRef, {
            'postId': postId,
            'articleUrl': articleUrl,
            'imageUrl': imageUrl,
            'content': content,
            'timestamp': FieldValue.serverTimestamp(),
          });

          if (postDoc.exists) {
            final currentSaves = postDoc.data()?['saves'] ?? 0;
            transaction.update(postRef, {'saves': currentSaves + 1});
          } else {
            transaction.set(postRef, {
              'postId': postId,
              'articleUrl': articleUrl,
              'imageUrl': imageUrl,
              'content': content,
              'likes': 0,
              'saves': 1,
              'commentCount': 0,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      print('Error toggling save: $e');
      rethrow;
    }
  }

  Future<bool> isSaved(String articleUrl) async {
    if (currentUserId == null) return false;

    final postId = _getPostId(articleUrl);
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('savedPosts')
        .doc(postId)
        .get();

    return doc.exists;
  }

  Stream<bool> isSavedStream(String articleUrl) {
    if (currentUserId == null) return Stream.value(false);

    final postId = _getPostId(articleUrl);
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('savedPosts')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> addComment(String articleUrl, String commentText) async {
    if (currentUserId == null) return;
    if (commentText.trim().isEmpty) return;

    final postId = _getPostId(articleUrl);
    final postRef = _firestore.collection('posts').doc(postId);
    final user = _auth.currentUser;

    try {
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);

        final commentRef = postRef.collection('comments').doc();
        transaction.set(commentRef, {
          'userId': currentUserId,
          'userEmail': user?.email ?? 'Anonymous',
          'text': commentText.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (postDoc.exists) {
          final currentCount = postDoc.data()?['commentCount'] ?? 0;
          transaction.update(postRef, {'commentCount': currentCount + 1});
        } else {
          transaction.set(postRef, {
            'postId': postId,
            'articleUrl': articleUrl,
            'likes': 0,
            'saves': 0,
            'commentCount': 1,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getComments(String articleUrl) {
    final postId = _getPostId(articleUrl);
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<int> getCommentsCount(String articleUrl) {
    final postId = _getPostId(articleUrl);
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.data()?['commentCount'] ?? 0);
  }

  Stream<QuerySnapshot> getSavedPosts() {
    if (currentUserId == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('savedPosts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

