import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_header.dart';
import 'profile_tabs.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/screens/auth/login_page.dart';
import 'package:untarest_app/widgets/liked_posts_grid.dart';
import 'package:untarest_app/widgets/saved_posts_grid.dart';
import 'package:untarest_app/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  int _selectedTab = 0;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
  }

  Future<void> _loadLocalImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${user.uid}');

    if (path != null && await File(path).exists()) {
      if (mounted) {
        setState(() => _localImagePath = path);
      }
    }
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

  void _navigateToEditProfile(String currentName, String currentNim,
      String currentUsername, String? currentImageUrl) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: currentName,
          initialNim: currentNim,
          userId: FirebaseAuth.instance.currentUser!.uid,
          initialUsername: currentUsername,
          initialImageUrl: currentImageUrl,
        ),
      ),
    );

    // Reload local image after edit
    if (result == true) {
      await _loadLocalImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User tidak login.'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Data pengguna tidak ditemukan.')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['namaLengkap'] ?? 'Nama Lengkap';
        final nim = data['nim'] ?? 'NIM';
        final username = data['username'] ?? 'username';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
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
                  _buildProfileHeader(name, nim, username),
                  Text(
                    '@$username',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
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
      },
    );
  }

  Widget _buildProfileHeader(String name, String nim, String username) {
    Widget profileImage;

    if (_localImagePath != null && File(_localImagePath!).existsSync()) {
      profileImage = CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(_localImagePath!)),
      );
    } else {
      profileImage = CircleAvatar(
        radius: 50,
        backgroundColor: primaryColor,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              profileImage,
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () =>
                      _navigateToEditProfile(name, nim, username, null),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          if (nim.isNotEmpty)
            Text(
              nim,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
            "Followers", _firestoreService.getFollowersCount(userId)),
        _buildStatItem(
            "Following", _firestoreService.getFollowingCount(userId)),
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
