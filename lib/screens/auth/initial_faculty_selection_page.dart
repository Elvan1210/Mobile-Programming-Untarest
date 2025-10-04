import 'package:flutter/material.dart';
import 'package:untarest_app/screens/auth/nim_builder_page.dart';
import 'package:untarest_app/utils/constants.dart';

class InitialFacultySelectionPage extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const InitialFacultySelectionPage({
    super.key,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<InitialFacultySelectionPage> createState() => _InitialFacultySelectionPageState();
}

class _InitialFacultySelectionPageState extends State<InitialFacultySelectionPage> {
  String? _selectedFaculty;

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

  void _proceedToNIMBuilder() {
    if (_selectedFaculty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih fakultas Anda.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NIMBuilderPage(
          username: widget.username,
          email: widget.email,
          password: widget.password,
          selectedFaculty: _selectedFaculty!,
        ),
      ),
    );
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
            color: Colors.black.withValues(alpha: 0.5),
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
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
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
                            const SizedBox(height: 16),
                            const Text(
                              'Pilih Fakultas Anda',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Setelah ini, Anda akan membuat NIM sesuai fakultas yang dipilih',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                                onPressed: _proceedToNIMBuilder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Lanjutkan ke Pembuatan NIM',
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