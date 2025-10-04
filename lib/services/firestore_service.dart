import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream controller for profile updates notification
  static final StreamController<String> _profileUpdateController =
      StreamController<String>.broadcast();
  
  static Stream<String> get profileUpdateStream => _profileUpdateController.stream;
  
  String? get currentUserId => _auth.currentUser?.uid;

  
  Stream<DocumentSnapshot> getSingleUserPost(String postId) {
    return _firestore.collection('user_posts').doc(postId).snapshots();
  }

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

  Future<void> syncProfileLocally(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_name', data['namaLengkap'] ?? '');
        await prefs.setString('profile_nim', data['nim'] ?? '');
        await prefs.setString('profile_username', data['username'] ?? '');
        await prefs.setString(
            'profile_image_url', data['profileImageUrl'] ?? '');
      }
    }
  }
  
  // Get local profile image path
  Future<String?> getLocalProfileImagePath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_$userId');
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        return path;
      }
    }
    return null;
  }

  // Enhanced method for complete profile synchronization
  Future<Map<String, dynamic>?> getCompleteUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('Error getting complete user profile: $e');
    }
    return null;
  }

  // Update profile image immediately and trigger updates
  Future<void> updateProfileImageImmediately(String userId, String? imageUrl) async {
    try {
      // Update SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      if (imageUrl != null) {
        await prefs.setString('profile_image_url', imageUrl);
      }
      
      // Trigger profile update stream
      _profileUpdateController.add(userId);
      
      debugPrint('Profile image updated immediately for user: $userId');
    } catch (e) {
      debugPrint('Error updating profile image immediately: $e');
    }
  }

  // Method to update profile data and sync everywhere
  Future<String?> updateProfileAndSync({
    required String userId,
    required String name,
    required String nim,
    required String username,
    String? imageUrl,
  }) async {
    try {
      // Validate username if changed
      final currentData = await getCompleteUserProfile(userId);
      final currentUsername = currentData?['username']?.toString() ?? '';
      
      if (username.toLowerCase() != currentUsername.toLowerCase()) {
        if (await isUsernameTaken(username, excludeUserId: userId)) {
          return 'Username sudah digunakan oleh akun lain.';
        }
      }
      
      // Validate NIM if changed
      final currentNim = currentData?['nim']?.toString() ?? '';
      if (nim != currentNim) {
        if (await isNimTaken(nim, excludeUserId: userId)) {
          return 'NIM sudah terdaftar.';
        }
      }
      
      // Update Firestore
      await _firestore.collection('users').doc(userId).set({
        'namaLengkap': name,
        'nim': nim,
        'username': username.toLowerCase(),
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Sync to local storage
      await syncProfileLocally(userId);
      
      // Notify all listeners about profile update
      _profileUpdateController.add(userId);
      
      return null; // Success
    } catch (e) {
      return 'Gagal memperbarui profil: $e';
    }
  }

  Future<void> addUserPostComment(String postId, String commentText) async {
    if (currentUserId == null || commentText.trim().isEmpty) return;

    final userDoc = await getUserData(currentUserId!);
    final username =
        (userDoc.data() as Map<String, dynamic>?)?['username'] ?? 'unknown';

    await _firestore
        .collection('user_posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': currentUserId,
      'username': username,
      'text': commentText.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    _firestore
        .collection('user_posts')
        .doc(postId)
        .update({'commentCount': FieldValue.increment(1)});
  }

  Stream<QuerySnapshot> getUserPostComments(String postId) {
    return _firestore
        .collection('user_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore
        .collection('user_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> streamUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  Future<bool> isNimTaken(String nim, {String? excludeUserId}) async {
    final query = _firestore
        .collection('users')
        .where('nim', isEqualTo: nim)
        .limit(2); // Get 2 to check if there are other users
    
    final result = await query.get();
    
    if (excludeUserId != null) {
      // Filter out the current user
      final otherUsers = result.docs.where((doc) => doc.id != excludeUserId);
      return otherUsers.isNotEmpty;
    }
    
    return result.docs.isNotEmpty;
  }


  // Extract hashtags from text
  List<String> extractHashtags(String text) {
    final RegExp hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!.toLowerCase()).toList();
  }

  // Search user posts by hashtag
  Future<QuerySnapshot> searchUserPostsByHashtag(String hashtag) {
    return _firestore
        .collection('user_posts')
        .where('hashtags', arrayContains: hashtag.toLowerCase())
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
  }

  // Search user posts by text (including hashtags)
  Future<List<DocumentSnapshot>> searchUserPostsByText(String query) async {
    final queryLower = query.toLowerCase();
    
    // If query starts with #, search by hashtag
    if (queryLower.startsWith('#')) {
      final result = await searchUserPostsByHashtag(queryLower);
      return result.docs;
    }
    
    // Otherwise search in description and hashtags
    final results = await _firestore
        .collection('user_posts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    
    return results.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final description = (data['description'] ?? '').toString().toLowerCase();
      final hashtags = List<String>.from(data['hashtags'] ?? []);
      
      return description.contains(queryLower) || 
             hashtags.any((tag) => tag.contains(queryLower));
    }).toList();
  }

  // Get trending hashtags
  Future<List<String>> getTrendingHashtags({int limit = 10}) async {
    try {
      final result = await _firestore
          .collection('hashtag_counts')
          .orderBy('count', descending: true)
          .limit(limit)
          .get();
      
      return result.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting trending hashtags: $e');
      // Return some default trending hashtags if Firestore access fails
      return ['#photo', '#travel', '#food', '#nature', '#life', '#love', '#beautiful', '#happy', '#art', '#style'];
    }
  }

  // Update hashtag counts
  Future<void> _updateHashtagCounts(List<String> hashtags) async {
    try {
      final batch = _firestore.batch();
      
      for (String hashtag in hashtags) {
        final hashtagRef = _firestore.collection('hashtag_counts').doc(hashtag);
        batch.set(hashtagRef, {
          'count': FieldValue.increment(1),
          'lastUsed': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error updating hashtag counts (permission issue - continuing): $e');
      // Continue without failing the upload if hashtag counting fails
    }
  }

  Future<void> uploadPost({
    required File imageFile,
    required String description,
  }) async {
    if (currentUserId == null) throw Exception("User tidak login.");
    try {
      final userDoc = await getUserData(currentUserId!);
      final username = (userDoc.data() as Map<String, dynamic>?)?['username'] ??
          'unknown_user';

      final cloudinary =
          CloudinaryPublic('da2cimmel', 'untarest-mobprog-app', cache: false);

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path,
            resourceType: CloudinaryResourceType.Image),
      );

      final String downloadUrl = response.secureUrl;
      
      // Extract hashtags from description
      final hashtags = extractHashtags(description);

      await _firestore.collection('user_posts').add({
        'userId': currentUserId,
        'username': username,
        'imageUrl': downloadUrl,
        'description': description,
        'hashtags': hashtags, // Add hashtags array
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'commentCount': 0,
      });
      
      // Update hashtag counts for trending
      if (hashtags.isNotEmpty) {
        await _updateHashtagCounts(hashtags);
      }
    } catch (e) {
      debugPrint('Error uploading post to Cloudinary: $e');
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
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(userIdToFollow)
        .set({});
    await _firestore
        .collection('users')
        .doc(userIdToFollow)
        .collection('followers')
        .doc(currentUserId)
        .set({});
  }

  Future<void> unfollowUser(String userIdToUnfollow) async {
    if (currentUserId == null) return;
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(userIdToUnfollow)
        .delete();
    await _firestore
        .collection('users')
        .doc(userIdToUnfollow)
        .collection('followers')
        .doc(currentUserId)
        .delete();
  }

  Future<bool> isFollowing(String otherUserId) async {
    if (currentUserId == null) return false;
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(otherUserId)
        .get();
    return doc.exists;
  }

  Stream<int> getFollowersCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> getFollowingCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Future<void> addComment(String articleUrl, String commentText) async {
    if (currentUserId == null) return;
    if (commentText.trim().isEmpty) return;
    final postId = _getPostId(articleUrl);
    final postRef = _firestore.collection('posts').doc(postId);
    try {
      final userDoc = await getUserData(currentUserId!);
      final username = (userDoc.data() as Map<String, dynamic>?)?['username'] ??
          'user_gagal';
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
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user data: $e');
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
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  Future<bool> isUsernameTaken(String username, {String? excludeUserId}) async {
    final query = _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(2); // Get 2 to check if there are other users
    
    final result = await query.get();
    
    if (excludeUserId != null) {
      // Filter out the current user
      final otherUsers = result.docs.where((doc) => doc.id != excludeUserId);
      return otherUsers.isNotEmpty;
    }
    
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
      debugPrint('Error getting email from username: $e');
      return null;
    }
  }

  String _getPostId(String articleUrl) {
    return articleUrl.hashCode.abs().toString();
  }

  Future<void> toggleLike(String articleUrl, {String? imageUrl, String? content, String? title}) async {
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
          // Store complete article information for liked posts
          transaction.set(userLikeRef, {
            'postId': postId,
            'articleUrl': articleUrl,
            'imageUrl': imageUrl ?? '',
            'content': content ?? '',
            'title': title ?? 'Liked Post',
            'timestamp': FieldValue.serverTimestamp(),
          });
          if (postDoc.exists) {
            final currentLikes = postDoc.data()?['likes'] ?? 0;
            transaction.update(postRef, {'likes': currentLikes + 1});
          } else {
            transaction.set(postRef, {
              'postId': postId,
              'articleUrl': articleUrl,
              'imageUrl': imageUrl,
              'content': content,
              'title': title,
              'likes': 1,
              'saves': 0,
              'commentCount': 0,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
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

  Stream<bool> isLikedStream(String articleUrl) {
    if (currentUserId == null) return Stream.value(false);
    final postId = _getPostId(articleUrl);
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('likedPosts')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<int> getLikesCount(String articleUrl) {
    final postId = _getPostId(articleUrl);
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.data()?['likes'] ?? 0);
  }

  Future<void> toggleSave(
      String articleUrl, String imageUrl, String content) async {
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
      debugPrint('Error toggling save: $e');
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

  Stream<QuerySnapshot> getLikedPosts() {
    if (currentUserId == null) return Stream.empty();
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('likedPosts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

Future<void> syncProfileLocally(String userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  if (doc.exists) {
    final data = doc.data();
    if (data != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', data['namaLengkap'] ?? '');
      await prefs.setString('profile_nim', data['nim'] ?? '');
      await prefs.setString('profile_username', data['username'] ?? '');
      await prefs.setString('profile_image_url', data['profileImageUrl'] ?? '');
    }
  }
}
