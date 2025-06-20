import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../database/hive_service.dart';
import 'task_adding_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/quickLinks.dart';

// ignore: must_be_immutable
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  DateTime now = DateTime.now();
  String addTaskId = DateFormat('yyyyMMddhhmmss').format(DateTime.now());

  String selectedDate = "Today";
  String showDate = DateFormat('d EEE MMM yyyy').format(DateTime.now());

  void _navigateToAddTaskScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TaskAddingScreen(taskId: addTaskId, isEdit: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void changeSelectedDate(String date) {
    setState(() {
      selectedDate = date;
      if (selectedDate == "Today") {
        showDate = DateFormat('d EEE MMM yyyy').format(DateTime.now());
      } else if (selectedDate == "Tomorrow") {
        showDate = DateFormat('d EEE MMM yyyy')
            .format(DateTime.now().add(Duration(days: 1)));
      }
    });
  }
  
  bool quickLinksEnabled = false;
  void quickLinkWidget() {
    setState(() {
      quickLinksEnabled = true;
    });
  }

  bool allDaysFalse(List weekDays) {
    for (var day in weekDays) {
      if (day) return false;
    }
    return true;
  }

  bool filteredList(String date, List weekDays, bool isImportant) {
    if (showDate == "Importants") {
      return isImportant;
    } else if (allDaysFalse(weekDays)) {
      DateFormat inputFormat = DateFormat("d MM yyyy");
      DateTime parsedDate = inputFormat.parse(date);
      String formattedDate = DateFormat('d EEE MMM yyyy').format(parsedDate);
      return showDate == formattedDate;
    } else {
      DateTime parsedDate = DateFormat("d EEE MMM yyyy").parse(showDate);
      String formattedDay = DateFormat('EEE').format(parsedDate);
      switch (formattedDay) {
        case "Mon":
          return weekDays[0];
        case "Tue":
          return weekDays[1];
        case "Wed":
          return weekDays[2];
        case "Thu":
          return weekDays[3];
        case "Fri":
          return weekDays[4];
        case "Sat":
          return weekDays[5];
        case "Sun":
          return weekDays[6];
        default:
          return false;
      }
    }
  }
  void dateChange(String value) {
    if(value == "Importants"){
      setState(() {
      showDate = value;
      selectedDate = "custom";
    });
    } else {
      DateFormat inputFormat = DateFormat("d MM yyyy");
      DateTime parsedDate = inputFormat.parse(value);
      String formattedDate = DateFormat('d EEE MMM yyyy').format(parsedDate);
      // Normalize today and tomorrow to ignore time
      DateTime today = DateTime.now();
      DateTime tomorrow = today.add(Duration(days: 1));
      
      bool isSameDate(DateTime a, DateTime b) {
        return a.year == b.year && a.month == b.month && a.day == b.day;
      }
      
      if (isSameDate(parsedDate, today)) {
        setState(() {
          selectedDate = "Today";
          showDate = formattedDate;
        });
      } else if (isSameDate(parsedDate, tomorrow)) {
        setState(() {
          selectedDate = "Tomorrow";
          showDate = formattedDate;
        });
      } else {
        setState(() {
          selectedDate = "custom";
          showDate = formattedDate;
        });
      }     
    }    
  }

  @override
  Widget build(BuildContext context) {
    final tasksBox = HiveService.getTasksBox();
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
          children: [
            Positioned(
              top: 47.48,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  quickLinkWidget();
                },
                child: Image(
                  width: 66.8,
                  image: AssetImage('assets/pageMark.png'),
                ),
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 66.0, left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      _buildDateSelector("Today"),
                      const SizedBox(width: 11),
                      _buildDateSelector("Tomorrow"),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      showDate,
                      style: const TextStyle(
                        color: Color(0xFFEBFAF9),
                        fontFamily: 'Quantico',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<Box<Task>>(
                    valueListenable: tasksBox.listenable(),
                    builder: (context, box, _) {
                      final tasks = box.values.toList();
                      final filteredTasks = tasks
                          .where((task) =>
                              filteredList(task.date, task.weekDays, task.important))
                          .toList();

  // ✅ Sort by fromTime in ascending order
                      filteredTasks.sort((a, b) {
                        final aParts = a.fromTime.split(':').map(int.parse).toList();
                        final bParts = b.fromTime.split(':').map(int.parse).toList();

                        final aMinutes = aParts[0] * 60 + aParts[1];
                        final bMinutes = bParts[0] * 60 + bParts[1];

                        return aMinutes.compareTo(bMinutes);
                      });

                      if (filteredTasks.isEmpty) {
                        return _emptyTaskWidget(context);
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return TaskCard(
                                  index: index,
                                  id: task.id,
                                  date: showDate,
                                );
                              },
                            ),
                          ),
                          _buildAddNewButton(context),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            if(quickLinksEnabled)
              QuickLinks(
                quickLinksEnabled:quickLinksEnabled,
                onToggle: (value) {
                  setState(() {
                    quickLinksEnabled = value;
                  });
                },
                showDate: showDate,
                onDateChanged: (value) {dateChange(value);},
              )
          ],
        ),
      );
  }

  Widget _buildDateSelector(String label) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => changeSelectedDate(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: selectedDate == label
                ? const Color(0xFFFED289)
                : Colors.transparent,
            border: Border.all(color: const Color(0xFFFED289), width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: selectedDate == label
                  ? const Color(0xFF1B1A1E)
                  : const Color(0xFFEBFAF9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.6),
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
    );
  }

  Widget _emptyTaskWidget( BuildContext context) {
    return SingleChildScrollView(
      child:  Center(
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
          ),
          const SizedBox(height: 100),
        ],
      ),
    ),
    );
  }
}
