import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final int index;
  final String id;

  const TaskCard({
    super.key,
    required this.index,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>('tasks');
    final Task? task = box.values.cast<Task?>().firstWhere(
      (task) => task?.id == id,
      orElse: () => null,
    );

    // Return an empty Container if task not found
    if (task == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: task.important? Color(0xFFFED289) : Color(0xFF5AD3D1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Center(
          child: Row(
            children: [
              Container(

              ),
              Image(
                image: AssetImage("assets/taskPending.png"),
                width: 48,
                height: 48,
              )

            ],
          ),
        ),
      ),
    );
  }
}
