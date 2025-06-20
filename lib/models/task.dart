// models/task.dart
import 'package:hive/hive.dart';

part 'task.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String id;

   @HiveField(1)
  String title;

  @HiveField(2)
  String date;

  @HiveField(3)
  List<bool> weekDays;

  @HiveField(4)
  String fromTime;

  @HiveField(5)
  String toTime;

  @HiveField(6)
  String tags;

  @HiveField(7)
  bool important;

  @HiveField(8)
  String location;

  @HiveField(9)
  String subTask;

  @HiveField(10)
  bool beforeLoudAlert;

  @HiveField(11)
  bool beforeMediumAlert;

  @HiveField(12)
  bool afterLoudAlert;

  @HiveField(13)
  bool afterMediumAlert;

  @HiveField(14)
  String alertBefore;

  @HiveField(15)
  String alertAfter;

  @HiveField(16)
  List taskCompletionDates;

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
  required this.alertBefore,
  required this.alertAfter,
  required this.taskCompletionDates
});

  get tagname => null;

}