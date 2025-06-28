// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'screens/onboarding_screen.dart';
// import 'database/hive_service.dart';
// import 'notification_service/notification_service.dart'; 

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final appDocumentDir = await getApplicationDocumentsDirectory();
//   await Hive.initFlutter(appDocumentDir.path);
//   await HiveService.init();

//   await AndroidAlarmManager.initialize();
//   await NotificationService().initNotification(); 

//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   runApp(MyApp());
// }


// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fullscreen App',
//       debugShowCheckedModeBanner: false,
//       home: FullScreenPage(),
//     );
//   }
// }
// class FullScreenPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light, // Adjust text/icon brightness if needed
//       child: Scaffold(
//         extendBody: true,
//         extendBodyBehindAppBar: true,
//         body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           color: Colors.transparent, // Your background color
//           alignment: Alignment.topCenter,
//           child: OnboardingScreen(),
//         ),
//       ),
//     );
//   }
// } 

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/lockscreen': (context) => LockScreenPage(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  static const MethodChannel _channel = MethodChannel('custom.alarm.channel');

  Future<void> scheduleAlarm() async {
    try {
      await _channel.invokeMethod('scheduleAlarm');
    } catch (e) {
      print('❌ Failed to call native alarm: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alarm LockScreen Trigger")),
      body: Center(
        child: ElevatedButton(
          onPressed: scheduleAlarm,
          child: Text("Trigger Lock Screen in 10s"),
        ),
      ),
    );
  }
}

class LockScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "🔒 Lock Screen Page",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
