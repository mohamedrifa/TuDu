import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskWidgetHelper {

  static bool allDaysFalse(List weekDays) {
    for (final day in weekDays) {
      if (day) return false;
    }
    return true;
  }
  static bool filteredList(
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
  static Future<void> updateTasksWidget() async {
    final box = Hive.box<Task>('tasks');
    if (!Hive.isBoxOpen('tasks')) {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter()); // 👈 use your Task typeId
      }
      await Hive.openBox<Task>('tasks');
    }
    final tasks = box.values.toList();
    final todayTasks = tasks
                          .where((task) =>
                              filteredList(task.date, task.weekDays, task.important, task.taskScheduleddate))
                          .toList();
    todayTasks.sort((a, b) {
      final aParts = a.fromTime.split(':').map(int.parse).toList();
      final bParts = b.fromTime.split(':').map(int.parse).toList();

      final aMinutes = aParts[0] * 60 + aParts[1];
      final bMinutes = bParts[0] * 60 + bParts[1];

      return aMinutes.compareTo(bMinutes);
    });

    if (todayTasks.isEmpty) {
      await HomeWidget.saveWidgetData<String>(
        'today_tasks',
        'No tasks for today 🎉',
      );
    } else {
      final taskString = todayTasks.map((t) {
        final timeRange =
            "${_formatTime(t.fromTime)} → ${_formatTime(t.toTime)}";

        // ✅ check if today’s date is inside completion list
        String completedDate = DateFormat('d EEE MMM yyyy').format(DateTime.now());
        final status = t.taskCompletionDates.contains(completedDate) ? "✅" : "⬜";

        return "$status ${t.title}${t.subTask.isNotEmpty ? ' – ${t.subTask}' : ''}"
                "\n      ${t.location} • $timeRange";
      }).join("\n\n");

      await HomeWidget.saveWidgetData<String>('today_tasks', taskString);
    }

    await HomeWidget.updateWidget(
      name: 'TaskWidget',
      iOSName: 'TaskWidget',
    );
  }

  static String _formatTime(String time) {
    final parts = time.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final dt = DateTime(0, 1, 1, hour, minute);
    return DateFormat('hh:mm a').format(dt);
  }
}
