import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../database/hive_service.dart';
import 'task_adding_screen.dart'; // Import the task adding screen

class TaskScreen extends StatelessWidget {

  
  void addPredefinedTasks() async {
    var box = Hive.box<Task>('tasks');

    final List<Task> tasks = [
      Task(
          title: "Prayer",
          time: "5.00 A.M To 5.40 A.M",
          tags: ["Spiritual"]),
      Task(
          title: "Read Novel",
          time: "6.00 A.M To 7.00 A.M",
          tags: ["Upskill"]),
      Task(
          title: "Prayer",
          time: "1.00 A.M To 1.30 A.M",
          tags: ["Spiritual", "Important"]),
      Task(
          title: "Out With Friends",
          time: "7.00 P.M To 8.10 P.M",
          tags: ["Social"]),
    ];

    // Add each task to the Hive box
    for (var task in tasks) {
      await box.add(task);
    }
  }

  void _navigateToAddTaskScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600), // 1.5 seconds
        pageBuilder: (context, animation, secondaryAnimation) => TaskAddingScreen(),
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


  @override
  Widget build(BuildContext context) {
    final tasksBox = HiveService.getTasksBox();
    // addPredefinedTasks();
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
                      Chip(label: Text("Today")),
                      SizedBox(width: 10),
                      Chip(label: Text("Tomorrow")),
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
                      "16 Tue Mar 2025",
                      style: TextStyle(
                          color: Color(0xFFEBFAF9),
                          fontFamily: 'Quantico',
                          fontWeight: FontWeight.w700,
                          fontSize: 24),
                    ),
                  ),
                ),
                // Watch for changes in Hive box
                ValueListenableBuilder<Box<Task>>(
                  valueListenable: tasksBox.listenable(),
                  builder: (context, box, _) {
                    final tasks = box.values.toList();
                    return tasks.isEmpty
                        ? _emptyTaskWidget(context)
                        : Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return TaskCard(
                                  title: task.title,
                                  time: task.time,
                                  tags: task.tags,
                                  index: index,
                                );
                              },
                            ),
                          );
                  },
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent, // Transparent background
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Add New',
                            style: TextStyle(
                              color: Color(0xFFEBFAF9), // Light text
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 24.75),
                          InkWell(
                            onTap: () { _navigateToAddTaskScreen(context); },
                            borderRadius: BorderRadius.circular(8),
                            splashColor: Colors.white24, // Tap effect
                            child: Image(
                              image: AssetImage('assets/addTaskPlus.png'),
                              width: 52.5,
                              height: 52.5,
                              fit: BoxFit.fill,
                            ),
                          ),
                       ],
                      ),
                    ),
                  )
                ),
     
                // Add New Button
                // ValueListenableBuilder<Box<Task>>(
                //   valueListenable: tasksBox.listenable(),
                //   builder: (context, box, _) {
                //     return box.isEmpty
                //         ? SizedBox.shrink()
                //         : Padding(
                //             padding: const EdgeInsets.all(16.0),
                //             child: ElevatedButton.icon(
                //               onPressed: () => _addNewTask(context, box),
                //               icon: Icon(Icons.add),
                //               label: Text("Add New"),
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: Color(0xFF1FD1A3),
                //                 foregroundColor: Colors.black,
                //                 minimumSize: Size(double.infinity, 50),
                //               ),
                //             ),
                //           );
                //   },
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Future<void> _addNewTask(BuildContext context, Box<Task> box) async {
  //   // Example of adding a new task - you should implement a proper form
  //   final newTask = Task(
  //     title: "New Task",
  //     time: "12:00 PM To 1:00 PM",
  //     tags: ["New"],
  //   );

  //   await box.add(newTask);

  //   // Show a snackbar or navigate to a form screen in a real app
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Task added successfully")),
  //   );
  // }

  Future<void> _deleteTask(Box<Task> box, int index) async {
    await box.deleteAt(index);
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
