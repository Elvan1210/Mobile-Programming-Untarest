import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:untarest_app/models/post_model.dart';

List<UserPost> userPosts = [];

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();

  List<UserPost> userPosts = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  void _submitPost() {
    if (_imageFile == null || _captionController.text.isEmpty) return;

    userPosts.add(UserPost(
      title: _titleController.text,
      caption: _captionController.text,
      imagePath: _imageFile!.path,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Post berhasil diupload!")),
    );

    _titleController.clear();
    _captionController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Pilih Gambar"),
            ),
            const SizedBox(height: 10),
            // Preview kecil jika gambar sudah dipilih
            if (_imageFile != null)
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: "Caption"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
