// ignore: file_names
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tudu/screens/onboarding_screen.dart';
import '../models/settings.dart';
import 'package:audioplayers/audioplayers.dart';

// ✅ SQLite-backed Task model & repository
import '../data/task_model.dart';
import '../data/task_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationService();
}

class NotificationService extends State<NotificationScreen> {
  static const _notif = MethodChannel('app.notifications');
  Future<void> scheduleAlarmEveryMinute() async {
    const int alarmId = 1;
    const Duration interval = Duration(minutes: 1);
    print("⏰ Scheduling periodic alarm every minute");
    await _notif.invokeMethod('scheduleAlarmEveryMinute');
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
      final dayOfWeekIndex = now.weekday - 1; // Dart: Mon = 1, ..., Sun = 7 → index 0-6
      return weekDays[dayOfWeekIndex];
    }
  }

  Future<void> _handleAlarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    print("✅ alarmCallback() triggered");

    // Hive only for AppSettings
    await Hive.initFlutter();
    await settingsUpdater();
    if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    if (Hive.isBoxOpen('settings')) {
      await Hive.box<AppSettings>('settings').close();
    }
    final settingsBox = await Hive.openBox<AppSettings>('settings');
    final AppSettings? userSettings = await settingsBox.get('userSettings');

    // ✅ Fetch tasks from SQLite instead of Hive
    final TaskRepository repo = SqliteTaskRepository();
    final List<Task> tasks = await repo.getAll();

    final filteredTasks = tasks
        .where((task) => filteredList(
              task.date,
              task.weekDays,
              task.important,
              task.taskScheduleddate,
            ))
        .toList();

    print("outside forloop ${filteredTasks.length}");
    String Message = "";

    for (int i = 0; i < filteredTasks.length; i++) {
      print("inside for loop");
      DateFormat timeFormat = DateFormat("HH:mm");
      DateTime parsedTime = timeFormat.parse(filteredTasks[i].fromTime);

      // Combine with today's date
      DateTime now = DateTime.now();
      DateTime todayTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      // Subtract 1 minute
      DateTime reducedTime = todayTime.subtract(const Duration(minutes: 1));

      // BEFORE
      DateTime beforeTime;
      switch (filteredTasks[i].selectedBefore) {
        case "5 Mins":
          beforeTime = reducedTime.subtract(const Duration(minutes: 5));
          Message = "5 Minutes to Start ";
          break;
        case "10 Mins":
          beforeTime = reducedTime.subtract(const Duration(minutes: 10));
          Message = "10 Minutes to Start ";
          break;
        case "15 Mins":
          beforeTime = reducedTime.subtract(const Duration(minutes: 15));
          Message = "15 Minutes to Start ";
          break;
        default:
          beforeTime = reducedTime;
      }

      String nowStr = timeFormat.format(DateTime.now());
      String beforeStr = timeFormat.format(beforeTime);
      print("$nowStr and $beforeStr");

      if (beforeStr == nowStr) {
        DateFormat nowFormat = DateFormat("d EEE MMM yyyy");
        String nowDate = nowFormat.format(DateTime.now());
        if (!filteredTasks[i].taskCompletionDates.contains(nowDate)) {
          if (filteredTasks[i].beforeMediumAlert) {
            MediumNotification().showNotification(
              userSettings ??
                  AppSettings(
                    mediumAlertTone: '',
                    loudAlertTone: '',
                    batteryUnrestricted: true,
                  ),
              filteredTasks[i],
              Message,
            );
          }
          if (filteredTasks[i].beforeLoudAlert) {
            
          }
        }
      }

      // AFTER
      DateTime afterTime;
      switch (filteredTasks[i].selectedAfter) {
        case "On Time":
          afterTime = reducedTime;
          Message = "Its Time to Start ";
          break;
        case "5 Mins":
          afterTime = reducedTime.add(const Duration(minutes: 5));
          Message = "5 Mins Passed for ";
          break;
        case "10 Mins":
          afterTime = reducedTime.add(const Duration(minutes: 10));
          Message = "10 Mins Passed for ";
          break;
        default:
          afterTime = reducedTime;
      }

      String afterStr = timeFormat.format(afterTime);
      print("$nowStr and $afterStr");

      if (afterStr == nowStr) {
        DateFormat nowFormat = DateFormat("d EEE MMM yyyy");
        String nowDate = nowFormat.format(DateTime.now());
        if (!filteredTasks[i].taskCompletionDates.contains(nowDate)) {
          if (filteredTasks[i].afterMediumAlert) {
            MediumNotification().showNotification(
              userSettings ??
                  AppSettings(
                    mediumAlertTone: '',
                    loudAlertTone: '',
                    batteryUnrestricted: true,
                  ),
              filteredTasks[i],
              Message,
            );
          }
          if (filteredTasks[i].afterLoudAlert) {
            
          }
        }
      }
    }
  }

  Future<void> stopPeriodicAlarm() async {
    await _notif.invokeMethod('stopPeriodicAlarm');
    const int alarmId = 1; // Must match the ID used in scheduleAlarmEveryMinute
    final success = await AndroidAlarmManager.cancel(alarmId);
    if (success) {
      print('🛑 Periodic alarm canceled successfully');
    } else {
      print('⚠️ Failed to cancel periodic alarm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const OnboardingScreen();
  }
}

// ✅ Top-level function — required for AndroidAlarmManager
@pragma('vm:entry-point')
void alarmCallback() {
  // Always sync at top level
  DartPluginRegistrant.ensureInitialized();
  print("✅ alarmCallback() entry");
  NotificationService()._handleAlarmCallback(); // async logic offloaded
}

class MediumNotification {
  MediumNotification._privateConstructor();
  static final MediumNotification _instance = MediumNotification._privateConstructor();
  factory MediumNotification() => _instance;

  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
  final AudioPlayer player = AudioPlayer();
  String taskId = "";

  Future<void> initNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        player.stop();
        final String? idFromPayload = response.payload;
        if (idFromPayload == null) return;

        // ✅ Use SQLite repo to update the task instead of Hive
        final TaskRepository repo = SqliteTaskRepository();
        final Task? t = await repo.getById(idFromPayload);

        if (response.actionId == 'action_1') {
          print('✅ Later button pressed');
          // (Optional snooze logic)
        } else if (response.actionId == 'action_2') {
          print('✅ Go button pressed');
          if (t != null) {
            final date = DateFormat('d EEE MMM yyyy').format(DateTime.now());
            final dates = List<String>.from(t.taskCompletionDates);
            if (!dates.contains(date)) dates.add(date);

            final updated = Task(
              id: t.id,
              title: t.title,
              date: t.date,
              weekDays: t.weekDays,
              fromTime: t.fromTime,
              toTime: t.toTime,
              tags: t.tags,
              important: t.important,
              location: t.location,
              subTask: t.subTask,
              beforeLoudAlert: t.beforeLoudAlert,
              beforeMediumAlert: t.beforeMediumAlert,
              afterLoudAlert: t.afterLoudAlert,
              afterMediumAlert: t.afterMediumAlert,
              selectedBefore: t.selectedBefore,
              selectedAfter: t.selectedAfter,
              taskCompletionDates: dates,
              taskScheduleddate: t.taskScheduleddate,
            );

            await repo.upsert(updated);
            print("✅ Task updated in SQLite");

            // ✅ Show follow-up notification without action buttons
            await notificationPlugin.show(
              9999,
              'Task Started',
              '${t.title} marked as completed!',
              _simpleNotificationDetails(),
            );
          } else {
            print("⚠️ Task not found for ID: $idFromPayload");
          }
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
        playSound: false,
        enableVibration: true,
        enableLights: true,
        ongoing: true,
        autoCancel: false,
        visibility: NotificationVisibility.public,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'action_1',
            'Later',
            showsUserInterface: true,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            'action_2',
            'Go',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  NotificationDetails _simpleNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'simple_channel',
        'General',
        channelDescription: 'Simple notification without actions',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification(AppSettings settings, Task tasks, String message) async {
    // Keep your "align to minute" logic
    DateTime now = DateTime.now();
    int currentSecond = now.second;
    await Future.delayed(Duration(seconds: 60 - currentSecond));

    taskId = tasks.id;
    int id;
    try {
      id = int.parse(tasks.id) % 2147483647;
    } catch (_) {
      // Fallback if id is not numeric
      id = tasks.id.hashCode & 0x7fffffff;
    }

    await notificationPlugin.show(
      id,
      tasks.title,
      "$message${tasks.title}",
      _notificationDetails(),
      payload: tasks.id,
    );

    if (settings.mediumAlertTone.isNotEmpty) {
      await player.play(DeviceFileSource(settings.mediumAlertTone));
    } else {
      await player.play(AssetSource('audio/medium.mp3'));
    }
  }
}
