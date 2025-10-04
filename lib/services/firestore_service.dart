import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // --- FUNGSI BARU UNTUK INTERAKSI POST PENGGUNA ---

  // Mengambil data satu post secara real-time
  Stream<DocumentSnapshot> getSingleUserPost(String postId) {
    return _firestore.collection('user_posts').doc(postId).snapshots();
  }

  // Toggle like pada post pengguna
  Future<void> toggleUserPostLike(String postId) async {
    if (currentUserId == null) return;
    final postRef = _firestore.collection('user_posts').doc(postId);

    final postDoc = await postRef.get();
    if (postDoc.exists) {
      List likes = (postDoc.data()! as Map<String, dynamic>)['likes'] ?? [];
      if (likes.contains(currentUserId)) {
        postRef.update({
          'likes': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        postRef.update({
          'likes': FieldValue.arrayUnion([currentUserId])
        });
      }
    }
  }

  // Menambahkan komentar pada post pengguna
  Future<void> addUserPostComment(String postId, String commentText) async {
    if (currentUserId == null || commentText.trim().isEmpty) return;
    
    final userDoc = await getUserData(currentUserId!);
    final username = (userDoc.data() as Map<String, dynamic>?)?['username'] ?? 'unknown';

    await _firestore.collection('user_posts').doc(postId).collection('comments').add({
      'userId': currentUserId,
      'username': username,
      'text': commentText.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Update jumlah komentar
    _firestore.collection('user_posts').doc(postId).update({
      'commentCount': FieldValue.increment(1)
    });
  }

  // Mengambil semua komentar dari sebuah post pengguna
  Stream<QuerySnapshot> getUserPostComments(String postId) {
    return _firestore
        .collection('user_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- KODE LAMA KAMU DIMULAI DARI SINI (TIDAK ADA YANG DIHAPUS) ---

  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore
        .collection('user_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> uploadPost({
    required File imageFile,
    required String description,
  }) async {
    if (currentUserId == null) throw Exception("User tidak login.");
    try {
      final userDoc = await getUserData(currentUserId!);
      final username = (userDoc.data() as Map<String, dynamic>?)?['username'] ?? 'unknown_user';
      
      final cloudinary = CloudinaryPublic(
        'da2cimmel',
        'untarest-mobprog-app',
        cache: false
      );

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );

      final String downloadUrl = response.secureUrl;

      await _firestore.collection('user_posts').add({
        'userId': currentUserId,
        'username': username,
        'imageUrl': downloadUrl,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [], 
        'commentCount': 0,
      });

    } catch (e) {
      print('Error uploading post to Cloudinary: $e');
      rethrow;
    }
  }
  
  Future<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  Future<QuerySnapshot> searchUsers(String query) async {
    if (query.isEmpty) {
      return _firestore.collection('users').limit(0).get();
    }
    return _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('username', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
        .limit(10)
        .get();
  }
  
  Future<void> followUser(String userIdToFollow) async {
    if (currentUserId == null) return;
    await _firestore.collection('users').doc(currentUserId).collection('following').doc(userIdToFollow).set({});
    await _firestore.collection('users').doc(userIdToFollow).collection('followers').doc(currentUserId).set({});
  }

  Future<void> unfollowUser(String userIdToUnfollow) async {
    if (currentUserId == null) return;
    await _firestore.collection('users').doc(currentUserId).collection('following').doc(userIdToUnfollow).delete();
    await _firestore.collection('users').doc(userIdToUnfollow).collection('followers').doc(currentUserId).delete();
  }

  Future<bool> isFollowing(String otherUserId) async {
    if (currentUserId == null) return false;
    final doc = await _firestore.collection('users').doc(currentUserId).collection('following').doc(otherUserId).get();
    return doc.exists;
  }

  Stream<int> getFollowersCount(String userId) {
    return _firestore.collection('users').doc(userId).collection('followers').snapshots().map((snapshot) => snapshot.size);
  }

  Stream<int> getFollowingCount(String userId) {
    return _firestore.collection('users').doc(userId).collection('following').snapshots().map((snapshot) => snapshot.size);
  }

  Future<void> addComment(String articleUrl, String commentText) async {
    if (currentUserId == null) return;
    if (commentText.trim().isEmpty) return;
    final postId = _getPostId(articleUrl);
    final postRef = _firestore.collection('posts').doc(postId);
    try {
      final userDoc = await getUserData(currentUserId!);
      final username = (userDoc.data() as Map<String, dynamic>?)?['username'] ?? 'user_gagal';
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        final commentRef = postRef.collection('comments').doc();
        transaction.set(commentRef, {
          'userId': currentUserId,
          'username': username,
          'text': commentText.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
        if (postDoc.exists) {
          final currentCount = postDoc.data()?['commentCount'] ?? 0;
          transaction.update(postRef, {'commentCount': currentCount + 1});
        } else {
          transaction.set(postRef, {
            'postId': postId, 'articleUrl': articleUrl, 'likes': 0, 'saves': 0,
            'commentCount': 1, 'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> createUserDocument({ required User user, required String username, }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid, 'username': username.toLowerCase(), 'email': user.email,
        'namaLengkap': '', 'nim': '', 'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final result = await _firestore.collection('users').where('username', isEqualTo: username.toLowerCase()).limit(1).get();
    return result.docs.isNotEmpty;
  }

  Future<String?> getEmailFromUsername(String username) async {
    try {
      final result = await _firestore.collection('users').where('username', isEqualTo: username.toLowerCase()).limit(1).get();
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
    final userLikeRef = _firestore.collection('users').doc(currentUserId).collection('likedPosts').doc(postId);
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
          transaction.set(userLikeRef, {'postId': postId, 'articleUrl': articleUrl, 'timestamp': FieldValue.serverTimestamp(),});
          if (postDoc.exists) {
            final currentLikes = postDoc.data()?['likes'] ?? 0;
            transaction.update(postRef, {'likes': currentLikes + 1});
          } else {
            transaction.set(postRef, {'postId': postId, 'articleUrl': articleUrl, 'likes': 1, 'saves': 0, 'commentCount': 0, 'createdAt': FieldValue.serverTimestamp(),});
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
    final doc = await _firestore.collection('users').doc(currentUserId).collection('likedPosts').doc(postId).get();
    return doc.exists;
  }

  Stream<int> getLikesCount(String articleUrl) {
    final postId = _getPostId(articleUrl);
    return _firestore.collection('posts').doc(postId).snapshots().map((doc) => doc.data()?['likes'] ?? 0);
  }

  Future<void> toggleSave(String articleUrl, String imageUrl, String content) async {
    if (currentUserId == null) return;
    final postId = _getPostId(articleUrl);
    final postRef = _firestore.collection('posts').doc(postId);
    final userSaveRef = _firestore.collection('users').doc(currentUserId).collection('savedPosts').doc(postId);
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
          transaction.set(userSaveRef, {'postId': postId, 'articleUrl': articleUrl, 'imageUrl': imageUrl, 'content': content, 'timestamp': FieldValue.serverTimestamp(),});
          if (postDoc.exists) {
            final currentSaves = postDoc.data()?['saves'] ?? 0;
            transaction.update(postRef, {'saves': currentSaves + 1});
          } else {
            transaction.set(postRef, {'postId': postId, 'articleUrl': articleUrl, 'imageUrl': imageUrl, 'content': content, 'likes': 0, 'saves': 1, 'commentCount': 0, 'createdAt': FieldValue.serverTimestamp(),});
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
    final doc = await _firestore.collection('users').doc(currentUserId).collection('savedPosts').doc(postId).get();
    return doc.exists;
  }

  Stream<bool> isSavedStream(String articleUrl) {
    if (currentUserId == null) return Stream.value(false);
    final postId = _getPostId(articleUrl);
    return _firestore.collection('users').doc(currentUserId).collection('savedPosts').doc(postId).snapshots().map((doc) => doc.exists);
  }

  Stream<QuerySnapshot> getComments(String articleUrl) {
    final postId = _getPostId(articleUrl);
    return _firestore.collection('posts').doc(postId).collection('comments').orderBy('timestamp', descending: true).snapshots();
  }

  Stream<int> getCommentsCount(String articleUrl) {
    final postId = _getPostId(articleUrl);
    return _firestore.collection('posts').doc(postId).snapshots().map((doc) => doc.data()?['commentCount'] ?? 0);
  }

  Stream<QuerySnapshot> getSavedPosts() {
    if (currentUserId == null) return Stream.empty();
    return _firestore.collection('users').doc(currentUserId).collection('savedPosts').orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getLikedPosts() {
    if (currentUserId == null) return Stream.empty();
    return _firestore.collection('users').doc(currentUserId).collection('likedPosts').orderBy('timestamp', descending: true).snapshots();
  }
}

