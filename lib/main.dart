import 'package:flutter/material.dart';
import 'package:hostel_haul/presentation/screens/login_screen.dart';
import 'package:hostel_haul/presentation/screens/splash_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Delivery',
      debugShowCheckedModeBanner: false, // Removes the 'DEBUG' banner

      // 1. Theme Configuration (Matches your Green Design)
      theme: ThemeData(
        primaryColor: const Color(0xFF34D186),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF34D186),
          primary: const Color(0xFF34D186),
        ),
      ),

      // 2. Route Configuration
      // This maps the string '/login' to the actual LoginScreen widget
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}