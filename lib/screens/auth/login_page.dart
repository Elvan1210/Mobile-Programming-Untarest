import 'package:flutter/material.dart';
import 'package:untarest_app/screens/auth/signup_page.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/utils/custom_widgets.dart';
import 'package:untarest_app/utils/constants.dart';
import 'login_signup_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool keepMeLoggedIn = false;

  Future<void> saveLoginState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepMeLoggedIn', value);
  }

  Future<void> checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('keepMeLoggedIn') ?? false;
    if (loggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginState();
  }

  void _login() async {
    final user = await _authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (user != null && mounted) {
      if (keepMeLoggedIn) {
        await saveLoginState(true);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Check your credentials.')),
      );
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

                //TOGGLE
                LoginSignupToggle(
                  isLogin: true,
                  onLoginTap: () {},
                  onSignupTap: () {
                    _navigateWithFade(context, const SignupPage());
                  },
                ),

                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  icon: Icons.email,
                ),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
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
                          text: "Don't have an account? ",
                          style: TextStyle(
                              color: Colors.black87, fontFamily: 'Poppins'),
                        ),
                        const TextSpan(
                          text: "Create an account",
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
                      'Keep me logged in',
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
