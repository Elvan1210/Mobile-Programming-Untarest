import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import '../utils/snackbar_helper.dart';

class SimpleImagePickerWidget extends StatefulWidget {
  final String? userId;
  final double radius;
  final VoidCallback? onImageChanged;

  const SimpleImagePickerWidget({
    super.key,
    this.userId,
    this.radius = 60,
    this.onImageChanged,
  });

  @override
  State<SimpleImagePickerWidget> createState() => _SimpleImagePickerWidgetState();
}

class _SimpleImagePickerWidgetState extends State<SimpleImagePickerWidget> {
  final ImageService _imageService = ImageService();
  final StorageService _storageService = StorageService();

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = await _storageService.loadImage();
    if (mounted) {
      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _pickImage(bool fromCamera) async {
    try {
      final file = fromCamera
          ? await _imageService.pickFromCamera()
          : await _imageService.pickFromGallery();

      if (file != null) {
        setState(() {
          _imageFile = file;
        });
        await _storageService.saveImagePath(file.path);

        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            fromCamera
                ? "Berhasil menambahkan gambar dari Kamera!"
                : "Berhasil menambahkan gambar dari Galeri!",
          );
          
          // Notify parent widget about image change
          widget.onImageChanged?.call();
        }
      } else {
        if (mounted) {
          SnackbarHelper.showError(context, "Gagal menambahkan gambar.");
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, "Terjadi error: $e");
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[300],
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null
                ? Icon(
                    Icons.person,
                    size: widget.radius,
                    color: Colors.grey[600],
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 118, 0, 0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}