import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'database/hive_service.dart';
import 'notification_service/notification_service.dart'; 
import 'notification_service/alarm_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await HiveService.init();
  await AndroidAlarmManager.initialize();
  await MediumNotification().initNotification(); 
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _startPage;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Initialize notifications with context
    await FullScreenNotification().initNotification(context);

    // Check if app was launched from notification
    final details =
        await FullScreenNotification().notificationPlugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse?.payload != null) {
        final parts = details.notificationResponse!.payload!.split('|');
        final taskId = parts[0];
        final message = parts.length > 1 ? parts[1] : "";
        _startPage = AlarmScreen(taskId: taskId, message: message); // 👈 pass taskId here
      } else {
        _startPage = FullScreenPage();
      }
    } else {
      _startPage = FullScreenPage();
    }


    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      home: _startPage
    );
  }
}



class AlarmService {
  static const MethodChannel _channel = MethodChannel('custom.alarm.channel');
  static Future<void> scheduleAlarm() async {
    try {
      await _channel.invokeMethod('scheduleAlarm');
    } catch (e) {
      print('❌ Failed to call native alarm: $e');
    }
  }
}

class FullScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // No background
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black, // Use a solid color
        body: MediaQuery.removeViewPadding(
          context: context,
          removeTop: true, // ✅ This removes the gap
          child: NotificationScreen(), // or whatever your content is
        ),
      ),
    );
  }
} 