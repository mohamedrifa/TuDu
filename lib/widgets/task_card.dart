import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final List<String> tags;
  final int index;

  const TaskCard({
    required this.title,
    required this.time,
    required this.tags,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Color(0xFF5AD3D1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(time, style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
