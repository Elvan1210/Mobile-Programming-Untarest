import 'package:flutter/material.dart';
import 'package:untarest_app/models/chat_room_model.dart';
import 'package:untarest_app/services/chat_service.dart';
import 'package:untarest_app/screens/chat/search_user_page.dart';
import 'package:untarest_app/screens/chat/chat_room_page.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();

  String _formatLastMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h lalu';
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  void _deleteChatRoom(ChatRoom chatRoom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Chat',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus chat dengan ${chatRoom.getOtherUsername(_chatService.currentUser!.uid)}?',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _chatService.deleteChatRoom(chatRoom.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Chat berhasil dihapus',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor: primaryColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUserPage(),
                ),
              );
            },
            tooltip: 'Cari pengguna',
          ),
        ],
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _chatService.getChatRooms(),
        builder: (context, snapshot) {
          // Debug log
          debugPrint('📱 Chat List - Connection state: ${snapshot.connectionState}');
          debugPrint('📱 Chat List - Has error: ${snapshot.hasError}');
          debugPrint('📱 Chat List - Error: ${snapshot.error}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Force rebuild
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final chatRooms = snapshot.data ?? [];

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai chat dengan mencari pengguna',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchUserPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text(
                      'Cari Pengguna',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[300],
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final currentUserId = _chatService.currentUser!.uid;
              final otherUserId = chatRoom.getOtherUserId(currentUserId);
              final otherUsername = chatRoom.getOtherUsername(currentUserId);
              final unreadCount = chatRoom.unreadCount[currentUserId] ?? 0;

              return Dismissible(
                key: Key(chatRoom.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Hapus Chat',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      content: Text(
                        'Apakah Anda yakin ingin menghapus chat dengan $otherUsername?',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  _chatService.deleteChatRoom(chatRoom.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Chat berhasil dihapus',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: primaryColor,
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryColor,
                    child: Text(
                      otherUsername[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    otherUsername,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: unreadCount > 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    chatRoom.lastMessage.isEmpty
                        ? 'Mulai percakapan'
                        : chatRoom.lastMessage,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: unreadCount > 0
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 60, // Batasi lebar trailing
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatLastMessageTime(chatRoom.lastMessageTime),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: unreadCount > 0
                                ? primaryColor
                                : Colors.grey[500],
                            fontWeight: unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          chatRoomId: chatRoom.id,
                          otherUserId: otherUserId,
                          otherUsername: otherUsername,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}