import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialNim;
  final String initialUsername;
  final String? initialImageUrl;

  const EditProfilePage({
    super.key,
    required this.initialName,
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
  
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nimController = TextEditingController(text: widget.initialNim);
    _usernameController = TextEditingController(text: widget.initialUsername);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    final newName = _nameController.text;
    final newNim = _nimController.text;
    final newUsername = _usernameController.text;

    Navigator.pop(context, {
      'name': newName,
      'nim': newNim,
      'username': newUsername,
      'imageFile': _imageFile,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return ClipOval(
        child: Image.file(_imageFile!, fit: BoxFit.cover, width: 120, height: 120),
      );
    } else if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.initialImageUrl!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 60, color: Colors.white);
          },
        ),
      );
    } else {
      return const Icon(Icons.camera_alt, size: 40, color: Colors.white);
    }
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
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.withOpacity(0.7),
                      child: _buildProfileImage(),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                        // PERBAIKAN: Menghapus `isEnabled: false` agar NIM bisa diubah
                        _buildTextField(_nimController, 'NIM'),
                        const SizedBox(height: 20),
                        _buildTextField(_usernameController, 'Username'), 
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 118, 0, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isEnabled = true}) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      style: TextStyle(color: isEnabled ? Colors.black : Colors.grey[700]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isEnabled ? Colors.black54 : Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color.fromARGB(255, 118, 0, 0)),
        ),
      ),
    );
  }
}