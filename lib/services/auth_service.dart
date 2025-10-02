import 'package:firebase_auth/firebase_auth.dart';
import 'package:untarest_app/services/firestore_service.dart'; // Import FirestoreService

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Error during login: ${e.message}');
      rethrow;
    }
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _firestoreService.createUserDocument(
          user: user,
          username: username,
        );
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('Error during registration: ${e.message}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get user => _auth.authStateChanges();
}

