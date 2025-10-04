import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  // Save image with user-specific key
  Future<void> saveImagePath(String path) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_${user.uid}', path);
  }

  // Load image with user-specific key
  Future<File?> loadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${user.uid}');
    if (path != null && await File(path).exists()) {
      return File(path);
    }
    return null;
  }
}
