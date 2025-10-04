/// Faculty code validation utility for NIM validation
/// NIM format: [Faculty Code][Year][Sequential Number]
/// Example: 825240001 (FTI, 2024, student #001)

class FacultyValidation {
  // Faculty codes mapping - multiple codes per faculty supported
  static const Map<String, List<String>> facultyCodes = {
    'FK - Fakultas Kedokteran': ['405'],
    'FEB - Fakultas Ekonomi dan Bisnis': ['115', '125'],
    'FSRD - Fakultas Seni Rupa dan Desain': ['625', '615'],
    'FTI - Fakultas Teknologi Informasi': ['535', '825'],
    'FH - Fakultas Hukum': ['205'],
    'FPsi - Fakultas Ilmu Psikologi': ['705'],
    'FIKOM - Fakultas Ilmu Komunikasi': ['915'],
    'FT - Fakultas Teknik': ['325', '315', '515', '525', '545', '345'],
  };

  // Reverse mapping for easier lookup
  static const Map<String, String> codeToFaculty = {
    '405': 'FK - Fakultas Kedokteran',
    '115': 'FEB - Fakultas Ekonomi dan Bisnis',
    '125': 'FEB - Fakultas Ekonomi dan Bisnis',
    '705': 'FPsi - Fakultas Ilmu Psikologi',
    '535': 'FTI - Fakultas Teknologi Informasi',
    '825': 'FTI - Fakultas Teknologi Informasi',
    '205': 'FH - Fakultas Hukum',
    '625': 'FSRD - Fakultas Seni Rupa dan Desain',
    '615': 'FSRD - Fakultas Seni Rupa dan Desain',
    '915': 'FIKOM - Fakultas Ilmu Komunikasi',
    '325': 'FT - Fakultas Teknik',
    '315': 'FT - Fakultas Teknik',
    '515': 'FT - Fakultas Teknik',
    '525': 'FT - Fakultas Teknik',
    '545': 'FT - Fakultas Teknik',
    '345': 'FT - Fakultas Teknik',
  };

  /// Validate NIM format and return validation result
  /// Expected format: [3-digit faculty code][2-digit year][3-digit sequential number]
  /// Total length: 8 digits
  static NIMValidationResult validateNIM(String nim, String? selectedFaculty) {
    // Remove whitespace and convert to uppercase
    nim = nim.trim();

    // Check if NIM is exactly 8 digits
    if (nim.length != 8) {
      return NIMValidationResult(
        isValid: false,
        errorMessage: 'NIM harus terdiri dari 8 digit angka',
      );
    }

    // Check if NIM contains only digits
    if (!RegExp(r'^\d{8}$').hasMatch(nim)) {
      return NIMValidationResult(
        isValid: false,
        errorMessage: 'NIM hanya boleh berisi angka',
      );
    }

    // Extract components
    String facultyCode = nim.substring(0, 3);
    String year = nim.substring(3, 5);
    String sequentialNumber = nim.substring(5, 8);

    // Validate faculty code exists
    if (!codeToFaculty.containsKey(facultyCode)) {
      return NIMValidationResult(
        isValid: false,
        errorMessage: 'Kode fakultas "$facultyCode" tidak valid',
      );
    }

    // Validate year (should be between 20-99, representing 2020-2099)
    int yearInt = int.tryParse(year) ?? 0;
    if (yearInt < 20 || yearInt > 99) {
      return NIMValidationResult(
        isValid: false,
        errorMessage: 'Tahun dalam NIM tidak valid (harus 20-99)',
      );
    }

    // Validate sequential number (should not be 000)
    if (sequentialNumber == '000') {
      return NIMValidationResult(
        isValid: false,
        errorMessage: 'Nomor urut tidak boleh 000',
      );
    }

    // Check if faculty code matches selected faculty
    if (selectedFaculty != null) {
      List<String>? expectedCodes = facultyCodes[selectedFaculty];
      if (expectedCodes != null && !expectedCodes.contains(facultyCode)) {
        return NIMValidationResult(
          isValid: false,
          errorMessage: 'NIM tidak sesuai dengan fakultas yang dipilih.\n'
              'Fakultas: $selectedFaculty\n'
              'Kode yang diharapkan: ${expectedCodes.join(' atau ')}\n'
              'Kode dalam NIM: $facultyCode',
          suggestedFaculty: codeToFaculty[facultyCode],
        );
      }
    }

    return NIMValidationResult(
      isValid: true,
      facultyCode: facultyCode,
      year: '20$year',
      sequentialNumber: sequentialNumber,
      detectedFaculty: codeToFaculty[facultyCode],
    );
  }

  /// Get faculty codes for a given faculty name
  static List<String>? getFacultyCodes(String facultyName) {
    return facultyCodes[facultyName];
  }

  /// Get first faculty code for a given faculty name (for backward compatibility)
  static String? getFacultyCode(String facultyName) {
    final codes = facultyCodes[facultyName];
    return codes?.isNotEmpty == true ? codes!.first : null;
  }

  /// Get faculty name for a given faculty code
  static String? getFacultyName(String facultyCode) {
    return codeToFaculty[facultyCode];
  }

  /// Generate example NIM for a faculty
  static String generateExampleNIM(String facultyName) {
    List<String>? codes = getFacultyCodes(facultyName);
    if (codes == null || codes.isEmpty) return '';

    int currentYear = DateTime.now().year % 100; // Get last 2 digits of year
    return '${codes.first}${currentYear.toString().padLeft(2, '0')}001';
  }

  /// Generate all possible example NIMs for a faculty
  static List<String> generateAllExampleNIMs(String facultyName) {
    List<String>? codes = getFacultyCodes(facultyName);
    if (codes == null || codes.isEmpty) return [];

    int currentYear = DateTime.now().year % 100;
    return codes
        .map((code) => '${code}${currentYear.toString().padLeft(2, '0')}001')
        .toList();
  }

  /// Format NIM with separators for display
  static String formatNIMDisplay(String nim) {
    if (nim.length != 8) return nim;
    return '${nim.substring(0, 3)}-${nim.substring(3, 5)}-${nim.substring(5, 8)}';
  }
}

/// Result class for NIM validation
class NIMValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? facultyCode;
  final String? year;
  final String? sequentialNumber;
  final String? detectedFaculty;
  final String? suggestedFaculty;

  const NIMValidationResult({
    required this.isValid,
    this.errorMessage,
    this.facultyCode,
    this.year,
    this.sequentialNumber,
    this.detectedFaculty,
    this.suggestedFaculty,
  });

  @override
  String toString() {
    if (isValid) {
      return 'Valid NIM: $facultyCode-$year-$sequentialNumber ($detectedFaculty)';
    } else {
      return 'Invalid NIM: $errorMessage';
    }
  }
}
