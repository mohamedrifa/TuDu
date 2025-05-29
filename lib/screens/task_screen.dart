import 'package:flutter/material.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';

class TaskScreen extends StatelessWidget {
  final List<Task> tasks = [
    Task(title: "Prayer", time: "5.00 A.M To 5.40 A.M", tags: ["Spiritual"]),
    Task(title: "Read Novel", time: "6.00 A.M To 7.00 A.M", tags: ["Upskill"]),
    Task(title: "Prayer", time: "1.00 A.M To 1.30 A.M", tags: ["Spiritual", "Important"]),
    Task(title: "Out With Friends", time: "7.00 P.M To 8.10 P.M", tags: ["Social"]),
    // Add as many tasks as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF313036),
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
                // Header
                Padding(
              padding: const EdgeInsets.only(top: 66.0, left: 16.0, right: 16.0),
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
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "16 Tue Mar 2025",
                  style: TextStyle(
                    color: Color(0xFFEBFAF9), 
                    fontFamily: 'Quantico',
                    fontWeight: FontWeight.w700,
                    fontSize: 24
                    ),
                ),
              ),
            ),
            // Dynamic Task Cards
            Expanded(
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
            ),

            // Add New Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add new task logic
                },
                icon: Icon(Icons.add),
                label: Text("Add New"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1FD1A3),
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            )
              ],
            )
            
          ],
        ),
      ),
    );
  }
}
