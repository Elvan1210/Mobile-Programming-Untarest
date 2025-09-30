import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untarest_app/firebase_options.dart';
import 'package:untarest_app/screens/auth/login_page.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/screens/home/search_features.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNTAREST',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchFeatures(),
      },
    );
  }
}
