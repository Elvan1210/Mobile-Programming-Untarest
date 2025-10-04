import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/screens/profile/profile_header.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/widgets/user_posts_grid.dart'; // <-- Import baru

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

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
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

  void _handleFollow() async {
    setState(() => _isFollowing = true);
    await _firestoreService.followUser(widget.userId);
  }

  void _handleUnfollow() async {
    setState(() => _isFollowing = false);
    await _firestoreService.unfollowUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = widget.userId == _firestoreService.currentUserId;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontFamily: 'Poppins', color: Colors.black)),
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
        child: FutureBuilder<DocumentSnapshot>(
          future: _firestoreService.getUserData(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Pengguna tidak ditemukan.', style: TextStyle(color: Colors.black)));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['username'] ?? 'No Username';
            final nim = userData['nim'] ?? '';
            final profileImageUrl = userData['profileImageUrl'];

            return SafeArea(
              child: Column(
                children: [
                  // Widget ProfileHeader, _buildStatsRow, dan tombol tidak berubah
                  ProfileHeader(
                    name: username,
                    nim: nim,
                    profileImageUrl: profileImageUrl,
                  ),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: primaryColor))
                        : isCurrentUser
                            ? _buildEditProfileButton()
                            : _buildFollowButton(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black38, indent: 20, endIndent: 20),
                  
                  // --- PERUBAHAN UTAMA DI SINI ---
                  // Mengganti pesan statis dengan widget galeri foto
                  Expanded(
                    child: UserPostsGrid(userId: widget.userId),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Followers", _firestoreService.getFollowersCount(widget.userId)),
        _buildStatItem("Following", _firestoreService.getFollowingCount(widget.userId)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Following', style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
      );
    } else {
      return ElevatedButton(
        onPressed: _handleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Follow', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      );
    }
  }

  Widget _buildEditProfileButton() {
    return ElevatedButton(
      onPressed: () {
        // Navigasi ke halaman Edit Profile jika diperlukan
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
    );
  }
}

