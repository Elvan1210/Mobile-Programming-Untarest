import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.withOpacity(0.7),
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : const Icon(Icons.camera_alt, size: 40, color: Colors.white),
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
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            labelStyle: const TextStyle(color: Colors.black54),
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
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nimController,
                          decoration: InputDecoration(
                            labelText: 'NIM',
                            labelStyle: const TextStyle(color: Colors.black54),
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
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            final newName = _nameController.text;
                            final newNim = _nimController.text;
                            Navigator.pop(context, {
                              'name': newName,
                              'nim': newNim,
                              'imageFile': _imageFile,
                            });
                          },
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
}