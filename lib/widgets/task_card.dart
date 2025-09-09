import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import '../screens/task_adding_screen.dart';

class TaskCard extends StatelessWidget {
  final int index;
  final String id;
  final String date;

  const TaskCard({
    super.key,
    required this.index,
    required this.id,
    required this.date
  });

  void toast (String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
      gravity: ToastGravity.CENTER, // or TOP, CENTER
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _navigateToAddTaskScreen(BuildContext context, String addTaskId) {
    Navigator.push(
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
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  String timing(String fromTime, String toTime) {
    List<String> parts1 = fromTime.split(":");
    int fromHour = int.parse(parts1[0]);
    int fromMinute = int.parse(parts1[1]);
    DateTime time1 = DateTime(0, 1, 1, fromHour, fromMinute);
    String formattedTime1 = DateFormat('hh.mm a').format(time1);
    formattedTime1 = formattedTime1.replaceAll("AM", "A.M").replaceAll("PM", "P.M");

    List<String> parts2 = toTime.split(":");
    int toHour = int.parse(parts2[0]);
    int toMinute = int.parse(parts2[1]);
    DateTime time2 = DateTime(0, 1, 1, toHour, toMinute);
    String formattedTime2 = DateFormat('hh.mm a').format(time2);
    formattedTime2 = formattedTime2.replaceAll("AM", "A.M").replaceAll("PM", "P.M");

    return "$formattedTime1 To $formattedTime2";
  }

  void handleLoudAlert(bool alert) {
    final box = Hive.box<Task>('tasks');
    final task = box.get(id);
    if (task != null) {
      task.beforeLoudAlert = !alert;
      task.afterLoudAlert = !alert;
      if(!alert) {
        task.beforeMediumAlert = alert;
        task.afterMediumAlert = alert;
      }
      box.put(id, task);
    }
  }

  void handleMediumAlert(bool alert) {
    final box = Hive.box<Task>('tasks');
    final task = box.get(id);
    if (task != null) {
      task.beforeMediumAlert = !alert;
      task.afterMediumAlert = !alert;
      if(!alert) {
        task.beforeLoudAlert = alert;
        task.afterLoudAlert = alert;
      }
      box.put(id, task);
    }
  }
  bool isTimePassed(String fromTime) {
    final now = DateTime.now();
    final parts = fromTime.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final taskTime = DateTime(now.year, now.month, now.day, hour, minute);
    return now.isAfter(taskTime);
  }


  void handleCheckMark() {
    final box = Hive.box<Task>('tasks');
    final task = box.get(id);
    if (task != null) {
      if(isTimePassed(task.fromTime)) {
        if (!task.taskCompletionDates.contains(date)) {
          task.taskCompletionDates.add(date);
        }
        box.put(id, task);
      } else {
        toast("This task is scheduled for a future time. You cannot complete it now.");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>('tasks');
    print(date);
    final task = box.get(id);
    if (task == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: task.important ? const Color(0xFFFED289) : const Color(0xFF5AD3D1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: InkWell(
              onTap: () {
                _navigateToAddTaskScreen(context, task.id);
              },
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      color: Color(0xFF0D0C10),
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    task.subTask,
                                    style: TextStyle(
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
                              style: TextStyle(
                                color: Color(0xFF0D0C10),
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timing(task.fromTime, task.toTime),
                              style: TextStyle(
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
                                    if (task.tags != "")
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        margin: const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                          color: Color(0xFF0C2C2C),
                                        ),
                                        child: Text(
                                          task.tags,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Color(0xFFEBFAF9),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    if (task.important)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        margin: const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                          color: Color(0xFF268D8C),
                                        ),
                                        child: Text(
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
                                                handleLoudAlert(task.beforeLoudAlert || task.afterLoudAlert);
                                              },
                                              borderRadius: BorderRadius.circular(5),
                                              child: Image(
                                                image: task.beforeLoudAlert || task.afterLoudAlert
                                                    ? AssetImage("assets/loudAlertOn1.png")
                                                    : AssetImage("assets/loudAlertOff1.png"),
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
                                                handleMediumAlert(task.beforeMediumAlert || task.afterMediumAlert);
                                              },
                                              borderRadius: BorderRadius.circular(5),
                                              child: Image(
                                                image: task.beforeMediumAlert || task.afterMediumAlert
                                                    ? AssetImage("assets/mediumAlertOn1.png")
                                                    : AssetImage("assets/mediumAlertOff1.png"),
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
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: InkWell(
                        onTap: () {
                          handleCheckMark();
                        },
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          task.taskCompletionDates.contains(date) ? "assets/taskDone.png" : "assets/taskPending.png",
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
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5.67),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFF1B1A1E),
              ),
              child: Text(
                task.taskCompletionDates.length.toString(),
                style: TextStyle(
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
