import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../database/hive_service.dart';
import 'task_adding_screen.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  DateTime now = DateTime.now();
  String addTaskId = DateFormat('yyyyMMddhhmmss').format(DateTime.now());

  void _navigateToAddTaskScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600), // 1.5 seconds
        pageBuilder: (context, animation, secondaryAnimation) => TaskAddingScreen(taskId: addTaskId, isEdit: false),
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

  String selectedDate = "Today";
  String showDate = DateFormat('d EEE MMM yyyy').format(DateTime.now());
  void changeSelectedDate(String date) {
    setState(() {
      selectedDate = date;
      if (selectedDate == "Today") {
        showDate = DateFormat('d EEE MMM yyyy').format(DateTime.now());
      } else if (selectedDate == "Tommorow") {
        showDate = DateFormat('d EEE MMM yyyy').format(DateTime.now().add(Duration(days: 1)));
      } else {

      }
    });
  }
  bool allDaysFalse(List weekDays) {
    for (int i = 0; i<weekDays.length; i++) {
      if (weekDays[i]) {
        return false;
      }
    }
    return true;
  }

  bool filteredList(String date, List weekDays, bool isImportant) {
    if (allDaysFalse(weekDays)) {
      DateFormat inputFormat = DateFormat("d MM yyyy");
      DateTime parsedDate = inputFormat.parse(date);
      String formattedDate = DateFormat('d EEE MMM yyyy').format(parsedDate);
      return showDate == formattedDate;
    } else {
      DateFormat inputFormat = DateFormat("d EEE MMM yyyy");
      DateTime parsedDate = inputFormat.parse(showDate);
      String formattedDate = DateFormat('EEE').format(parsedDate);
      switch(formattedDate) {
        case "Mon":
          if(weekDays[0]) {
            return true;
          }
        case "Tue":
          if(weekDays[1]) {
            return true;
          }
        case "Wed":
          if(weekDays[2]) {
            return true;
          }
        case "Thu":
          if(weekDays[3]) {
            return true;
          }
        case "Fri":
          if(weekDays[4]) {
            return true;
          }
        case "Sat":
          if(weekDays[5]) {
            return true;
          }
        case "Sun":
          if(weekDays[6]) {
            return true;
          }
      }
      return false;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final tasksBox = HiveService.getTasksBox();
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 47.48,
              right: 0,
              child: Image(
                width: 66.8,
                image: AssetImage('assets/pageMark.png'),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 66.0, left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      // buttons needs to included
                      Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: InkWell(
                          onTap: () {
                            changeSelectedDate("Today");
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: selectedDate == "Today" ? Color(0xFFFED289) : Colors.transparent,
                              border: Border.all(color: Color(0xFFFED289), width: 1),
                            ),
                            child: Text(
                              "Today",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: selectedDate == "Today" ? Color(0xFF1B1A1E) : Color(0xFFEBFAF9),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      ),
                      SizedBox(width: 11),
                      Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: InkWell(
                          onTap: () {
                            changeSelectedDate("Tommorow");
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: selectedDate == "Tommorow" ? Color(0xFFFED289) : Colors.transparent,
                              border: Border.all(color: Color(0xFFFED289), width: 1),
                            ),
                            child: Text(
                              "Tommorow",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: selectedDate == "Tommorow" ? Color(0xFF1B1A1E) : Color(0xFFEBFAF9),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ),
                // Date Text
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      showDate,
                      style: TextStyle(
                          color: Color(0xFFEBFAF9),
                          fontFamily: 'Quantico',
                          fontWeight: FontWeight.w700,
                          fontSize: 24),
                    ),
                  ),
                ),
                // Watch for changes in Hive box
                Expanded(
                  child: ValueListenableBuilder<Box<Task>>(
                    valueListenable: tasksBox.listenable(),
                    builder: (context, box, _) {
                      final tasks = box.values.toList();

                      if (tasks.isEmpty) {
                        return _emptyTaskWidget(context);
                      } else {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  final task = tasks[index];
                                  if(filteredList(task.date, task.weekDays, task.important)){
                                    return TaskCard(
                                      index: index,
                                      id: task.id,
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.centerRight,
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 14.6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Add New',
                                        style: TextStyle(
                                          color: Color(0xFFEBFAF9),
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(width: 24.75),
                                      InkWell(
                                        onTap: () => _navigateToAddTaskScreen(context),
                                        borderRadius: BorderRadius.circular(8),
                                        splashColor: Colors.white24,
                                        child: const Image(
                                          image: AssetImage('assets/addTaskPlus.png'),
                                          width: 52.5,
                                          height: 52.5,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                        );
                      }
                    },
                  ),
                ),

                
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _emptyTaskWidget( BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 85.09),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 18),
                children: [
                  TextSpan(
                    text: "‘’you Have No ",
                    style: TextStyle(
                      color: Color(0xFFEBFAF9),
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "Tasks",
                    style: TextStyle(
                      color: Color(0xFFFED289),
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: " Yet”",
                    style: TextStyle(
                      color: Color(0xFFEBFAF9),
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 24.0),
            child: Image.asset(
              'assets/emptyTaskImg.png',
              height: 253.15,
            ),

          ),
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: 350,
                    margin: EdgeInsets.only(top: 24.0, bottom: 24.0),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          children: [
                            TextSpan(
                              text: "‘’",
                              style: TextStyle(
                                color: Color(0xFFEBFAF9),
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: "Add Your First Task",
                              style: TextStyle(
                                color: Color(0xFFFED289),
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: " ”",
                              style: TextStyle(
                                color: Color(0xFFEBFAF9),
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    child: InkWell(
                      onTap: () {
                        _navigateToAddTaskScreen(context);
                      },
                      splashColor: Colors.white.withOpacity(0.2),
                      child: Container(
                        width: 205.0,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.75),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 31, 209, 162),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add New",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Image.asset(
                              'assets/addTaskPlus.png',
                              width: 52.5,
                              height: 52.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 55,
                left: 20,
                child: Transform.rotate(
                  angle: 0.01,
                  child: Image.asset(
                    'assets/emptytaskArrow.png',
                    width: 27.23,
                    height: 65.77,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
