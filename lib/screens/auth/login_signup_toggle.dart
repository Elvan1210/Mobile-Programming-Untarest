import 'package:flutter/material.dart';
import 'package:untarest_app/screens/auth/signup_page.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/services/auth_service.dart';
import 'package:untarest_app/utils/custom_widgets.dart';
import 'package:untarest_app/utils/constants.dart';

class LoginSignupToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

  const LoginSignupToggle({
    super.key,
    required this.isLogin,
    required this.onLoginTap,
    required this.onSignupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onLoginTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut, // bikin smooth
                decoration: BoxDecoration(
                  color: isLogin ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLogin ? Colors.white : primaryColor,
                    ),
                    child: const Text("Login"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSignupTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isLogin ? Colors.white : primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLogin ? primaryColor : Colors.white,
                    ),
                    child: const Text("Sign Up"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
