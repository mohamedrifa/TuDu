import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/settings.dart';
import '../models/task.dart';
import '../screens/onboarding_screen.dart';
import 'package:audioplayers/audioplayers.dart';

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
    print("✅ alarmCallback() triggered");
    await Hive.initFlutter();
    settingsUpdater();
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
      Hive.registerAdapter(SettingsAdapter());
    }

    if (Hive.isBoxOpen('tasks')) {
      await Hive.box<Task>('tasks').close();
    }
    final taskBox = await Hive.openBox<Task>('tasks'); // now it's refreshed
    if (Hive.isBoxOpen('settings')) {
      await Hive.box<AppSettings>('settings').close();
    }
    final settingsBox = await Hive.openBox<AppSettings>('settings');
    final AppSettings? userSettings = await settingsBox.get('userSettings');
    final tasks = taskBox.values.toList();
    
    final  filteredTasks = await tasks
        .where((task) => filteredList(
              task.date,
              task.weekDays,
              task.important,
              task.taskScheduleddate,
            ))
        .toList();
    print("outside forloop "+ filteredTasks.length.toString());
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
      DateTime reducedTime = todayTime.subtract(Duration(minutes: 1));
      // Subtract alert time
      DateTime beforeTime;
      switch (filteredTasks[i].alertBefore) {
        case "5 Mins":
          beforeTime = reducedTime.subtract(Duration(minutes: 5));
          Message = "5 Minutes to Start ";
          break;
        case "10 Mins":
          beforeTime = reducedTime.subtract(Duration(minutes: 10));
          Message = "10 Minutes to Start ";
          break;
        case "15 Mins":
          beforeTime = reducedTime.subtract(Duration(minutes: 15));
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
        if(!filteredTasks[i].taskCompletionDates.contains(nowDate)) {
          if(filteredTasks[i].beforeMediumAlert) {
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
          if(filteredTasks[i].beforeLoudAlert) {
            print("before loud alert");
            // for full screen
          }
        }
      }
      DateTime afterTime;
      switch (filteredTasks[i].alertAfter) {
        case "On Time":
          afterTime = reducedTime;
          Message = "Its Time to Start ";
          break;
        case "5 Mins":
          afterTime = reducedTime.add(Duration(minutes: 5));
          Message = "5 Mins Passed for ";
          break;
        case "10 Mins":
          afterTime = reducedTime.add(Duration(minutes: 10));
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
        if(!filteredTasks[i].taskCompletionDates.contains(nowDate)) {
          if(filteredTasks[i].afterMediumAlert) {
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
          if(filteredTasks[i].afterLoudAlert) {
            print("after loud alert");
            // for full screen
          }
        }
      }
    }
  }
  Future<void> stopPeriodicAlarm() async {
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
        String? idFromPayload = response.payload;
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

        if (response.actionId == 'action_1') {
          print('✅ Later button pressed');
          // Optional: Add snooze/reschedule logic
        } else if (response.actionId == 'action_2') {
          print('✅ Go button pressed');
          if (task != null) {
            String date = DateFormat('d EEE MMM yyyy').format(DateTime.now());
            task.taskCompletionDates.add(date);
            await box.put(idFromPayload, task);
            print("✅ Task updated in Hive");

            // ✅ Show follow-up notification without action buttons
            await notificationPlugin.show(
              9999,
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
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'action_2',
            'Go',
            showsUserInterface: true,
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
    DateTime now = DateTime.now();
    int currentSecond = now.second;
    await Future.delayed(Duration(seconds: 60 - currentSecond));

    taskId = tasks.id;
    int id = int.parse(tasks.id) % 2147483647;

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