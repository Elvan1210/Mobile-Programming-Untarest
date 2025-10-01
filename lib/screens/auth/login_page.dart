import 'package:flutter/material.dart';
import 'package:untarest_app/screens/auth/signup_page.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/utils/custom_widgets.dart';
import 'package:untarest_app/utils/constants.dart';
import 'login_signup_toggle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final user = await _authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (user != null && mounted) {
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
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Create an account',
                    style: TextStyle(color: primaryColor),
                  ),
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
