import 'dart:convert';

class Task {
  final String id;
  final String title;
  final String date;                 // "repeat" or "d MM yyyy"
  final List<bool> weekDays;         // length 7
  final String fromTime;             // "HH:mm"
  final String toTime;               // "HH:mm"
  final String tags;
  final bool important;
  final String location;
  final String subTask;

  final bool beforeLoudAlert;
  final bool beforeMediumAlert;
  final bool afterLoudAlert;
  final bool afterMediumAlert;

  final String selectedBefore;       // alertBefore
  final String selectedAfter;        // alertAfter

  final List<String> taskCompletionDates; // store as JSON string
  final String taskScheduleddate;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.weekDays,
    required this.fromTime,
    required this.toTime,
    required this.tags,
    required this.important,
    required this.location,
    required this.subTask,
    required this.beforeLoudAlert,
    required this.beforeMediumAlert,
    required this.afterLoudAlert,
    required this.afterMediumAlert,
    required this.selectedBefore,
    required this.selectedAfter,
    required this.taskCompletionDates,
    required this.taskScheduleddate,
  });

  // Encode weekDays to "1010010"
  static String _weekDaysToString(List<bool> days) =>
      days.map((b) => b ? '1' : '0').join();

  static List<bool> _stringToWeekDays(String s) {
    final padded = s.padRight(7, '0').substring(0, 7);
    return padded.split('').map((c) => c == '1').toList(growable: false);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'week_days': _weekDaysToString(weekDays),
      'from_time': fromTime,
      'to_time': toTime,
      'tags': tags,
      'important': important ? 1 : 0,
      'location': location,
      'sub_task': subTask,
      'before_loud_alert': beforeLoudAlert ? 1 : 0,
      'before_medium_alert': beforeMediumAlert ? 1 : 0,
      'after_loud_alert': afterLoudAlert ? 1 : 0,
      'after_medium_alert': afterMediumAlert ? 1 : 0,
      'alert_before': selectedBefore,
      'alert_after': selectedAfter,
      'task_completion_dates': jsonEncode(taskCompletionDates),
      'task_scheduled_date': taskScheduleddate,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: (map['title'] ?? '') as String,
      date: (map['date'] ?? '') as String,
      weekDays: _stringToWeekDays((map['week_days'] ?? '0000000') as String),
      fromTime: (map['from_time'] ?? '') as String,
      toTime: (map['to_time'] ?? '') as String,
      tags: (map['tags'] ?? '') as String,
      important: (map['important'] ?? 0) == 1,
      location: (map['location'] ?? '') as String,
      subTask: (map['sub_task'] ?? '') as String,
      beforeLoudAlert: (map['before_loud_alert'] ?? 0) == 1,
      beforeMediumAlert: (map['before_medium_alert'] ?? 0) == 1,
      afterLoudAlert: (map['after_loud_alert'] ?? 0) == 1,
      afterMediumAlert: (map['after_medium_alert'] ?? 0) == 1,
      selectedBefore: (map['alert_before'] ?? '') as String,
      selectedAfter: (map['alert_after'] ?? '') as String,
      taskCompletionDates: List<String>.from(
        (jsonDecode(map['task_completion_dates'] ?? '[]') as List).map((e) => e.toString()),
      ),
      taskScheduleddate: (map['task_scheduled_date'] ?? '') as String,
    );
  }
}
