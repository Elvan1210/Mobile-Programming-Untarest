import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile_header.dart';
import 'profile_tabs.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Nama Lengkap';
  String _nim = 'NIM';
  String? _profileImageUrl;
  int _selectedTab = 0; // 0: Photos, 1: Liked, 2: Saved

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

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

  Future<void> _saveProfileLocally(
      String name, String nim, String? imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_nim', nim);

    if (imageUrl != null) {
      await prefs.setString('profile_image_url', imageUrl);
    } else {
      await prefs.remove('profile_image_url');
    }
  }

  Future<void> _saveProfileToFirestore(
      String name, String nim, String? imageUrl) async {
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
    setState(() {});

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

            if (loadedName != _name ||
                loadedNim != _nim ||
                loadedImageUrl != _profileImageUrl) {
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG_UNTAR.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Header Section
              ProfileHeader(
                name: _name,
                nim: _nim,
                profileImageUrl: _profileImageUrl,
                onEditPressed: _navigateToEditProfile,
              ),

              const SizedBox(height: 20),

              // Tab Buttons Section
              ProfileTabs(
                selectedTab: _selectedTab,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Content Section
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(),
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedTab) {
      case 0:
        return 'Belum ada Feeds!';
      case 1:
        return 'Belum ada foto yang disukai!';
      case 2:
        return 'Belum ada foto yang disimpan!';
      default:
        return 'Belum ada konten!';
    }
  }
}
