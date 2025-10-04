# Firebase Storage Rules Configuration

## Issue
Getting "Firebase Storage object not found" or "no object exist at the desired reference" errors when uploading profile images.

## Root Causes
1. **Firebase Storage Rules** - Default rules may be too restrictive
2. **File path issues** - Local file gets deleted before upload
3. **Authentication issues** - User not properly authenticated
4. **Network connectivity** - Poor connection during upload

## Solution: Configure Firebase Storage Rules

### Step 1: Open Firebase Console
1. Go to https://console.firebase.google.com/
2. Select your project (`untarest-mobprog-app`)
3. Navigate to "Storage" in the left menu
4. Click on the "Rules" tab

### Step 2: Update Storage Rules
Replace the existing rules with the following:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload/download profile images
    match /profile_images/{userId}_{timestamp}.jpg {
      allow read, write: if request.auth != null && 
                         request.auth.uid == userId;
    }
    
    // Allow authenticated users to manage their own profile images
    match /profile_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Allow public read access to user posts
    match /user_posts/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Step 3: Alternative Simple Rules (for testing)
If you're still having issues, try these more permissive rules temporarily:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Step 4: Verify Firebase Configuration
Make sure your `firebase_options.dart` file has the correct storage bucket configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  // ... other options
  storageBucket: 'your-project-id.appspot.com',  // Make sure this is correct
);
```

## Testing the Fix

1. Apply the storage rules in Firebase Console
2. Run `flutter clean` and `flutter pub get`
3. Test profile image upload on a real device (not emulator)
4. Check the debug console for detailed error messages

## Debug Information
The app now includes comprehensive error handling and debug information:
- Detailed error messages based on Firebase error codes
- Automatic retry for network-related errors
- Debug logging for Firebase Storage configuration
- "Try Again" button for manual retries

## Common Error Messages and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `object-not-found` | File deleted before upload | Pick image again |
| `unauthorized` | Authentication issues | Login again |
| `quota-exceeded` | Storage limit reached | Contact admin |
| `invalid-argument` | Invalid file format | Try different image |
| `network` | Connection problems | Check internet |

## Important Notes
- Test on a real device, not emulator
- Ensure user is properly logged in
- Check internet connection
- Profile images are uploaded to `profile_images/{userId}_{timestamp}.jpg`
- The app includes automatic retry for network errors
- Local images are cached for immediate display while uploading to cloud