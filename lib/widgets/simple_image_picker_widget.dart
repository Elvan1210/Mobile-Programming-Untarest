import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleImagePickerWidget extends StatefulWidget {
  final String? userId;
  final double radius;
  final Function(String?)? onImageChanged;

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

  File? _imageFile;
  int _imageKey = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SimpleImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_${widget.userId}');
      
      if (imagePath != null && File(imagePath).existsSync()) {
        if (mounted) {
          setState(() {
            _imageFile = File(imagePath);
            _imageKey++;
          });
          debugPrint('✅ Loaded image from: $imagePath');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading image: $e');
    }
  }

  Future<void> _pickImage(bool fromCamera) async {
    if (widget.userId == null) {
      if (mounted) {
        SnackbarHelper.showError(context, "User ID tidak ditemukan");
      }
      return;
    }

    try {
      final file = fromCamera
          ? await _imageService.pickFromCamera()
          : await _imageService.pickFromGallery();

      if (file != null) {
        // Save image path with userId
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${widget.userId}', file.path);
        
        setState(() {
          _imageFile = file;
          _imageKey++;
        });

        debugPrint('📸 New image saved: ${file.path} for user: ${widget.userId}');

        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            fromCamera
                ? "Berhasil menambahkan gambar dari Kamera!"
                : "Berhasil menambahkan gambar dari Galeri!",
          );
          
          // Notify parent widget about image change
          widget.onImageChanged?.call(file.path);
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
            key: ValueKey('image_picker_$_imageKey'),
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