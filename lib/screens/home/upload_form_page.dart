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
            content: Text('Post berhasil di-upload!'),
            backgroundColor: Colors.green,
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

  @override
  void dispose() {
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
                    child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.0,),
                  ),
                )
              : TextButton(
                  onPressed: _handleUpload,
                  child: const Text('Upload', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                      hintText: 'Tulis deskripsi...',
                      border: InputBorder.none,
                    ),
                    maxLines: 4,
                    autofocus: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

