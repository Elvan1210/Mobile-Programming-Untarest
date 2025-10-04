import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untarest_app/screens/auth/faculty_selection_page.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/utils/faculty_validation.dart';

class NIMBuilderPage extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String selectedFaculty;

  const NIMBuilderPage({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    required this.selectedFaculty,
  });

  @override
  State<NIMBuilderPage> createState() => _NIMBuilderPageState();
}

class _NIMBuilderPageState extends State<NIMBuilderPage> {
  String? _selectedFacultyCode;
  int? _selectedYear;
  final _sequentialController = TextEditingController();
  String _constructedNIM = '';

  @override
  void initState() {
    super.initState();
    _updateConstructedNIM();
  }

  @override
  void dispose() {
    _sequentialController.dispose();
    super.dispose();
  }

  void _updateConstructedNIM() {
    if (_selectedFacultyCode != null && _selectedYear != null && _sequentialController.text.isNotEmpty) {
      String year = (_selectedYear! % 100).toString().padLeft(2, '0');
      String sequential = _sequentialController.text.padLeft(3, '0');
      setState(() {
        _constructedNIM = '$_selectedFacultyCode$year$sequential';
      });
    } else {
      setState(() {
        _constructedNIM = '';
      });
    }
  }

  void _proceedToFacultySelection() {
    if (_constructedNIM.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi semua komponen NIM')),
      );
      return;
    }

    // Validate the constructed NIM
    final validation = FacultyValidation.validateNIM(_constructedNIM, widget.selectedFaculty);
    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NIM tidak valid: ${validation.errorMessage}')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultySelectionPage(
          username: widget.username,
          email: widget.email,
          password: widget.password,
          nim: _constructedNIM,
          detectedFaculty: widget.selectedFaculty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facultyCodes = FacultyValidation.getFacultyCodes(widget.selectedFaculty) ?? [];
    final currentYear = DateTime.now().year;
    
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
                                height: 80,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Buat NIM Anda',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.selectedFaculty,
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            
                            // Faculty Code Selection
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Step 1: Pilih Kode Fakultas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...facultyCodes.map((code) => RadioListTile<String>(
                                    title: Text(
                                      code,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Kode $code untuk ${widget.selectedFaculty}'),
                                    value: code,
                                    groupValue: _selectedFacultyCode,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedFacultyCode = value;
                                      });
                                      _updateConstructedNIM();
                                    },
                                    activeColor: primaryColor,
                                  )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Year Selection
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Step 2: Pilih Tahun Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      hintText: 'Pilih tahun masuk',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    value: _selectedYear,
                                    items: List.generate(10, (index) {
                                      int year = currentYear - index;
                                      return DropdownMenuItem<int>(
                                        value: year,
                                        child: Text('$year'),
                                      );
                                    }),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedYear = value;
                                      });
                                      _updateConstructedNIM();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Sequential Number Input
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Step 3: Masukkan Nomor Urut',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _sequentialController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Contoh: 001, 027, 156',
                                      helperText: 'Nomor urut 1-999 (akan diformat menjadi 3 digit)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    onChanged: (value) {
                                      _updateConstructedNIM();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // NIM Preview
                            if (_constructedNIM.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green[300]!),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Preview NIM Anda:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      FacultyValidation.formatNIMDisplay(_constructedNIM),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'NIM: $_constructedNIM',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),
                            
                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _constructedNIM.isNotEmpty ? _proceedToFacultySelection : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Lanjutkan',
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