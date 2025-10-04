import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/screens/profile/profile_header.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/screens/profile/edit_profile.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isFollowing = false;
  bool _isLoading = true;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
    _loadLocalImage();
  }

  Future<void> _checkIfFollowing() async {
    if (widget.userId == _firestoreService.currentUserId) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    bool isFollowing = await _firestoreService.isFollowing(widget.userId);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
        _isLoading = false;
      });
    }
  }

  // Load local image for current user only
  Future<void> _loadLocalImage() async {
    // Only load local image if viewing own profile
    if (widget.userId == _firestoreService.currentUserId) {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('profile_image_${widget.userId}');

      if (path != null && await File(path).exists()) {
        if (mounted) {
          setState(() => _localImagePath = path);
        }
      }
    }
  }

  void _handleFollow() async {
    setState(() => _isFollowing = true);
    await _firestoreService.followUser(widget.userId);
  }

  void _handleUnfollow() async {
    setState(() => _isFollowing = false);
    await _firestoreService.unfollowUser(widget.userId);
  }

  void _navigateToEditProfile(
      String name, String nim, String username, String? profileImageUrl) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: name,
          userId: widget.userId,
          initialNim: nim,
          initialUsername: username,
          initialImageUrl: profileImageUrl,
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
    final bool isCurrentUser = widget.userId == _firestoreService.currentUserId;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profil',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG_UNTAR.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestoreService.streamUserData(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: primaryColor));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Pengguna tidak ditemukan.'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            String name = userData['namaLengkap'] ?? 'Nama Lengkap';
            String username = userData['username'] ?? 'No Username';
            String nim = userData['nim'] ?? '';
            final profileImageUrl = userData['profileImageUrl'];

            return SafeArea(
              child: ListView(
                children: [
                  _buildProfileHeader(
                    name,
                    username,
                    nim,
                    profileImageUrl,
                    isCurrentUser,
                  ),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: _isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: primaryColor))
                        : isCurrentUser
                            ? _buildEditProfileButton(
                                name, nim, username, profileImageUrl)
                            : _buildFollowButton(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      color: Colors.black38, indent: 20, endIndent: 20),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Pengguna ini belum mengupload foto.',
                        style: TextStyle(
                            fontFamily: 'Poppins', color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String username, String nim,
      String? profileImageUrl, bool isCurrentUser) {
    Widget profileImage;

    // Show local image if it's current user and exists
    if (isCurrentUser &&
        _localImagePath != null &&
        File(_localImagePath!).existsSync()) {
      profileImage = CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(_localImagePath!)),
      );
    } else {
      // Default avatar with initials
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
              if (isCurrentUser)
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
          Text(
            '@$username',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
            "Followers", _firestoreService.getFollowersCount(widget.userId)),
        _buildStatItem(
            "Following", _firestoreService.getFollowingCount(widget.userId)),
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
                fontSize: 16,
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        );
      },
    );
  }

  Widget _buildFollowButton() {
    if (_isFollowing) {
      return OutlinedButton(
        onPressed: _handleUnfollow,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Following',
            style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
      );
    } else {
      return ElevatedButton(
        onPressed: _handleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Follow',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      );
    }
  }

  Widget _buildEditProfileButton(
      String name, String nim, String username, String? profileImageUrl) {
    return ElevatedButton(
      onPressed: () =>
          _navigateToEditProfile(name, nim, username, profileImageUrl),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Edit Profile',
        style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
      ),
    );
  }
}
