// ignore: file_names
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

// ✅ SQLite-backed Task model & repository
import '../data/task_model.dart';
import '../data/task_repository.dart';

// ✅ SQLite-backed AppSettings
import '../data/app_settings_repository.dart';
import '../data/app_settings_model.dart';
import '../data/app_database.dart';

import 'package:tudu/screens/onboarding_screen.dart';

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
    debugPrint("⏰ Scheduling periodic alarm every minute");
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

  /// Replaces the old Hive updater: stores batteryUnrestricted in SQLite
  Future<void> settingsUpdater() async {
    // Ensure DB is opened in this isolate (and path sent to Android)
    await AppDatabase.instance.database;

    final repo = AppSettingsRepository();
    final cur = await repo.get();
    if (!cur.batteryUnrestricted) {
      await repo.setBatteryUnrestricted(true);
      debugPrint("✅ batteryUnrestricted set in SQLite");
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
        debugPrint("❌ Error parsing task date: $e");
        return false;
      }
    } else {
      // Handle recurring tasks
      final dayOfWeekIndex = now.weekday - 1; // Mon=1..Sun=7 -> 0..6
      return weekDays[dayOfWeekIndex];
    }
  }

  Future<void> _handleAlarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("✅ alarmCallback() triggered");

    // Ensure our DB is ready in this background isolate
    await AppDatabase.instance.database;

    // Update battery flag in SQLite (was Hive before)
    await settingsUpdater();

    // Read AppSettings from SQLite
    final settingsRepo = AppSettingsRepository();
    AppSettingsDB userSettings = await settingsRepo.get();

    // Prepare notifications plugin (safe to call repeatedly)
    await MediumNotification().initNotification();

    // ✅ Fetch tasks from SQLite
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

    debugPrint("outside forloop ${filteredTasks.length}");
    String Message = "";

    for (int i = 0; i < filteredTasks.length; i++) {
      debugPrint("inside for loop");
      final timeFormat = DateFormat("HH:mm");
      final parsedTime = timeFormat.parse(filteredTasks[i].fromTime);

      // Combine with today's date
      final now = DateTime.now();
      final todayTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      // Subtract 1 minute
      final reducedTime = todayTime.subtract(const Duration(minutes: 1));

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
          Message = "Starting soon ";
      }

      final nowStr = timeFormat.format(DateTime.now());
      final beforeStr = timeFormat.format(beforeTime);
      debugPrint("$nowStr and $beforeStr");

      if (beforeStr == nowStr) {
        final nowDate = DateFormat("d EEE MMM yyyy").format(DateTime.now());
        if (!filteredTasks[i].taskCompletionDates.contains(nowDate)) {
          if (filteredTasks[i].beforeMediumAlert) {
            await MediumNotification().showNotification(
              userSettings,
              filteredTasks[i],
              Message,
            );
          }
          if (filteredTasks[i].beforeLoudAlert) {
            // (Optional) trigger your full-screen/loud path here if you have one
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
          Message = "Its Time to Start ";
      }

      final afterStr = timeFormat.format(afterTime);
      debugPrint("$nowStr and $afterStr");

      if (afterStr == nowStr) {
        final nowDate = DateFormat("d EEE MMM yyyy").format(DateTime.now());
        if (!filteredTasks[i].taskCompletionDates.contains(nowDate)) {
          if (filteredTasks[i].afterMediumAlert) {
            await MediumNotification().showNotification(
              userSettings,
              filteredTasks[i],
              Message,
            );
          }
          if (filteredTasks[i].afterLoudAlert) {
            // (Optional) trigger your full-screen/loud path here if you have one
          }
        }
      }
    }
  }

  Future<void> stopPeriodicAlarm() async {
    await _notif.invokeMethod('stopPeriodicAlarm');
    const int alarmId = 1; // Must match scheduleAlarmEveryMinute
    final success = await AndroidAlarmManager.cancel(alarmId);
    if (success) {
      debugPrint('🛑 Periodic alarm canceled successfully');
    } else {
      debugPrint('⚠️ Failed to cancel periodic alarm');
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
  debugPrint("✅ alarmCallback() entry");
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
        await player.stop();
        final String? idFromPayload = response.payload;
        if (idFromPayload == null) return;

        // ✅ Use SQLite repo to update the task
        final TaskRepository repo = SqliteTaskRepository();
        final Task? t = await repo.getById(idFromPayload);

        if (response.actionId == 'action_1') {
          debugPrint('✅ Later button pressed');
          // (Optional snooze logic)
        } else if (response.actionId == 'action_2') {
          debugPrint('✅ Go button pressed');
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
            debugPrint("✅ Task updated in SQLite");

            // ✅ Show follow-up notification without action buttons
            await notificationPlugin.show(
              9999,
              'Task Started',
              '${t.title} marked as completed!',
              _simpleNotificationDetails(),
            );
          } else {
            debugPrint("⚠️ Task not found for ID: $idFromPayload");
          }
        } else {
          debugPrint('✅ Notification body tapped');
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
        playSound: false, // we play custom audio below
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

  /// Now accepts AppSettingsDB (SQLite) instead of Hive AppSettings
  Future<void> showNotification(AppSettingsDB settings, Task tasks, String message) async {
    // Keep your "align to minute" logic
    final now = DateTime.now();
    final currentSecond = now.second;
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

    // Play chosen tone if present, otherwise default asset
    if (settings.mediumAlertTone.isNotEmpty) {
      await player.play(DeviceFileSource(settings.mediumAlertTone));
    } else {
      await player.play(AssetSource('audio/medium.mp3'));
    }
  }
}
