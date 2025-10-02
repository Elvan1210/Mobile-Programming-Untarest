import 'package:flutter/material.dart';
import 'package:untarest_app/screens/auth/signup_page.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/utils/custom_widgets.dart';
import 'package:untarest_app/utils/constants.dart';
import 'login_signup_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool keepMeLoggedIn = false;

  Future<void> saveLoginState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepMeLoggedIn', value);
  }

  // --- MODIFIKASI: Ubah fungsi agar tidak memblokir ---
  void _checkLoginState() async {
    // Memberi jeda agar UI selesai dibangun terlebih dahulu
    await Future.delayed(Duration.zero);

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('keepMeLoggedIn') ?? false;
    
    // Pengecekan Firebase Auth juga penting
    if (loggedIn && FirebaseAuth.instance.currentUser != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // --- MODIFIKASI: Panggil fungsi tanpa await ---
    _checkLoginState();
  }

  void _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kolom tidak boleh kosong.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String? emailForLogin;

    if (identifier.contains('@')) {
      emailForLogin = identifier;
    } else {
      emailForLogin = await _firestoreService.getEmailFromUsername(identifier);
    }
    
    if(mounted) Navigator.of(context).pop();

    if (emailForLogin == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Pengguna tidak ditemukan.')),
        );
      }
      return;
    }
    
    try {
      final user = await _authService.signInWithEmailAndPassword(
        emailForLogin,
        password,
      );

      if (user != null && mounted) {
        if (keepMeLoggedIn) {
          await saveLoginState(true);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Periksa kembali kredensial Anda.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG_UNTAR.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    "assets/images/logo_UNTARESTBIG.png",
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 0),
                LoginSignupToggle(
                  isLogin: true,
                  onLoginTap: () {},
                  onSignupTap: () {
                    _navigateWithFade(context, const SignupPage());
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _identifierController,
                  hintText: 'Masukkan email atau username',
                  icon: Icons.person_outline,
                ),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Masukkan password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                CustomButton(text: 'Login', onPressed: _login),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Belum punya akun? ",
                          style: TextStyle(
                              color: Colors.black87, fontFamily: 'Poppins'),
                        ),
                        const TextSpan(
                          text: "Buat akun",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: keepMeLoggedIn,
                      onChanged: (val) {
                        setState(() => keepMeLoggedIn = val ?? false);
                      },
                    ),
                    const Text(
                      'Biarkan saya tetap login',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _navigateWithFade(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ));
}

