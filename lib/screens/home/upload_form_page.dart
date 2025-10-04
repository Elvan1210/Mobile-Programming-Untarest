import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/utils/constants.dart';

class UploadFormPage extends StatefulWidget {
  final File imageFile;

  const UploadFormPage({super.key, required this.imageFile});

  @override
  State<UploadFormPage> createState() => _UploadFormPageState();
}

class _UploadFormPageState extends State<UploadFormPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isUploading = false;
  List<String> _trendingHashtags = [];
  List<String> _extractedHashtags = [];

  @override
  void initState() {
    super.initState();
    _loadTrendingHashtags();
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _loadTrendingHashtags() async {
    try {
      final hashtags = await _firestoreService.getTrendingHashtags(limit: 20);
      if (mounted) {
        setState(() {
          _trendingHashtags = hashtags;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onDescriptionChanged() {
    final text = _descriptionController.text;
    final hashtags = _firestoreService.extractHashtags(text);
    if (mounted) {
      setState(() {
        _extractedHashtags = hashtags;
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      await _firestoreService.uploadPost(
        imageFile: widget.imageFile,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Foto berhasil diunggah!',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal meng-upload post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _insertHashtag(String hashtag) {
    final currentText = _descriptionController.text;
    final cursorPosition = _descriptionController.selection.base.offset;

    final newText = currentText.substring(0, cursorPosition) +
        hashtag +
        ' ' +
        currentText.substring(cursorPosition);

    _descriptionController.text = newText;
    _descriptionController.selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition + hashtag.length + 1),
    );
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tulis Deskripsi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          _isUploading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _handleUpload,
                  child: const Text('Upload',
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(widget.imageFile, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis deskripsi... (gunakan # untuk hashtag)',
                      border: InputBorder.none,
                    ),
                    maxLines: 4,
                    autofocus: true,
                  ),
                ),
              ],
            ),

            // Show extracted hashtags
            if (_extractedHashtags.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Hashtag yang ditemukan:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _extractedHashtags
                    .map((hashtag) => Chip(
                          label: Text(
                            hashtag,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: primaryColor,
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],

            // Show trending hashtags
            if (_trendingHashtags.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Hashtag trending:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _trendingHashtags
                    .map((hashtag) => ActionChip(
                          label: Text(
                            hashtag,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () => _insertHashtag(hashtag),
                          backgroundColor: Colors.grey[100],
                          side: BorderSide(color: Colors.grey[300]!),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Tips Hashtag',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Gunakan hashtag yang relevan dengan foto\n• Maksimal 5-10 hashtag per post\n• Contoh: #photography #nature #sunset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
