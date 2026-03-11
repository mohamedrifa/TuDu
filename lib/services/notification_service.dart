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
  Future<void> scheduleOneShotForTodayAndMidnightRollover() async {
    await cancelAllKnownTaskAlarms();

    await _scheduleTodayTaskAlarms();
    await _scheduleMidnightRollover();
  }

  /// Builds and schedules today's alarms (before/after) as exact one-shots.
  Future<void> _scheduleTodayTaskAlarms() async {
    WidgetsFlutterBinding.ensureInitialized();
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
    final taskBox = await Hive.openBox<Task>('tasks');

    if (Hive.isBoxOpen('settings')) {
      await Hive.box<AppSettings>('settings').close();
    }
    final settingsBox = await Hive.openBox<AppSettings>('settings');
    // ignore: unused_local_variable
    final AppSettings? userSettings = settingsBox.get('userSettings');

    final tasks = taskBox.values.toList();
    final now = DateTime.now();

    final filteredTasks = tasks
        .where((task) => filteredList(
              task.date,
              task.weekDays,
              task.important,
              task.taskScheduleddate,
            ))
        .toList();

    final timeFormat = DateFormat("HH:mm");

    for (final task in filteredTasks) {
      // Parse "fromTime" into today's DateTime
      DateTime parsed;
      try {
        final t = timeFormat.parse(task.fromTime);
        parsed = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      } catch (_) {
        continue; // skip malformed time safely
      }

      // -------- BEFORE --------
      {
        final _BeforeCalc calc = _computeBefore(parsed, task.alertBefore);
        if (calc.fireAt.isAfter(now)) {
          final int alarmId = _alarmId(task.id, kind: _AlarmKind.before);
          final params = {
            'taskId': task.id,
            'kind': 'before',
            'message': calc.message, // e.g. "5 Minutes to Start "
          };
          await AndroidAlarmManager.oneShotAt(
            calc.fireAt,
            alarmId,
            taskAlarmCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
            params: params,
          );
        }
      }

      // -------- AFTER --------
      {
        final _AfterCalc calc = _computeAfter(parsed, task.alertAfter);
        if (calc.fireAt.isAfter(now)) {
          final int alarmId = _alarmId(task.id, kind: _AlarmKind.after);
          final params = {
            'taskId': task.id,
            'kind': 'after',
            'message': calc.message, // e.g. "Its Time to Start "
          };
          await AndroidAlarmManager.oneShotAt(
            calc.fireAt,
            alarmId,
            taskAlarmCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
            params: params,
          );
        }
      }
    }
  }

  /// Schedules a self-rescheduling one-shot at next midnight (local time).
  Future<void> _scheduleMidnightRollover() async {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

    const int rolloverId = 900000001; // stable ID for midnight job
    await AndroidAlarmManager.oneShotAt(
      nextMidnight,
      rolloverId,
      midnightRolloverCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  Future<void> cancelAllKnownTaskAlarms() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
        Hive.registerAdapter(TaskAdapter());
      }
      if (!Hive.isBoxOpen('tasks')) {
        await Hive.openBox<Task>('tasks');
      }

      final taskBox = Hive.box<Task>('tasks');
      final tasks = taskBox.values.toList();

      // Cancel per-task BEFORE/AFTER alarms
      for (final task in tasks) {
        final int beforeId = _alarmId(task.id, kind: _AlarmKind.before);
        final int afterId  = _alarmId(task.id, kind: _AlarmKind.after);

        await AndroidAlarmManager.cancel(beforeId);
        await AndroidAlarmManager.cancel(afterId);
      }

      const int rolloverId = 900000001;
      await AndroidAlarmManager.cancel(rolloverId);

      debugPrint('🧹 Canceled ${tasks.length * 2 + 1} alarms (before/after per task + midnight rollover)');
    } catch (e, st) {
      debugPrint('❌ cancelAllKnownTaskAlarms error: $e\n$st');
    }
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
      try {
        final taskDate = DateFormat("d MM yyyy").parse(date);
        final todayStr = DateFormat("d MM yyyy").format(now);
        return DateFormat("d MM yyyy").format(taskDate) == todayStr;
      } catch (e) {
        debugPrint("❌ Error parsing task date: $e");
        return false;
      }
    } else {
      final int dayOfWeekIndex = now.weekday - 1; // 0..6
      return weekDays[dayOfWeekIndex];
    }
  }

  int _alarmId(String taskId, {required _AlarmKind kind}) {
    final base = int.tryParse(taskId) ?? taskId.hashCode;
    return (base.abs() % 100000000) + (kind == _AlarmKind.before ? 1000000000 : 2000000000);
  }

  _BeforeCalc _computeBefore(DateTime reduced, String alertBefore) {
    // Matches your legacy offsets & messages, and sets "toFireAt" like before.
    switch (alertBefore) {
      case "5 Mins":
        final before = reduced.subtract(const Duration(minutes: 5));
        return _BeforeCalc(fireAt: before, message: "5 Minutes to Start ");
      case "10 Mins":
        final before = reduced.subtract(const Duration(minutes: 10));
        return _BeforeCalc(fireAt: before, message: "10 Minutes to Start ");
      case "15 Mins":
        final before = reduced.subtract(const Duration(minutes: 15));
        return _BeforeCalc(fireAt: before, message: "15 Minutes to Start ");
      default:
        // "None" -> trigger one minute after reduced (the old default path)
        final before = reduced;
        return _BeforeCalc(fireAt: before, message: "");
    }
  }

  _AfterCalc _computeAfter(DateTime reduced, String alertAfter) {
    switch (alertAfter) {
      case "On Time":
        final after = reduced;
        return _AfterCalc(fireAt: after, message: "Its Time to Start ");
      case "5 Mins":
        final after = reduced.add(const Duration(minutes: 5));
        return _AfterCalc(fireAt: after, message: "5 Mins Passed for ");
      case "10 Mins":
        final after = reduced.add(const Duration(minutes: 10));
        return _AfterCalc(fireAt: after, message: "10 Mins Passed for ");
      default:
        final after = reduced;
        return _AfterCalc(fireAt: after, message: "");
    }
  }
}

// Simple structs
enum _AlarmKind { before, after }

class _BeforeCalc {
  final DateTime fireAt;
  final String message;
  _BeforeCalc({required this.fireAt, required this.message});
}

class _AfterCalc {
  final DateTime fireAt;
  final String message;
  _AfterCalc({required this.fireAt, required this.message});
}

@pragma('vm:entry-point')
void taskAlarmCallback(int id, Map<String, dynamic> params) {
  DartPluginRegistrant.ensureInitialized();
  _TaskAlarmExecutor().run(params);
}
@pragma('vm:entry-point')
void midnightRolloverCallback(int id) {
  DartPluginRegistrant.ensureInitialized();
  _MidnightExecutor().run();
}

class _TaskAlarmExecutor {
  Future<void> run(Map<String, dynamic> params) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
        Hive.registerAdapter(TaskAdapter());
      }
      if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
        Hive.registerAdapter(SettingsAdapter());
      }

      if (!Hive.isBoxOpen('tasks')) {
        await Hive.openBox<Task>('tasks');
      }
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox<AppSettings>('settings');
      }

      final box = Hive.box<Task>('tasks');
      final settingsBox = Hive.box<AppSettings>('settings');
      final AppSettings settings = settingsBox.get('userSettings') ??
          AppSettings(mediumAlertTone: '', loudAlertTone: '', batteryUnrestricted: true);

      final String taskId = params['taskId'] as String;
      final String kind = params['kind'] as String; // "before" or "after"
      final String message = (params['message'] as String?) ?? "";

      final task = box.get(taskId);
      if (task == null) {
        debugPrint("⚠️ Task not found for ID: $taskId");
        return;
      }

      // Skip if already completed today (same safeguard as your loop)
      final nowDate = DateFormat('d EEE MMM yyyy').format(DateTime.now());
      if (task.taskCompletionDates.contains(nowDate)) {
        return;
      }

      if (kind == 'before') {
        // Respect per-task toggles
        if (task.beforeMediumAlert) {
          await MediumNotification().showNotification(settings, task, message, true);
        }
        if (task.beforeLoudAlert) {
          await FullScreenNotification().showNotification(task, message, true);
        }
      } else {
        if (task.afterMediumAlert) {
          await MediumNotification().showNotification(settings, task, message, false);
        }
        if (task.afterLoudAlert) {
          await FullScreenNotification().showNotification(task, message, false);
        }
      }
    } catch (e, st) {
      debugPrint("❌ taskAlarmCallback error: $e\n$st");
    }
  }
}

class _MidnightExecutor {
  Future<void> run() async {
    try {
      await NotificationService()._scheduleTodayTaskAlarms();
      await NotificationService()._scheduleMidnightRollover();
      if (!Hive.isBoxOpen('tasks')) {
        await Hive.initFlutter();
        if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
          Hive.registerAdapter(TaskAdapter());
        }
        await Hive.openBox<Task>('tasks');
      }
      TaskWidgetHelper.updateTasksWidget();
    } catch (e, st) {
      debugPrint("❌ midnightRolloverCallback error: $e\n$st");
    }
  }
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
        TaskWidgetHelper.updateTasksWidget();

        if (response.actionId == 'action_1') {
          print('✅ Later button pressed');
        } else if (response.actionId == 'action_2') {
          print('✅ Go button pressed');
          if (task != null) {
            final date = DateFormat('d EEE MMM yyyy').format(DateTime.now());
            if(!task.taskCompletionDates.contains(date)) {
              task.taskCompletionDates.add(date);
            }
            await box.put(idFromPayload, task);
            print("✅ Task updated in Hive");
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

  Future<void> showNotification(AppSettings settings, Task tasks, String message, bool isBefore) async {
    taskId = tasks.id;
    int id;
    if(isBefore) {
      id = int.parse(tasks.id) % 2147483647;
    } else {
      id = (int.parse(tasks.id) % 2147483647) + 500000;
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

class FullScreenNotification {
  FullScreenNotification._privateConstructor();
  static final FullScreenNotification _instance = FullScreenNotification._privateConstructor();
  factory FullScreenNotification() => _instance;

  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
  String taskId = "";
  bool _listening = false;
  Future<void> initNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await EffectService().stopEffect();

        final String? idFromPayload = response.payload;
        if (idFromPayload == null) return;

        final parts = idFromPayload.split('|');
        final String tappedTaskId = parts[0];
        final String message = parts.length > 1 ? parts[1] : "";
        if (!Hive.isBoxOpen('tasks')) {
          await Hive.initFlutter();
          if (!Hive.isAdapterRegistered(0)) {
            Hive.registerAdapter(TaskAdapter()); // your Task typeId
          }
          await Hive.openBox<Task>('tasks');
        }
        final box = Hive.box<Task>('tasks');
        final task = box.get(tappedTaskId);
        TaskWidgetHelper.updateTasksWidget();
        if (response.actionId == 'action_1') {
          debugPrint('Later pressed');
          cancelNotification();
          return;
        } else if (response.actionId == 'action_2') {
          debugPrint('Go pressed');
          if (task != null) {
            final date = DateFormat('d EEE MMM yyyy').format(DateTime.now());
            if(!task.taskCompletionDates.contains(date)) {
              task.taskCompletionDates.add(date);
            }
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
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => AlarmScreen(
                taskId: idFromPayload,
                message: message,
              ),
            ),
          );
        }
        cancelNotification();
      },
    );
    final androidPlugin = notificationPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        'loud_alarm_channel',
        'Loud Alarms',
        description: 'Channel for loud fullscreen alarms',
        importance: Importance.max,
        playSound: false,     
        enableVibration: true,
        showBadge: false,
      );
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      await androidPlugin.requestFullScreenIntentPermission();
    }
  }

  /// Full-screen, high-importance details for the alarm-style notification.
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'loud_alarm_channel',
        'Loud Alarms',
        channelDescription: 'Channel for loud fullscreen alarms',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,     // <- required for full-screen
        ongoing: true,
        autoCancel: false,
        visibility: NotificationVisibility.public,
        playSound: false,           // sound handled by EffectService
        enableVibration: true,
        enableLights: true,
        ticker: 'Alarm',
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
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: false, // avoid double audio (EffectService handles sound)
        presentBadge: false,
      ),
    );
  }

  /// Lightweight toast-style details for the "Task Started" follow-up.
  NotificationDetails _simpleNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'simple_channel',
        'Simple',
        channelDescription: 'General lightweight notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification(Task task, String message, bool isBefore) async {
    taskId = task.id;
    int id;
    if(isBefore) {
      id = int.parse(task.id) % 2147483647;
    } else {
      id = (int.parse(task.id) % 2147483647) + 500000;
    }

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
