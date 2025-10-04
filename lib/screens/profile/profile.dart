import 'package:flutter/material.dart';
import 'dart:async';
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
import 'package:untarest_app/widgets/user_posts_grid.dart';
import 'package:untarest_app/utils/constants.dart';

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
  StreamSubscription<String>? _profileUpdateSubscription;
  int _headerKey = 0; // Key to force ProfileHeader rebuild

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    
    // Listen for profile updates from anywhere in the app
    _profileUpdateSubscription = FirestoreService.profileUpdateStream.listen((userId) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == userId) {
        _loadProfileData();
      }
    });
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
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

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Load from local storage first
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name = prefs.getString('profile_name') ?? 'Nama Lengkap';
        _nim = prefs.getString('profile_nim') ?? 'NIM';
        _username = prefs.getString('profile_username') ?? 'username';
        _profileImageUrl = prefs.getString('profile_image_url');
      });
    }

    // Then load fresh data from Firestore
    try {
      final profileData = await _firestoreService.getCompleteUserProfile(user.uid);
      if (profileData != null && mounted) {
        final loadedName = profileData['namaLengkap'] as String? ?? 'Nama Lengkap';
        final loadedNim = profileData['nim'] as String? ?? 'NIM';
        final loadedUsername = profileData['username'] as String? ?? 'username';
        final loadedImageUrl = profileData['profileImageUrl'] as String?;

        setState(() {
          _name = loadedName;
          _nim = loadedNim;
          _username = loadedUsername;
          _profileImageUrl = loadedImageUrl;
        });
        
        await _firestoreService.syncProfileLocally(user.uid);
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  void _navigateToEditProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak login')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: _name,
          initialNim: _nim,
          initialUsername: _username,
          initialImageUrl: _profileImageUrl,
          userId: user.uid,
        ),
      ),
    );

    if (result == true && mounted) {
      // Give time for file system to sync
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Force complete refresh
      setState(() {
        _headerKey++; // This forces ProfileHeader to rebuild completely
      });
      
      await _loadProfileData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _profileUpdateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseAuth.instance.currentUser?.uid != null
                ? _firestoreService.streamUserData(FirebaseAuth.instance.currentUser!.uid)
                : null,
            builder: (context, snapshot) {
              String displayName = _name;
              String displayNim = _nim;
              String displayUsername = _username;
              String? displayImageUrl = _profileImageUrl;

              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                displayName = userData['namaLengkap'] ?? _name;
                displayNim = userData['nim'] ?? _nim;
                displayUsername = userData['username'] ?? _username;
                displayImageUrl = userData['profileImageUrl'] ?? _profileImageUrl;
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && 
                      (displayName != _name || displayNim != _nim || 
                       displayUsername != _username || displayImageUrl != _profileImageUrl)) {
                    setState(() {
                      _name = displayName;
                      _nim = displayNim;
                      _username = displayUsername;
                      _profileImageUrl = displayImageUrl;
                    });
                  }
                });
              }

              return Column(
                children: [
                  ProfileHeader(
                    key: ValueKey('profile_header_$_headerKey'), // Force rebuild with key
                    name: displayName,
                    nim: displayNim,
                    profileImageUrl: displayImageUrl,
                    onEditPressed: _navigateToEditProfile,
                    userId: FirebaseAuth.instance.currentUser?.uid,
                    username: null,
                  ),
                  Text(
                    '@$displayUsername',
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
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildTabContent(),
                  ),
                ],
              );
            },
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    switch (_selectedTab) {
      case 0:
        if (userId != null) {
          return UserPostsGrid(userId: userId);
        }
        return const Center(
            child: Text('User tidak ditemukan.',
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