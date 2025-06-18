import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'database/hive_service.dart';
import 'package:flutter/services.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await HiveService.init();
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   runApp(const MaterialApp(  
//     home: OnboardingScreen(),
//     debugShowCheckedModeBanner: false,
//   ));
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fullscreen App',
      debugShowCheckedModeBanner: false,
      home: FullScreenPage(),
    );
  }
}

class FullScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // Adjust text/icon brightness if needed
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent, // Your background color
          alignment: Alignment.topCenter,
          child: OnboardingScreen(),
        ),
      ),
    );
  }
}
