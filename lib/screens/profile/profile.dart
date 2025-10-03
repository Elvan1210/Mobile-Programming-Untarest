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
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/screens/auth/login_page.dart';
import 'package:untarest_app/widgets/liked_posts_grid.dart';
import 'package:untarest_app/widgets/saved_posts_grid.dart';
import 'package:untarest_app/utils/constants.dart'; // Pastikan import ini ada

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

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
      return await storageRef.getDownloadURL();
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
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if(mounted) {
      setState(() {
        _name = prefs.getString('profile_name') ?? 'Nama Lengkap';
        _nim = prefs.getString('profile_nim') ?? 'NIM';
        _username = prefs.getString('profile_username') ?? 'username';
        _profileImageUrl = prefs.getString('profile_image_url');
      });
    }

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && mounted) {
            final loadedName = data['namaLengkap'] as String? ?? 'Nama Lengkap';
            final loadedNim = data['nim'] as String? ?? 'NIM';
            final loadedUsername = data['username'] as String? ?? 'username';
            final loadedImageUrl = data['profileImageUrl'] as String?;
            
            setState(() {
              _name = loadedName;
              _nim = loadedNim;
              _username = loadedUsername;
              _profileImageUrl = loadedImageUrl;
            });
            await _saveProfileLocally(loadedName, loadedNim, loadedUsername, loadedImageUrl);
          }
        }
      } catch (e) {
        // Handle error jika perlu
      }
    }
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null, // Hapus title dari AppBar
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
              // --- PERUBAHAN DI SINI ---
              // ProfileHeader sekarang menampilkan nama lengkap & NIM
              ProfileHeader(
                name: _name, // Nama Lengkap
                nim: _nim,  // NIM
                profileImageUrl: _profileImageUrl,
                onEditPressed: _navigateToEditProfile,
              ),
              // Menambahkan Username di bawah Header
              Text(
                '@$_username',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor, // Warna merah
                ),
              ),
              const SizedBox(height: 20),
              _buildStatsRow(),
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

  Widget _buildStatsRow() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Followers", _firestoreService.getFollowersCount(userId)),
        _buildStatItem("Following", _firestoreService.getFollowingCount(userId)),
      ],
    );
  }

  Widget _buildStatItem(String label, Stream<int> stream) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        );
      },
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const Center(
            child: Text('Feed Anda akan muncul di sini',
                style: TextStyle(color: Colors.black54)));
      case 1:
        return const LikedPostsGrid();
      case 2:
        return const SavedPostsGrid();
      default:
        return const Center(
            child: Text('Konten tidak tersedia.',
                style: TextStyle(color: Colors.black54)));
    }
  }
}

