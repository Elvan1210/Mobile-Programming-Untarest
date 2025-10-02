import 'package:flutter/material.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/services/firestore_service.dart'; // Import FirestoreService
import 'package:untarest_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultySelectionPage extends StatefulWidget {
  final String username; // MODIFIKASI: Tambahkan username
  final String email;
  final String password;

  const FacultySelectionPage({
    super.key,
    required this.username, // MODIFIKASI: Tambahkan username
    required this.email,
    required this.password,
  });

  @override
  State<FacultySelectionPage> createState() => _FacultySelectionPageState();
}

class _FacultySelectionPageState extends State<FacultySelectionPage> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService(); // Buat instance FirestoreService
  String? _selectedFaculty;
  bool _isLoading = false;

  final List<String> _faculties = [
    'FK - Fakultas Kedokteran',
    'FE - Fakultas Ekonomi',
    'FPT - Fakultas Psikologi',
    'FTI - Fakultas Teknologi Informasi',
    'FH - Fakultas Hukum',
    'FISIP - Fakultas Ilmu Sosial dan Ilmu Politik',
    'FIKOM - Fakultas Ilmu Komunikasi',
    'FT - Fakultas Teknik'
  ];

  void _register() async {
    if (_selectedFaculty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih fakultas.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // MODIFIKASI: Kirim username saat registrasi
      final user = await _authService.registerWithEmailAndPassword(
        widget.email,
        widget.password,
        widget.username,
      );

      if (!mounted) return;

      if (user != null) {
        // MODIFIKASI: Simpan fakultas ke Firestore
        await _firestoreService.updateUserData(user.uid, {
          'faculty': _selectedFaculty,
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false, // Hapus semua halaman sebelumnya
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email ini sudah terdaftar.';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        default:
          message = 'Registrasi gagal: ${e.message ?? e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color.fromARGB(255, 130, 6, 6),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: const Color.fromARGB(255, 110, 5, 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BG_UNTAR.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/images/logo_UNTARESTBIG.png",
                                height: 100,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Pilih Fakultas Anda',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedFaculty,
                                  hint: const Text('Pilih Fakultas'),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: primaryColor),
                                  items: _faculties.map((String faculty) {
                                    return DropdownMenuItem<String>(
                                      value: faculty,
                                      child: Text(
                                        faculty,
                                        style: const TextStyle(fontSize: 14),
                                      ),
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
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  disabledBackgroundColor:
                                      primaryColor.withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
