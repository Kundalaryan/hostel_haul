import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // 1. Minimum delay to show off your logo (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Check for Token
    String? token = await _storage.read(key: 'jwt_token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Token exists -> Go Home (Remove history)
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      // No token -> Go Login (Remove history)
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors from your design
    final primaryGreen = const Color(0xFF34D186);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Subtle gradient background like your design
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFE0F8ED).withOpacity(0.5) // Very light green tint at bottom
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(), // Pushes content to center

            // 1. Logo Container
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(30), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  // White border effect
                  const BoxShadow(
                      color: Colors.white,
                      spreadRadius: -5,
                      blurRadius: 0,
                      offset: Offset(0, 0)
                  )
                ],
              ),
              child: const Icon(
                  Icons.shopping_bag,
                  size: 60,
                  color: Colors.white
              ),
            ),

            const SizedBox(height: 30),

            // 2. App Name
            const Text(
              "GroceryFast",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            // 3. Tagline
            Text(
              "Freshness delivered.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 60),

            // 4. Loading Indicator
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primaryGreen,
              ),
            ),

            const Spacer(), // Pushes version to bottom

            // 5. Version Number
            Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}