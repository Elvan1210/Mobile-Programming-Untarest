import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile_header.dart';
import 'profile_tabs.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/screens/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  String _name = 'Nama Lengkap';
  String _nim = 'NIM';
  String _username = 'username';
  String? _profileImageUrl;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('keepMeLoggedIn');
      
      await _authService.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal untuk logout: $e')),
        );
      }
    }
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
      String name, String nim, String username, String? imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_nim', nim);
    await prefs.setString('profile_username', username);

    if (imageUrl != null) {
      await prefs.setString('profile_image_url', imageUrl);
    } else {
      await prefs.remove('profile_image_url');
    }
  }

  Future<String?> _saveProfileToFirestore(
      String name, String nim, String username, String? imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User tidak login.';

    if (_username != username) {
      final usernameCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return 'Username sudah digunakan oleh akun lain.';
      }
    }
    
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'namaLengkap': name,
        'nim': nim,
        'username': username,
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return null;
    } catch (e) {
      return 'Gagal menyimpan ke Firestore: $e';
    }
  }

  Future<void> _loadProfileData() async {
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    String? localName = prefs.getString('profile_name');
    String? localNim = prefs.getString('profile_nim');
    String? localUsername = prefs.getString('profile_username');
    String? localImageUrl = prefs.getString('profile_image_url');

    if (localName != null && localNim != null && localUsername != null) {
      setState(() {
        _name = localName;
        _nim = localNim;
        _username = localUsername;
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
            final loadedUsername = data['username'] as String? ?? 'username';
            final loadedImageUrl = data['profileImageUrl'] as String?;

            if (loadedName != _name ||
                loadedNim != _nim ||
                loadedUsername != _username ||
                loadedImageUrl != _profileImageUrl) {
              setState(() {
                _name = loadedName;
                _nim = loadedNim;
                _username = loadedUsername;
                _profileImageUrl = loadedImageUrl;
              });
              _saveProfileLocally(loadedName, loadedNim, loadedUsername, loadedImageUrl);
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
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: _name,
          initialNim: _nim,
          initialUsername: _username,
          initialImageUrl: _profileImageUrl,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final newName = result['name'] as String;
      final newNim = result['nim'] as String;
      final newUsername = result['username'] as String;
      final newImageFile = result['imageFile'] as File?;

      String? finalImageUrl = _profileImageUrl;

      if (newImageFile != null) {
        final uploadedUrl = await _uploadImage(newImageFile);
        finalImageUrl = uploadedUrl;
      }

      final error = await _saveProfileToFirestore(newName, newNim, newUsername, finalImageUrl);

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui profil: $error')),
          );
        }
        return;
      }

      setState(() {
        _name = newName;
        _nim = newNim;
        _username = newUsername;
        _profileImageUrl = finalImageUrl;
      });

      await _saveProfileLocally(newName, newNim, newUsername, finalImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double usernameBoxTotalWidth = 170.0; 

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: usernameBoxTotalWidth, 
        
        leading: Row( 
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 118, 0, 0),
                  borderRadius: BorderRadius.circular(10), 
                ),
                child: Text(
                  'Username: $_username',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG_UNTAR.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              ProfileHeader(
                name: _name,
                nim: _nim,
                profileImageUrl: _profileImageUrl,
                onEditPressed: _navigateToEditProfile,
              ),

              const SizedBox(height: 20),

              ProfileTabs(
                selectedTab: _selectedTab,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              ),

              const SizedBox(height: 20),

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
