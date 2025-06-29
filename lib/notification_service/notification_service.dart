import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tudu/main.dart';
import '../models/settings.dart';
import '../screens/onboarding_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationService();
}

class NotificationService extends State<NotificationScreen> {
  NotificationService._privateConstructor();
  static final NotificationService _instance = NotificationService._privateConstructor();
  factory NotificationService() => _instance;
  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
  Future<void> initNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await notificationPlugin.initialize(initSettings);
  }


  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_channel',
        'Alarms',
        channelDescription: 'Channel for alarm notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
  
  Future<void> scheduleAlarmEveryMinute() async {
    const int alarmId = 1;
    const Duration interval = Duration(minutes: 1);

    print("⏰ Scheduling periodic alarm every minute");

    await AndroidAlarmManager.periodic(
      interval,
      alarmId,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }


  static Future<void> showNotification() async {
    print("✅ showNotification() executed");
    await _instance.notificationPlugin.show(
      0,
      'Alarm!',
      'This is your scheduled alarm notification.',
      _instance._notificationDetails(),
    );
  }
  Future<void> settingsUpdater() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    var settingsBox = await Hive.openBox<AppSettings>('settings');
    AppSettings? currentSettings = settingsBox.get('userSettings');
    if (currentSettings == null || !currentSettings.batteryUnrestricted) {
      print("✅ alarm inside");
      final updatedSettings = AppSettings(
        mediumAlertTone: currentSettings?.mediumAlertTone ?? "",
        loudAlertTone: currentSettings?.loudAlertTone ?? "",
        batteryUnrestricted: true,
      );
      await settingsBox.put('userSettings', updatedSettings);
    }
  }

  Future<void> _handleAlarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    print("✅ alarmCallback() triggered");
    NotificationService.showNotification();
    settingsUpdater();
  }


  @override
  Widget build(BuildContext context) {
    return OnboardingScreen();}
}

// ✅ Top-level function — required for AndroidAlarmManager
@pragma('vm:entry-point')
void alarmCallback() {
  // Always sync at top level
  print("✅ alarmCallback() entry");
  NotificationService()._handleAlarmCallback(); // async logic offloaded
}
