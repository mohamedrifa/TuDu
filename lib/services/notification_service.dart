import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tudu/services/effect_service.dart';
import 'package:tudu/services/task_widget_helper.dart';
import 'package:volume_controller/volume_controller.dart';
import '../models/settings.dart';
import '../models/task.dart';
import '../main.dart' show navigatorKey;
import 'package:audioplayers/audioplayers.dart';
import '../screens/alarm_screen.dart';

class NotificationService {
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

  bool allDaysFalse(List weekDays) {
    for (final day in weekDays) {
      if (day) return false;
    }
    return true;
  }

  bool filteredList(
    String date,
    List<bool> weekDays,
    bool isImportant,
    String taskScheduleddate,
  ) {
    final now = DateTime.now();

    if (allDaysFalse(weekDays)) {
      // One-time tasks
      try {
        final taskDate = DateFormat("d MM yyyy").parse(date);
        final todayStr = DateFormat("d MM yyyy").format(now);
        return DateFormat("d MM yyyy").format(taskDate) == todayStr;
      } catch (e) {
        print("❌ Error parsing task date: $e");
        return false;
      }
    } else {
      // Recurring tasks
      final int dayOfWeekIndex = now.weekday - 1; // 0 (Mon) ... 6 (Sun)
      return weekDays[dayOfWeekIndex];
    }
  }

  Future<void> _handleAlarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    print("✅ alarmCallback() triggered");
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
      Hive.registerAdapter(SettingsAdapter());
    }

    if (Hive.isBoxOpen('tasks')) {
      await Hive.box<Task>('tasks').close();
    }
    final taskBox = await Hive.openBox<Task>('tasks'); // refreshed

    if (Hive.isBoxOpen('settings')) {
      await Hive.box<AppSettings>('settings').close();
    }
    final settingsBox = await Hive.openBox<AppSettings>('settings');
    final AppSettings? userSettings = settingsBox.get('userSettings');

    final tasks = taskBox.values.toList();

    final filteredTasks = tasks
        .where(
          (task) => filteredList(
            task.date,
            task.weekDays,
            task.important,
            task.taskScheduleddate,
          ),
        )
        .toList();

    print("outside forloop ${filteredTasks.length}");

    String message = "";
    for (int i = 0; i < filteredTasks.length; i++) {
      print("inside for loop");

      final timeFormat = DateFormat("HH:mm");
      final DateTime parsedTime = timeFormat.parse(filteredTasks[i].fromTime);

      final DateTime now = DateTime.now();

      if (now.hour == 0 && now.minute == 0) {
        TaskWidgetHelper.updateTasksWidget(tasks);
      }

      final DateTime todayTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );
      DateTime toFireAt;
      // Subtract 1 minute
      final DateTime reducedTime = todayTime.subtract(const Duration(minutes: 1));

      // BEFORE alerts
      DateTime beforeTime;
      switch (filteredTasks[i].alertBefore) {
        case "5 Mins":
          beforeTime = reducedTime.subtract(const Duration(minutes: 5));
          toFireAt = reducedTime.subtract(const Duration(minutes: 4));
          message = "5 Minutes to Start ";
          break;
        case "10 Mins":
          beforeTime = reducedTime.subtract(const Duration(minutes: 10));
          toFireAt = reducedTime.subtract(const Duration(minutes: 9));
          message = "10 Minutes to Start ";
          break;
        case "15 Mins":
          beforeTime = reducedTime.subtract(const Duration(minutes: 15));
          toFireAt = reducedTime.subtract(const Duration(minutes: 14));
          message = "15 Minutes to Start ";
          break;
        default:
          toFireAt = reducedTime.add(const Duration(minutes: 1));
          beforeTime = reducedTime;
      }

      final String nowStr = timeFormat.format(DateTime.now());
      final String beforeStr = timeFormat.format(beforeTime);
      print("$nowStr and $beforeStr");

      if (beforeStr == nowStr) {
        final nowFormat = DateFormat("d EEE MMM yyyy");
        final String nowDate = nowFormat.format(DateTime.now());

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
              message,
              toFireAt,
            );
          }
          if (filteredTasks[i].beforeLoudAlert) {
            FullScreenNotification().showNotification(
              filteredTasks[i],
              message,
              toFireAt
            );
          }
        }
      }

      // AFTER alerts
      DateTime afterTime;
      switch (filteredTasks[i].alertAfter) {
        case "On Time":
          afterTime = reducedTime;
          toFireAt = reducedTime.add(const Duration(minutes: 1));
          message = "Its Time to Start ";
          break;
        case "5 Mins":
          afterTime = reducedTime.add(const Duration(minutes: 5));
          toFireAt = reducedTime.add(const Duration(minutes: 6));
          message = "5 Mins Passed for ";
          break;
        case "10 Mins":
          afterTime = reducedTime.add(const Duration(minutes: 10));
          toFireAt = reducedTime.add(const Duration(minutes: 11));
          message = "10 Mins Passed for ";
          break;
        default:
          afterTime = reducedTime;
          toFireAt = reducedTime.add(const Duration(minutes: 1));
      }

      final String afterStr = timeFormat.format(afterTime);
      print("$nowStr and $afterStr");

      if (afterStr == nowStr) {
        final nowFormat = DateFormat("d EEE MMM yyyy");
        final String nowDate = nowFormat.format(DateTime.now());

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
              message,
              toFireAt,
            );
          }
          if (filteredTasks[i].afterLoudAlert) {
            FullScreenNotification().showNotification(
              filteredTasks[i],
              message,
              toFireAt,
            );
          }
        }
      }
    }
  }

  Future<void> stopPeriodicAlarm() async {
    const int alarmId = 1; // must match scheduleAlarmEveryMinute
    final success = await AndroidAlarmManager.cancel(alarmId);
    if (success) {
      print('🛑 Periodic alarm canceled successfully');
    } else {
      print('⚠️ Failed to cancel periodic alarm');
    }
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
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        player.stop();
        final String? idFromPayload = response.payload;
        if (idFromPayload == null) return;

        // ✅ Ensure Hive is initialized and box is open
        if (!Hive.isBoxOpen('tasks')) {
          await Hive.initFlutter();
          if (!Hive.isAdapterRegistered(0)) {
            Hive.registerAdapter(TaskAdapter()); // Replace 0 with your Task typeId
          }
          await Hive.openBox<Task>('tasks');
        }

        final box = Hive.box<Task>('tasks');
        final task = box.get(idFromPayload);
        final tasks = box.values.toList();
        TaskWidgetHelper.updateTasksWidget(tasks);

        if (response.actionId == 'action_1') {
          print('✅ Later button pressed');
        } else if (response.actionId == 'action_2') {
          print('✅ Go button pressed');
          if (task != null) {
            final date = DateFormat('d EEE MMM yyyy').format(DateTime.now());
            task.taskCompletionDates.add(date);
            await box.put(idFromPayload, task);
            print("✅ Task updated in Hive");

            // ✅ Show follow-up notification without action buttons
            await notificationPlugin.show(
              7777,
              'Task Started',
              '${task.title} marked as completed!',
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

  Future<void> showNotification(AppSettings settings, Task tasks, String message, DateTime toFireAt) async {
    final DateTime now = DateTime.now();
    final int currentSecond = now.second;
    if(DateTime.now().isBefore(toFireAt)) {
      await Future.delayed(Duration(seconds: 60 - currentSecond));
    }
    taskId = tasks.id;
    final int id = int.parse(tasks.id) % 2147483647;

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

class FullScreenNotification {
  FullScreenNotification._privateConstructor();
  static final FullScreenNotification _instance = FullScreenNotification._privateConstructor();
  factory FullScreenNotification() => _instance;

  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
  String taskId = "";
  bool _listening = false;

  Future<void> initNotification() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await EffectService().stopEffect();

        final String? idFromPayload = response.payload;
        if (idFromPayload == null) return;

        final parts = idFromPayload.split('|');
        final String tappedTaskId = parts[0];
        final String message = parts.length > 1 ? parts[1] : "";

        // ✅ Ensure Hive is ready
        if (!Hive.isBoxOpen('tasks')) {
          await Hive.initFlutter();
          if (!Hive.isAdapterRegistered(0)) {
            Hive.registerAdapter(TaskAdapter()); // your Task typeId
          }
          await Hive.openBox<Task>('tasks');
        }

        final box = Hive.box<Task>('tasks');
        final task = box.get(tappedTaskId);
        final tasks = box.values.toList();
        TaskWidgetHelper.updateTasksWidget(tasks);

        if (response.actionId == 'action_1') {
          debugPrint('Later pressed');
          cancelNotification();
        } else if (response.actionId == 'action_2') {
          debugPrint('Go pressed');
          if (task != null) {
            final date = DateFormat('d EEE MMM yyyy').format(DateTime.now());
            task.taskCompletionDates.add(date);
            await box.put(idFromPayload, task);

            await notificationPlugin.show(
              8888,
              'Task Started',
              '${task.title} marked as completed!',
              _simpleNotificationDetails(),
            );
          }
          cancelById(tappedTaskId);
        } else {
          debugPrint('Notification tapped');
        }

        // ✅ Navigate to AlarmScreen WITHOUT context
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => AlarmScreen(
              taskId: idFromPayload,
              message: message,
            ),
          ),
        );

        cancelNotification();
      },
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'loud_alarm_channel', // keep your existing id if you want; change only if you need a new channel
        'Loud Alarms',
        channelDescription: 'Channel for loud fullscreen alarms',
        importance: Importance.max,
        priority: Priority.max,
        playSound: false, // you play your own tone
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
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
    );
  }

  NotificationDetails _simpleNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'simple_channel',
        'Simple',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }

  Future<void> showNotification(Task task, String message, DateTime toFireAt) async {
    final int currentSecond = DateTime.now().second;
    if (DateTime.now().isBefore(toFireAt)) {
      await Future.delayed(Duration(seconds: 60 - currentSecond));
    }
    taskId = task.id;
    final int id = int.parse(task.id) % 2147483647;

    await notificationPlugin.show(
      id,
      task.title,
      "$message${task.title}",
      _notificationDetails(),
      payload: "${task.id}|$message",
    );

    ringtoneHandler();
    _startListening();
  }

  void _startListening() {
    if (!_listening) {
      VolumeController().listener((volume) {
        EffectService().stopEffect();
      });
      _listening = true;
    }
  }

  Future<void> ringtoneHandler() async {
    if (Hive.isBoxOpen('settings')) {
      await Hive.box<AppSettings>('settings').close();
    }
    final settingsBox = await Hive.openBox<AppSettings>('settings');
    final userSettings = settingsBox.get('userSettings');
    final tonePath = userSettings?.loudAlertTone;
    EffectService().startVibration();
    if (tonePath != null && tonePath.isNotEmpty) {
      await EffectService().play(tonePath);
    } else {
      await EffectService().playAsset('audio/loud.mp3');
    }
  }

  Future<void> cancelById(taskId) async {
    final int id = int.parse(taskId) % 2147483647;
    await notificationPlugin.cancel(id);
    EffectService().stopEffect();
  }

  Future<void> cancelNotification() async {
    await notificationPlugin.cancelAll();
    EffectService().stopEffect();
  }
}
