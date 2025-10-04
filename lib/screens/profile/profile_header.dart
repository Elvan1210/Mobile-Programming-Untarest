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
  int _imageKey = 0;

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
    if (widget.userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final localPath = prefs.getString('profile_image_${widget.userId}');
      
      if (mounted && localPath != _currentLocalPath) {
        setState(() {
          _currentLocalPath = localPath;
          _imageKey++; // Force image widget rebuild
        });
        debugPrint('Profile image path loaded: $localPath');
      }
    } catch (e) {
      debugPrint('Error loading local image path: $e');
    }
  }

  void _refreshImage() {
    debugPrint('🔄 REFRESHING profile image for user: ${widget.userId}');
    _loadLocalImagePath();
    // Force a complete widget rebuild
    setState(() {
      _imageKey = DateTime.now().millisecondsSinceEpoch;
    });
    debugPrint('🔄 FORCED setState with new imageKey: $_imageKey');
  }

  Widget _buildProfileImageWidget() {
    // Show local image if available, otherwise show default icon
    if (_currentLocalPath != null && File(_currentLocalPath!).existsSync()) {
      return ClipOval(
        key: ValueKey('profile_image_${_imageKey}_$_currentLocalPath'),
        child: Image.file(
          File(_currentLocalPath!),
          fit: BoxFit.cover,
          width: 112,
          height: 112,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading profile image: $error');
            return const Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            );
          },
        ),
      );
    }
    
    // Default icon when no image is available
    return const Icon(
      Icons.person,
      size: 60,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: profileImageNotifier,
      builder: (context, notifierValue, child) {
        // Refresh image whenever the notifier value changes
        if (notifierValue != null) {
          debugPrint('ProfileHeader received update notification: $notifierValue');
          // Trigger a refresh when we get a notification
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshImage();
          });
        }
        
        return Padding(
          padding: const EdgeInsets.only(
              top: 20.0, bottom: 20.0), // Changed from 60 to 20
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
                  // Tombol edit hanya akan muncul jika onEditPressed TIDAK null
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
                          child:
                              const Icon(Icons.edit, color: Colors.white, size: 20),
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
                    color: Colors.black, // Warna diubah ke hitam
                    shadows: [Shadow(blurRadius: 1, color: Colors.white54)]),
              ),
              const SizedBox(height: 4),
              Text(
                widget.nim,
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.black54, // Warna diubah ke abu-abu gelap
                    shadows: [Shadow(blurRadius: 1, color: Colors.white54)]),
              ),
            ],
          ),
        );
      },
    );
  }
}
