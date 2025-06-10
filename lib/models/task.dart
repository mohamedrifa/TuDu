// models/task.dart
import 'package:hive/hive.dart';

part 'task.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String title;
  
  @HiveField(1)
  final String time;
  
  @HiveField(2)
  final List<String> tags;

  Task({
    required this.title,
    required this.time,
    required this.tags,
  });
}