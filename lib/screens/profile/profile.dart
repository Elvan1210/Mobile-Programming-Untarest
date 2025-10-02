import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_profile.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Nama Lengkap';
  String _nim = 'NIM';
  String? _profileImageUrl; 

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

  // digunakan firebase agar jika kita login dalam suatu akun dan mengedit di bagian profilenya
  // dan kita close mobile programming kita atau kita restart dibagian profilenya akan tetap terlihat
  // nama, nim dan profile picture yang kita masukkan

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<String?> _uploadImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveProfileLocally(String name, String nim, String? imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_nim', nim);
    
    if (imageUrl != null) {
      await prefs.setString('profile_image_url', imageUrl);
    } else {
      await prefs.remove('profile_image_url');
    }
  }

  Future<void> _saveProfileToFirestore(String name, String nim, String? imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'namaLengkap': name,
          'nim': nim,
          'profileImageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {}
    }
  }

  Future<void> _loadProfileData() async {
    setState(() {}
    );

    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    String? localName = prefs.getString('profile_name');
    String? localNim = prefs.getString('profile_nim');
    String? localImageUrl = prefs.getString('profile_image_url');

    if (localName != null && localNim != null) {
      setState(() {
        _name = localName;
        _nim = localNim;
        _profileImageUrl = localImageUrl;
      });
    }

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            final loadedName = data['namaLengkap'] as String? ?? 'Nama Lengkap';
            final loadedNim = data['nim'] as String? ?? 'NIM';
            final loadedImageUrl = data['profileImageUrl'] as String?;

            if (loadedName != _name || loadedNim != _nim || loadedImageUrl != _profileImageUrl) {
              setState(() {
                _name = loadedName;
                _nim = loadedNim;
                _profileImageUrl = loadedImageUrl;
              });
              _saveProfileLocally(loadedName, loadedNim, loadedImageUrl);
            }
          }
        }
      } catch (e) {}
    }
    setState(() {});
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      final newName = result['name'] as String;
      final newNim = result['nim'] as String;
      final newImageFile = result['imageFile'] as File?;

      String? finalImageUrl = _profileImageUrl;

      if (newImageFile != null) {
        final uploadedUrl = await _uploadImage(newImageFile);
        finalImageUrl = uploadedUrl;
      }

      setState(() {
        _name = newName;
        _nim = newNim;
        _profileImageUrl = finalImageUrl;
      });

      await _saveProfileToFirestore(newName, newNim, finalImageUrl);
      await _saveProfileLocally(newName, newNim, finalImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: untarRed,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/BG_UNTAR.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      // bagian dari profile untuk nama, nim dan profile picturenya
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.withOpacity(0.5),
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      
                      const SizedBox(height: 15),
                      Text(
                        _name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4.0)
                          ],
                        ),
                      ),
                      Text(
                        _nim,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white70,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4.0)
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ProfileButton(
                        text: 'Edit Profile',
                        onPressed: _navigateToEditProfile,
                        icon: Icons.edit,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                // Code untuk membuat bagian dari konten yang akan di upload 
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: screenHeight * 0.55),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Uploads',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: untarRed,
                          ),
                        ),
                        const Divider(height: 30, color: Colors.grey),
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Belum ada Feeds!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _UploadButton(),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

  const _ProfileButton({
    required this.text,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: untarRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        elevation: 5,
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Upload Feeds Baru'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _ProfilePageState.untarRed,
        side: const BorderSide(color: _ProfilePageState.untarRed, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
