import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/task_adding_screen.dart';

// SQLite-backed model & repo
import '../data/task_model.dart';
import '../data/task_repository.dart';

class TaskCard extends StatefulWidget {
  final int index;
  final String id;
  final String date; // display date string used for completion tracking
  final Future<void> Function()? onChanged; // ← notify parent to refresh

  const TaskCard({
    super.key,
    required this.index,
    required this.id,
    required this.date,
    this.onChanged,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late final TaskRepository _repo;
  Task? _task;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = SqliteTaskRepository();
    _loadTask();
  }

  // IMPORTANT: reload if ListView reuses this element for a different task id
  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _loading = true;
      _task = null;
      _loadTask();
    }
  }

  Future<void> _loadTask() async {
    final t = await _repo.getById(widget.id);
    if (!mounted) return;
    setState(() {
      _task = t;
      _loading = false;
    });
  }

  Future<void> _notifyParent() async {
    if (widget.onChanged != null) {
      await widget.onChanged!();
    }
  }

  void _navigateToAddTaskScreen(BuildContext context, String addTaskId) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TaskAddingScreen(taskId: addTaskId, isEdit: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = const Offset(0.0, 1.0);
          final end = Offset.zero;
          final curve = Curves.easeInOut;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
    await _loadTask();
    await _notifyParent();
  }

  String timing(String fromTime, String toTime) {
    final parts1 = fromTime.split(":");
    final fromHour = int.parse(parts1[0]);
    final fromMinute = int.parse(parts1[1]);
    final time1 = DateTime(0, 1, 1, fromHour, fromMinute);
    var formattedTime1 = DateFormat('hh.mm a').format(time1).replaceAll("AM", "A.M").replaceAll("PM", "P.M");

    final parts2 = toTime.split(":");
    final toHour = int.parse(parts2[0]);
    final toMinute = int.parse(parts2[1]);
    final time2 = DateTime(0, 1, 1, toHour, toMinute);
    var formattedTime2 = DateFormat('hh.mm a').format(time2).replaceAll("AM", "A.M").replaceAll("PM", "P.M");

    return "$formattedTime1 To $formattedTime2";
  }

  // Helpers to read either selectedBefore/selectedAfter or alertBefore/alertAfter
  String _selBefore(Task t) {
    try { return (t as dynamic).selectedBefore ?? (t as dynamic).alertBefore ?? ""; } catch (_) { return ""; }
  }
  String _selAfter(Task t) {
    try { return (t as dynamic).selectedAfter ?? (t as dynamic).alertAfter ?? ""; } catch (_) { return ""; }
  }

  Future<void> handleLoudAlert(bool alert) async {
    final t = _task;
    if (t == null) return;

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
      beforeLoudAlert: !alert,
      beforeMediumAlert: !alert ? false : t.beforeMediumAlert,
      afterLoudAlert: !alert,
      afterMediumAlert: !alert ? false : t.afterMediumAlert,
      selectedBefore: _selBefore(t),
      selectedAfter: _selAfter(t),
      taskCompletionDates: t.taskCompletionDates,
      taskScheduleddate: t.taskScheduleddate,
    );

    await _repo.upsert(updated);
    if (!mounted) return;
    setState(() => _task = updated);
    await _notifyParent();
  }

  Future<void> handleMediumAlert(bool alert) async {
    final t = _task;
    if (t == null) return;

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
      beforeLoudAlert: !alert ? false : t.beforeLoudAlert,
      beforeMediumAlert: !alert,
      afterLoudAlert: !alert ? false : t.afterLoudAlert,
      afterMediumAlert: !alert,
      selectedBefore: _selBefore(t),
      selectedAfter: _selAfter(t),
      taskCompletionDates: t.taskCompletionDates,
      taskScheduleddate: t.taskScheduleddate,
    );

    await _repo.upsert(updated);
    if (!mounted) return;
    setState(() => _task = updated);
    await _notifyParent();
  }

  Future<void> handleCheckMark() async {
    final t = _task;
    if (t == null) return;

    final dates = List<String>.from(t.taskCompletionDates);
    if (!dates.contains(widget.date)) {
      dates.add(widget.date);
    }

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
      selectedBefore: _selBefore(t),
      selectedAfter: _selAfter(t),
      taskCompletionDates: dates,
      taskScheduleddate: t.taskScheduleddate,
    );

    await _repo.upsert(updated);
    if (!mounted) return;
    setState(() => _task = updated);
    await _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    final task = _task;
    if (task == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: task.important ? const Color(0xFFFED289) : const Color(0xFF5AD3D1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: InkWell(
              onTap: () => _navigateToAddTaskScreen(context, task.id),
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Row(
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    color: Color(0xFF0D0C10),
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  task.subTask,
                                  style: const TextStyle(
                                    color: Color(0xFF0D0C10),
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.location,
                            style: const TextStyle(
                              color: Color(0xFF0D0C10),
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timing(task.fromTime, task.toTime),
                            style: const TextStyle(
                              color: Color(0xFF313036),
                              fontFamily: 'Quantico',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (task.tags.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        color: Color(0xFF0C2C2C),
                                      ),
                                      child: Text(
                                        task.tags,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFFEBFAF9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  if (task.important)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        color: Color(0xFF268D8C),
                                      ),
                                      child: const Text(
                                        "Important",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFFEBFAF9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: 86,
                                    height: 35,
                                    child: Row(
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              final isOn = task.beforeLoudAlert || task.afterLoudAlert;
                                              handleLoudAlert(isOn);
                                            },
                                            borderRadius: BorderRadius.circular(5),
                                            child: Image(
                                              image: (task.beforeLoudAlert || task.afterLoudAlert)
                                                  ? const AssetImage("assets/loudAlertOn1.png")
                                                  : const AssetImage("assets/loudAlertOff1.png"),
                                              width: 35,
                                              height: 35,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              final isOn = task.beforeMediumAlert || task.afterMediumAlert;
                                              handleMediumAlert(isOn);
                                            },
                                            borderRadius: BorderRadius.circular(5),
                                            child: Image(
                                              image: (task.beforeMediumAlert || task.afterMediumAlert)
                                                  ? const AssetImage("assets/mediumAlertOn1.png")
                                                  : const AssetImage("assets/mediumAlertOff1.png"),
                                              width: 35,
                                              height: 35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: InkWell(
                        onTap: () => handleCheckMark(),
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          task.taskCompletionDates.contains(widget.date)
                              ? "assets/taskDone.png"
                              : "assets/taskPending.png",
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (task.taskCompletionDates.isNotEmpty && task.date == "repeat")
          Positioned(
            right: 16,
            top: 11,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5.67),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF1B1A1E),
              ),
              child: Text(
                task.taskCompletionDates.length.toString(),
                style: const TextStyle(
                  color: Color(0xFFEBFAF9),
                  fontFamily: 'Quantico',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
