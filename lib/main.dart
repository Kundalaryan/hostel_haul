import 'package:flutter/material.dart';
import 'splash_screen.dart'; // <--- 1. Add this import

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grocery App',
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light, // Changed to Light for Splash Screen context
        // Note: The Login screen overrides background color individually,
        // so changing this to light won't break the dark mode login.
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // <--- 2. Change this from LoginScreen to SplashScreen
    );
  }
}