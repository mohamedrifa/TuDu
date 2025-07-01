import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/settings.dart';
import '../models/task.dart';
import '../screens/onboarding_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationService();
}

class NotificationService extends State<NotificationScreen> {
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

  bool allDaysFalse(List weekDays) {
    for (var day in weekDays) {
      if (day) return false;
    }
    return true;
  }

  bool filteredList(String date, List<bool> weekDays, bool isImportant, String taskScheduleddate) {
    final now = DateTime.now();
    if (allDaysFalse(weekDays)) {
      // Handle one-time tasks
      try {
        final taskDate = DateFormat("d MM yyyy").parse(date);
        return DateFormat("d MM yyyy").format(taskDate) == DateFormat("d MM yyyy").format(now);
      } catch (e) {
        print("❌ Error parsing task date: $e");
        return false;
      }
    } else {
      // Handle recurring tasks
      final dayOfWeekIndex = now.weekday % 7; // Dart: Mon = 1, ..., Sun = 7 → index 0-6
      return weekDays[dayOfWeekIndex];
    }
  }


  Future<void> _handleAlarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    print("✅ alarmCallback() triggered");
    // ✅ Initialize Hive again for background context
    await Hive.initFlutter();
    // ✅ Only register if not already registered
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }

    // ✅ Open the box again
    final box = await Hive.openBox<Task>('tasks');

    final tasks = box.values.toList();

    final filteredTasks = tasks
        .where((task) => filteredList(
              task.date,
              task.weekDays,
              task.important,
              task.taskScheduleddate,
            ))
        .toList();
    MediumNotification().showNotification();
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


class MediumNotification {
  MediumNotification._privateConstructor();
  static final MediumNotification _instance = MediumNotification._privateConstructor();
  factory MediumNotification() => _instance;
  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
  Future<void> initNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle button taps here
        if (response.actionId == 'action_1') {
          print('✅ Snooze button pressed');
          // Add logic for snooze
        } else if (response.actionId == 'action_2') {
          print('✅ Dismiss button pressed');
          // Add logic for dismiss
        } else {
          print('✅ Notification body tapped');
        }
      },
    );
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
        ongoing: true,
        autoCancel: false,
        visibility: NotificationVisibility.public,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'action_1', // action id
            'Snooze',   // button text
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'action_2',
            'Dismiss',
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification() async {
    await notificationPlugin.show(
      0,
      '⏰ Alarm!',
      'This is your scheduled alarm as notification.',
      _notificationDetails(),
      payload: 'default_payload', // optional
    );
  }
}