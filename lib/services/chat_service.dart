import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:untarest_app/models/chat_room_model.dart';
import 'package:untarest_app/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Search users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return [];

      // Fetch all users and filter locally (temporary fix for index issue)
      final querySnapshot = await _firestore
          .collection('users')
          .limit(100) // Limit untuk performa
          .get();

      final users = querySnapshot.docs
          .where((doc) => doc.id != currentUserId) // Exclude current user
          .where((doc) {
            final username = (doc.data()['username'] ?? '').toString().toLowerCase();
            return username.contains(query.toLowerCase());
          })
          .map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'username': data['username'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'profileImageUrl': data['profileImageUrl'],
        };
      }).toList();

      return users;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // Create or get existing chat room
  Future<String> createOrGetChatRoom(
    String otherUserId,
    String otherUsername,
  ) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not logged in');

      // Get current user's username
      final currentUserDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final currentUsername = currentUserDoc.data()?['username'] ?? 'Unknown';

      final chatRoomId = ChatRoom.getChatRoomId(currentUserId, otherUserId);

      final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
      final chatRoomDoc = await chatRoomRef.get();

      if (!chatRoomDoc.exists) {
        // Create new chat room
        await chatRoomRef.set({
          'participants': [currentUserId, otherUserId],
          'participantUsernames': {
            currentUserId: currentUsername,
            otherUserId: otherUsername,
          },
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSenderId': '',
          'unreadCount': {
            currentUserId: 0,
            otherUserId: 0,
          },
        });
      }

      return chatRoomId;
    } catch (e) {
      debugPrint('Error creating/getting chat room: $e');
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage(
    String chatRoomId,
    String receiverId,
    String message, {
    String? imageUrl,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not logged in');

      // Get sender username
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final senderUsername = userDoc.data()?['username'] ?? 'Unknown';

      // Add message to messages subcollection
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'senderUsername': senderUsername,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'imageUrl': imageUrl,
      });

      // Update chat room with last message info
      final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
      final chatRoomDoc = await chatRoomRef.get();
      final currentUnreadCount = chatRoomDoc.data()?['unreadCount'] as Map<String, dynamic>? ?? {};

      await chatRoomRef.update({
        'lastMessage': imageUrl != null ? '📷 Image' : message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUserId,
        'unreadCount': {
          currentUserId: 0,
          receiverId: (currentUnreadCount[receiverId] ?? 0) + 1,
        },
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Get chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    debugPrint('🔍 Getting chat rooms for user: $currentUserId'); // Debug log

    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
      debugPrint('📦 Found ${snapshot.docs.length} chat rooms'); // Debug log
      
      final rooms = snapshot.docs
          .map((doc) {
            try {
              return ChatRoom.fromFirestore(doc);
            } catch (e) {
              debugPrint('❌ Error parsing chat room ${doc.id}: $e');
              return null;
            }
          })
          .whereType<ChatRoom>() // Filter out nulls
          .toList();
      
      // Sort manually by lastMessageTime (descending)
      rooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      return rooms;
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String otherUserId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return;

      // Get unread messages
      final messagesSnapshot = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      // Mark all as read
      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'unreadCount.$currentUserId': 0,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Get unread message count for a chat room
  Future<int> getUnreadCount(String chatRoomId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return 0;

      final chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      final unreadCount = chatRoomDoc.data()?['unreadCount'] as Map<String, dynamic>? ?? {};
      return unreadCount[currentUserId] ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  // Get total unread messages count
  Stream<int> getTotalUnreadCount() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final unreadCount = doc.data()['unreadCount'] as Map<String, dynamic>? ?? {};
        total += (unreadCount[currentUserId] ?? 0) as int;
      }
      return total;
    });
  }

  // Delete chat room (optional feature)
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      // Delete all messages first
      final messagesSnapshot = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete chat room
      await _firestore.collection('chatRooms').doc(chatRoomId).delete();
    } catch (e) {
      debugPrint('Error deleting chat room: $e');
      rethrow;
    }
  }
}