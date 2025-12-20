import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// 1. Add SingleTickerProviderStateMixin for animations
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 2. Initialize the AnimationController
    // The animation lasts 2.5 seconds, reaching 100% just before navigation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start the animation
    _controller.forward();

    // 3. Navigation Timer
    // We wait 3 seconds total (0.5s longer than animation) so the user sees "100%" briefly
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF34E078);
    const Color darkGreen = Color(0xFF1D3028);
    const Color iconBackground = Color(0xFF1D3028);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // --- Logo Section ---
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_mall_outlined,
                  color: primaryGreen,
                  size: 35,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- App Title ---
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                children: [
                  TextSpan(text: "Fresh", style: TextStyle(color: darkGreen)),
                  TextSpan(text: "Mart", style: TextStyle(color: primaryGreen)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Fresh groceries in minutes",
              style: TextStyle(color: Colors.grey, fontSize: 16, letterSpacing: 0.5),
            ),

            const Spacer(),

            // --- Animated Loading Section ---
            // 4. Wrap the loading section in AnimatedBuilder to update UI every frame
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      // Loading Labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "LOADING",
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          // Dynamic Percentage Text
                          Text(
                            "${(_animation.value * 100).toInt()}%",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Custom Progress Bar
                      Stack(
                        children: [
                          // Background Bar
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // Animated Filled Bar
                          FractionallySizedBox(
                            widthFactor: _animation.value, // Dynamic Width (0.0 to 1.0)
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // --- Version Text ---
            const Text("v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}