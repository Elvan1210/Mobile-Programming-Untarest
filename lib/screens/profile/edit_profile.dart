import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/firestore_service.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String userId;
  final String initialNim;
  final String initialUsername;
  final String? initialImageUrl;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.userId,
    required this.initialNim,
    required this.initialUsername,
    this.initialImageUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _nimController;
  late TextEditingController _usernameController;

  String? _localImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nimController = TextEditingController(text: widget.initialNim);
    _usernameController = TextEditingController(text: widget.initialUsername);
    _loadLocalImage();
  }

  // Load image path from local storage
  Future<void> _loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.userId}');
    if (path != null && await File(path).exists()) {
      setState(() => _localImagePath = path);
    }
  }

  // Save image path to local storage
  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_${widget.userId}', path);
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}'); // This log you're seeing

        // THIS IS THE IMPORTANT PART - Copy to permanent directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${widget.userId}.jpg';
        final localPath = '${directory.path}/$fileName';

        print('Copying to: $localPath'); // Should see this log

        // Copy the picked file to app directory
        final File localFile = await File(pickedFile.path).copy(localPath);

        print('File copied successfully'); // Should see this log

        await _saveImagePath(localFile.path);
        setState(() => _localImagePath = localFile.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gambar berhasil dipilih')),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<String> _getAppDirectory() async {
    // Get app's documents directory
    final directory = Directory.systemTemp.createTempSync('profile_images');
    return directory.path;
  }

  void _saveProfile() async {
    if (_isSaving) return;

    final newName = _nameController.text.trim();
    final newNim = _nimController.text.trim();
    final newUsername = _usernameController.text.trim().toLowerCase();

    if (newName.isEmpty || newNim.isEmpty || newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Validate NIM (only if changed)
      if (newNim != widget.initialNim) {
        if (await FirestoreService().isNimTaken(newNim)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('NIM sudah terdaftar')),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
      }

      // Validate username (only if changed)
      if (newUsername != widget.initialUsername.toLowerCase()) {
        if (await FirestoreService().isUsernameTaken(newUsername)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Username sudah dipakai')),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
      }

      // Update Firestore (without image URL)
      await FirestoreService().updateUserData(widget.userId, {
        'namaLengkap': newName,
        'nim': newNim,
        'username': newUsername,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Widget _buildProfileImage() {
    if (_localImagePath != null) {
      final file = File(_localImagePath!);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        );
      }
    }
    return const Icon(Icons.camera_alt, size: 40, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/BG_UNTAR.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color.fromARGB(255, 237, 203, 203),
                  BlendMode.multiply,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: _isSaving ? null : _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.withOpacity(0.7),
                          child: _buildProfileImage(),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 118, 0, 0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Foto hanya tersimpan di perangkat ini',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(_nameController, 'Nama Lengkap'),
                        const SizedBox(height: 20),
                        _buildTextField(_nimController, 'NIM'),
                        const SizedBox(height: 20),
                        _buildTextField(_usernameController, 'Username'),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 118, 0, 0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              onPressed: _isSaving ? null : () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isEnabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled && !_isSaving,
      style: TextStyle(
        color: isEnabled ? Colors.black : Colors.grey[700],
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 118, 0, 0),
            width: 2,
          ),
        ),
      ),
    );
  }
}
