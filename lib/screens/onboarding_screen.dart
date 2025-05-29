import 'package:flutter/material.dart';
import 'dart:async';
import 'task_screen.dart'; // Replace with your actual home screen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  double leftOffset = 0;
  double greenWidth = 304.39;
  double greenHeight = 346.75;
  double yellowWidth = 228.74;
  double yellowHeight = 230.82;
  double darkWidth = 325.16;
  double darkHeight = 222.73;

  double greenLeft = 56 - 221.52;
  double greenBottom = 36 - 100.4;
  double yellowRight = 27 - 168.18;
  double yellowBottom = 26 - 89.15;
  double darkRight = 15 - 122.77;
  double darkTop = 62 - 141.1;
  
  
  @override
  void initState() {
    super.initState();
    // Trigger size animation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        leftOffset = -403;
        
        greenWidth = 337.6;
        greenHeight = 41.82;
        greenLeft = 56 - 187.36;
        greenBottom = 36 - 151.14;

        yellowWidth = 19.5;
        yellowHeight = 593.67;
        yellowRight = 27 - 324.99;
        yellowBottom = 26 - 115.04;

        darkWidth = 1223.27;
        darkHeight = 1060.32;
        darkTop = 62 - 330.07;
        darkRight = 15 - 402.61;
      });
    });
    // Navigate to HomeScreen after animation
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (_, __, ___) => TaskScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ));
    });


  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF2C9C94),
      body: Stack(
        children: [
          // Center content
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).size.height / 2 - 100,
            left: screenWidth / 2 - 200 + leftOffset,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 73,
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    "Stay On Track. Stay In Flow",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins-Regular',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10.5),
                  Image.asset(
                    'assets/dots.png',
                    height: 32,
                  ),
                ],
              ),
            ),
          ),
          // ✅ Green shape with animated size
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            bottom: greenBottom,
            left: greenLeft,
            child: Transform.rotate(
              angle: 41.29 * 3.1416 / 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: greenWidth,
                height: greenHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFFBFF6E5),
                  borderRadius: BorderRadius.all(Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Yellow shape (bottom-right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            bottom: yellowBottom,
            right: yellowRight,
            child: Transform.rotate(
              angle: 41.29 * 3.1416 / 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: yellowWidth,
                height: yellowHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEDB8A),
                  borderRadius: BorderRadius.all(Radius.circular(34)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Dark shape (top-right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: darkTop,
            right: darkRight,
            child: Transform.rotate(
              angle: 41.29 * 3.1416 / 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: darkWidth,
                height: darkHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFF313036),
                  borderRadius: BorderRadius.all(Radius.circular(43)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
