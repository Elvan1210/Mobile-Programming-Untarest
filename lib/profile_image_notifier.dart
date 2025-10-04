import 'package:flutter/material.dart';

/// Global notifier for profile image updates
/// This allows real-time updates across the app when profile image changes
class ProfileImageNotifier extends ValueNotifier<String?> {
  ProfileImageNotifier() : super(null);

  /// Update the profile image path and notify all listeners
  void updateImagePath(String? imagePath) {
    value = imagePath;
    notifyListeners();
  }

  /// Clear the profile image and notify listeners
  void clearImage() {
    value = null;
    notifyListeners();
  }
}

/// Global instance of ProfileImageNotifier
/// Use this throughout the app to listen for profile image changes
final ProfileImageNotifier profileImageNotifier = ProfileImageNotifier();
