import 'package:flutter/material.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailPage extends StatefulWidget {
  final NewsArticle article;

  const PostDetailPage({super.key, required this.article});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isPostingComment = false;
  bool showFullText = false;

  String getShortContent(String content) {
    if (content.length <= 125) return content;
    return '${content.substring(0, 125)}...';
  }

  String formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return number.toString();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike(bool isCurrentlyLiked) async {
    try {
      await _firestoreService.toggleLike(widget.article.url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyLiked ? 'Like dihapus' : '❤️ Liked!',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            duration: const Duration(milliseconds: 1200),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleSave(bool isCurrentlySaved) async {
    try {
      await _firestoreService.toggleSave(
        widget.article.url,
        widget.article.urlToImage,
        widget.article.content,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlySaved ? 'Dihapus dari simpanan' : '🔖 Disimpan!',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            duration: const Duration(milliseconds: 1200),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isPostingComment = true);
    try {
      await _firestoreService.addComment(
        widget.article.url,
        _commentController.text.trim(),
      );
      _commentController.clear();
      FocusScope.of(context).unfocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '💬 Komentar berhasil diposting!',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            duration: Duration(milliseconds: 1200),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isPostingComment = false);
    }
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.comment, color: primaryColor, size: 24),
                    const SizedBox(width: 8),
                    StreamBuilder<int>(
                      stream: _firestoreService.getCommentsCount(widget.article.url),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text(
                          'Komentar ($count)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getComments(widget.article.url),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: primaryColor));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada komentar',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Jadilah yang pertama berkomentar!',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    final comments = snapshot.data!.docs;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index].data() as Map<String, dynamic>;
                        final timestamp = comment['timestamp'] as Timestamp?;
                        final username = comment['username'] ?? 'User';
                        final text = comment['text'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                child: Text(
                                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            username,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (timestamp != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTimestamp(timestamp.toDate()),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          hintStyle: const TextStyle(fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        maxLines: null,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _isPostingComment ? null : _postComment,
                        icon: _isPostingComment
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}h yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Post',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.article.urlToImage.isNotEmpty)
                    buildImage(widget.article.urlToImage)
                  else
                    Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 100, color: Colors.grey),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showFullText ? widget.article.content : getShortContent(widget.article.content),
                          style: const TextStyle(fontSize: 16, height: 1.6, fontFamily: 'Poppins', color: Colors.black87),
                        ),
                        if (widget.article.content.length > 125 && !showFullText)
                          GestureDetector(
                            onTap: () => setState(() => showFullText = true),
                            child: const Text(
                              'Read more',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                StreamBuilder<bool>(
                  stream: _firestoreService.isSavedStream(widget.article.url).map((_) => true).handleError((_) => false),
                  builder: (context, _) {
                    return FutureBuilder<bool>(
                      future: _firestoreService.isLiked(widget.article.url),
                      builder: (context, snapshot) {
                        final isLiked = snapshot.data ?? false;
                        return _ActionButton(
                          icon: isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey[700]!,
                          label: 'Like',
                          onTap: () => _toggleLike(isLiked),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 16),
                StreamBuilder<int>(
                  stream: _firestoreService.getCommentsCount(widget.article.url),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _ActionButton(
                      icon: Icons.comment_outlined,
                      color: Colors.grey[700]!,
                      label: count > 0 ? '$count' : 'Comment',
                      onTap: _showCommentsBottomSheet,
                    );
                  },
                ),
                const Spacer(),
                StreamBuilder<bool>(
                  stream: _firestoreService.isSavedStream(widget.article.url),
                  builder: (context, snapshot) {
                    final isSaved = snapshot.data ?? false;
                    return _ActionButton(
                      icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? primaryColor : Colors.grey[700]!,
                      label: 'Save',
                      onTap: () => _toggleSave(isSaved),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildImage(String path) {
  if (path.startsWith("assets/")) {
    return Image.asset(
      path,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  } else {
    return Image.network(
      path,
      width: double.infinity,
      fit: BoxFit.cover,
      headers: const {
        'User-Agent': 'Mozilla/5.0',
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 300,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
          ),
        );
      },
    );
  }
}

