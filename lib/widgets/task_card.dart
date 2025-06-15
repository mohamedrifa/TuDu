import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import '../screens/task_adding_screen.dart';

class TaskCard extends StatelessWidget {
  final int index;
  final String id;

  const TaskCard({
    super.key,
    required this.index,
    required this.id,
  });
  void _navigateToAddTaskScreen(BuildContext context, String addTaskId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600), // 1.5 seconds
        pageBuilder: (context, animation, secondaryAnimation) => TaskAddingScreen(taskId: addTaskId, isEdit: true),
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
    
    return formattedTime1 + " To " + formattedTime2;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>('tasks');
    final task = box.get(id);
    if (task == null) {
      return const SizedBox.shrink();
    }

    return Padding(
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
                              )
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
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                    margin: const EdgeInsets.only(left: 16),
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
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 86,
                                  height: 35,
                                  child: Row(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        child: InkWell(
                                          onTap: () {
                                            // handle tap
                                          },
                                          borderRadius: BorderRadius.circular(5),
                                          child: Image(
                                            image: task.beforeLoudAlert || task.afterLoudAlert? AssetImage("assets/loudAlertOn1.png") : AssetImage("assets/loudAlertOff1.png"),
                                            width: 35,
                                            height: 35,
                                          )
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Material(
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        child: InkWell(
                                          onTap: () {
                                            // handle tap
                                          },
                                          borderRadius: BorderRadius.circular(5),
                                          child: Image(
                                            image: task.beforeMediumAlert || task.afterMediumAlert? AssetImage("assets/mediumAlertOn1.png") : AssetImage("assets/mediumAlertOff1.png"),
                                            width: 35,
                                            height: 35,
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          )
                        )
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  "assets/taskPending.png",
                  width: 48,
                  height: 48,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
