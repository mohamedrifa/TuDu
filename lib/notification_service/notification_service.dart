import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
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


  Future<void> scheduleAlarmAt(DateTime dateTime) async {
    final int alarmId = 1;
    Duration delay = dateTime.difference(DateTime.now());
    if (delay.isNegative) delay = Duration(seconds: 5); // fallback
    print("alarm scheduled");
    await AndroidAlarmManager.oneShot(
      delay,
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
}

// ✅ Top-level function — required for AndroidAlarmManager
@pragma('vm:entry-point')
void alarmCallback() {
  WidgetsFlutterBinding.ensureInitialized();
  print("✅ alarmCallback() triggered");
  NotificationService.showNotification();
}
