import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'database/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MaterialApp(  
    home: OnboardingScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
