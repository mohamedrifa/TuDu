import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskWidgetHelper {
  static Future<void> updateTasksWidget(List<Task> tasks) async {
    final today = DateFormat('d MM yyyy').format(DateTime.now());

    final todayTasks = tasks.where((t) => t.date == today).toList();

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
