import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../widgets/simple_image_picker_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nimController = TextEditingController(text: widget.initialNim);
    _usernameController = TextEditingController(text: widget.initialUsername);
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
      final userId = widget.userId.isEmpty ? FirestoreService().currentUserId : widget.userId;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID tidak ditemukan')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      // Use centralized update method
      final error = await FirestoreService().updateProfileAndSync(
        userId: userId,
        name: newName,
        nim: newNim,
        username: newUsername,
        imageUrl: widget.initialImageUrl,
      );

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        // Return true to signal successful update
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
                  SimpleImagePickerWidget(
                    userId: widget.userId,
                    radius: 60,
                    onImageChanged: (imagePath) {
                      debugPrint('Image changed: $imagePath');
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap gambar untuk mengubah foto profil',
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
                      color: Colors.white.withValues(alpha: 0.85),
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