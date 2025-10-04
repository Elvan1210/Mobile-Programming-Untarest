import 'package:flutter/material.dart';

// Global notifier for profile image changes
class ProfileImageNotifier {
  static final ValueNotifier<String> _imagePathNotifier = ValueNotifier<String>('');
  
  static ValueNotifier<String> get imagePathNotifier => _imagePathNotifier;
  
  static void updateImagePath(String userId, String? imagePath) {
    final notificationValue = '${userId}_${imagePath}_${DateTime.now().millisecondsSinceEpoch}';
    _imagePathNotifier.value = notificationValue;
    debugPrint('🔔 ProfileImageNotifier: Image path updated for $userId: $imagePath');
    debugPrint('🔔 Notification value: $notificationValue');
  }
  
  static void dispose() {
    _imagePathNotifier.dispose();
  }
}