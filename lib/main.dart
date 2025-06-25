import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/onboarding_screen.dart';
import 'database/hive_service.dart';
import 'notification_service/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await HiveService.init();

  await AndroidAlarmManager.initialize();
  await NotificationService().initNotification(); 

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