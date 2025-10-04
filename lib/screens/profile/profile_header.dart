import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile_image_notifier.dart';

class ProfileHeader extends StatefulWidget {
  final String name;
  final String nim;
  final String? profileImageUrl;
  final String? localImagePath;
  final VoidCallback? onEditPressed;
  final String? userId;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.nim,
    this.profileImageUrl,
    this.localImagePath,
    this.onEditPressed,
    this.userId,
    String? username,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? _currentLocalPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocalImagePath();
  }

  @override
  void didUpdateWidget(ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadLocalImagePath();
    }
  }

  Future<void> _loadLocalImagePath() async {
    if (widget.userId == null || _isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final localPath = prefs.getString('profile_image_${widget.userId}');
      
      if (mounted && localPath != _currentLocalPath) {
        setState(() {
          _currentLocalPath = localPath;
        });
        debugPrint('✅ Profile image loaded: $localPath');
      }
    } catch (e) {
      debugPrint('❌ Error loading image: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileImageWidget() {
    // Check if file exists and is valid
    if (_currentLocalPath != null) {
      final file = File(_currentLocalPath!);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: 112,
            height: 112,
            cacheWidth: 112, // Optimize memory
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error displaying image: $error');
              return _buildDefaultIcon();
            },
          ),
        );
      }
    }
    
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return const Icon(
      Icons.person,
      size: 60,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  child: _buildProfileImageWidget(),
                ),
              ),
              if (widget.onEditPressed != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onEditPressed,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 118, 0, 0),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
              shadows: [Shadow(blurRadius: 1, color: Colors.white54)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.nim,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Colors.black54,
              shadows: [Shadow(blurRadius: 1, color: Colors.white54)],
            ),
          ),
        ],
      ),
    );
  }
}