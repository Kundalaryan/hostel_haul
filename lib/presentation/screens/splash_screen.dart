import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import this

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
    await Future.delayed(const Duration(seconds: 2));

    String? token = await _storage.read(key: 'jwt_token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // --- THE NEW LOGIC ---
      bool isExpired = JwtDecoder.isExpired(token);

      if (isExpired) {
        // Token is old -> Delete it and Go to Login
        await _storage.delete(key: 'jwt_token');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        // Token is good -> Go Home
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
      // ---------------------
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF34D186);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const Color(0xFFE0F8ED).withOpacity(0.5)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 120, width: 120,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.shopping_bag, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 30),
            const Text("GroceryFast", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text("Freshness delivered.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 60),
            SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: primaryGreen)),
            const Spacer(),
            Text("Version 1.0.0", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}