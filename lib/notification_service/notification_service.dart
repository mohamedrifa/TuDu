import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import 'package:hive/hive.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    // Request permissions only on iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );


    tz.initializeTimeZones();

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );
  }

  Future<void> scheduleTaskNotification(Task task) async {
    final timeParts = task.fromTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Task Channel',
        importance: Importance.max,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction('go', 'Go'),
          AndroidNotificationAction('later', 'Later'),
        ],
      ),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      task.hashCode,
      task.title,
      'It\'s time for: ${task.title}',
      tzScheduled,
      details,
      payload: task.id,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> onNotificationResponse(NotificationResponse response) async {
    final taskId = response.payload;
    if (taskId == null) return;

    final box = await Hive.openBox<Task>('tasks');
    final task = box.values.firstWhere((t) => t.id == taskId, orElse: () => Task(
      id: '',
      title: '',
      date: '',
      weekDays: [],
      fromTime: '',
      toTime: '',
      tags: '',
      important: false,
      location: '',
      subTask: '',
      beforeLoudAlert: false,
      beforeMediumAlert: false,
      afterLoudAlert: false,
      afterMediumAlert: false,
      alertBefore: '',
      alertAfter: '',
      taskCompletionDates: [],
      taskScheduleddate: '',
    ));

    // if (response.actionId == 'go') {
    //   final now = DateFormat('d EEE MM yyyy').format(DateTime.now());
    //   task.taskCompletionDates.add(now);
    //   await task.save();
    // } else if (response.actionId == 'later') {
    //   final later = DateTime.now().add(Duration(minutes: 10));
    //   task.fromTime = '${later.hour.toString().padLeft(2, '0')}:${later.minute.toString().padLeft(2, '0')}';
    //   await task.save();
    //   await scheduleTaskNotification(task);
    // }
  }
}
