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
    // Future.delayed(const Duration(seconds: 3), () {
    //   setState(() {
    //     leftOffset = -403;
        
    //     greenWidth = 337.6;
    //     greenHeight = 41.82;
    //     greenLeft = 56 - 187.36;
    //     greenBottom = 36 - 151.14;

    //     yellowWidth = 19.5;
    //     yellowHeight = 593.67;
    //     yellowRight = 27 - 324.99;
    //     yellowBottom = 26 - 115.04;

    //     darkWidth = 1223.27;
    //     darkHeight = 1360.32;
    //     darkTop = 62 - 410.07;
    //     darkRight = 15 - 482.61;
    //   });
    // });
    // Navigate to HomeScreen after animation
    // Future.delayed(const Duration(seconds: 4), () {
    //   Navigator.of(context).pushReplacement(PageRouteBuilder(
    //     transitionDuration: const Duration(milliseconds: 1500),
    //     pageBuilder: (_, __, ___) => TaskScreen(),
    //     transitionsBuilder: (_, animation, __, child) {
    //       return FadeTransition(opacity: animation, child: child);
    //     },
    //   ));
    // });


  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF2C9C94),
      body: Stack(
        children: [
          // Center content
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: screenHeight / 2 - 100,
            left: screenWidth / 2 - ((screenWidth * 1.03)/2) + leftOffset,
            child: SizedBox(
              width: screenWidth * 1.03,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 0.4045 * screenWidth,
                  ),
                  SizedBox(height: 0.03 * screenHeight),
                  Text(
                    "Stay On Track. Stay In Flow",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins-Regular',
                      fontSize: 0.0582 * screenWidth,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.0114 * screenHeight),
                  Image.asset(
                    'assets/dots.png',
                    width: 0.6407 * screenWidth,
                  ),
                ],
              ),
            ),
          ),
          // ✅ Green shape with animated size
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            bottom: greenBottom / 917 * screenHeight,
            left: greenLeft / 412 * screenWidth,
            child: Transform.rotate(
              angle: 41.29 * 3.1416 / 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: greenWidth / 412 * screenWidth,
                height: greenHeight / 917 * screenHeight,
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
            bottom: yellowBottom / 917 * screenHeight,
            right: yellowRight / 412 * screenWidth,
            child: Transform.rotate(
              angle: 41.29 * 3.1416 / 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: yellowWidth / 412 * screenWidth,
                height: yellowHeight / 917 * screenHeight,
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
            top: darkTop / 917 * screenHeight,
            right: darkRight / 412 * screenWidth,
            child: Transform.rotate(
              angle: 41.29 * 3.1416 / 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: darkWidth / 412 * screenWidth,
                height: darkHeight / 917 * screenHeight,
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
