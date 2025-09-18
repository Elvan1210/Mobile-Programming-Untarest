import 'package:flutter/material.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/utils/custom_widgets.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultySelectionPage extends StatefulWidget {
  final String email;
  final String password;

  const FacultySelectionPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<FacultySelectionPage> createState() => _FacultySelectionPageState();
}

class _FacultySelectionPageState extends State<FacultySelectionPage> {
  final _authService = AuthService();
  String? _selectedFaculty;
  final List<String> _faculties = [
    'FK - Fakultas Kedokteran',
    'FE - Fakultas Ekonomi',
    'FPT - Fakultas Psikologi',
    'FTI - Fakultas Teknologi Informasi',
    'FH - Fakultas Hukum',
    'FISIP - Fakultas Ilmu Sosial dan Ilmu Politik',
  ];

  void _register() async {
    if (_selectedFaculty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a faculty.')),
      );
      return;
    }
    
    // Gunakan try-catch untuk menangkap error spesifik dari Firebase
    try {
      final user = await _authService.registerWithEmailAndPassword(
        widget.email,
        widget.password,
      );
      
      if (user != null && mounted) {
        // Logika untuk menyimpan data user ke Firestore (jika ada)
        // ... (misalnya: menambahkan fakultas ke profil user di database)
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use by another account.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Catch all other generic errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'untarest',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 50),
              const Text('Choose your Faculty', style: bodyTextStyle),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedFaculty,
                    hint: const Text('Select Faculty'),
                    items: _faculties.map((String faculty) {
                      return DropdownMenuItem<String>(
                        value: faculty,
                        child: Text(faculty),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFaculty = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Sign Up',
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}