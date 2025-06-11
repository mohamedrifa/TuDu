import 'package:flutter/material.dart';
import 'task_screen.dart';

class TaskAddingScreen extends StatefulWidget {
  const TaskAddingScreen({super.key});

  @override
  State<TaskAddingScreen> createState() => _TaskAddingScreenState();
}

class _TaskAddingScreenState extends State<TaskAddingScreen> {
  bool isImportant = false;


  void _navigateToHome() {
  Navigator.of(context).pushReplacement(

    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => TaskScreen(),
      transitionsBuilder: (_, animation, __, child) {
        // Horizontal slide from left to right
        final tween = Tween<Offset>(
          begin: const Offset(-1.0, 0.0), // Start offscreen from the left
          end: Offset.zero,               // Slide into position
        ).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}





  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF313036),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 122.7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF313036), Color(0xFF434549)], 
                      begin: Alignment.topCenter, 
                      end: Alignment.bottomCenter, 
                    ),
                  ),
                  child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _navigateToHome(),
                        child: Image(
                          image: AssetImage("assets/addTaskArrowBack.png"), 
                          width: 35,
                          height: 35
                          )
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("Add Task",
                        style: TextStyle(
                          color: Color(0xFFF4F4F5),
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
                ),

              Padding(
                padding:  const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                _buildLabel("Task Name"),
                _buildTextField("Eg: Read Novel"),
                const SizedBox(height: 12),
                _buildLabel("Tommorow–Sun, 25 May"),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2E3C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Tommorow–Sun, 25 May", style: TextStyle(color: Colors.white70)),
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white70),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabel("Schedule"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: "MTWTFSS".split("").map((day) {
                    return Text(day,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ));
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTimePicker("From", "08", "00", "A.M"),
                    const SizedBox(width: 12),
                    _buildTimePicker("To", "06", "00", "P.M"),
                  ],
                ),
                const SizedBox(height: 12),
                _buildLabel("Tags"),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTag("Upskill", Color(0xFFEDD57E)),
                    _buildTag("Work", Color(0xFF68C6D9)),
                    _buildTag("Personal", Color(0xFFDD7EB1)),
                    _buildTag("Health", Color(0xFF7EDD86)),
                    _buildTag("Exercise", Color(0xFF7EBCED)),
                    _buildTag("Social", Color(0xFFF28C8C)),
                    _buildTag("Spiritual", Color(0xFFD78CF2)),
                    _buildTag("Finance", Color(0xFFB5ED7E)),
                    _buildTag("+Add", Colors.white24),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isImportant,
                      onChanged: (val) {
                        setState(() {
                          isImportant = val!;
                        });
                      },
                      activeColor: const Color(0xFF6BD1E8),
                    ),
                    Text("Mark As Important",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ))
                  ],
                ),
                const SizedBox(height: 12),
                _buildLabel("Location"),
                _buildTextField("At Cafe"),
                const SizedBox(height: 12),
                _buildLabel("Sub Tasks"),
                _buildTextField("Binding Work"),
                const SizedBox(height: 12),
                _buildLabel("Notifications"),
                Row(
                  children: [
                    Expanded(child: _buildDropdown("Before", ["5 Mins", "10 Mins", "15 Mins"], "5 Mins")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdown("After", ["On Time", "5 Mins Late"], "On Time")),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("ADD"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B2E3C),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, String hour, String minute, String period) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2B2E3C),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$hour : $minute", style: const TextStyle(color: Colors.white)),
                Text(period, style: const TextStyle(color: Colors.white54)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2E3C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF2B2E3C),
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (val) {},
            ),
          ),
        )
      ],
    );
  }
}
