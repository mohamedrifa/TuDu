import 'package:flutter/material.dart';
import 'task_screen.dart';

class TaskAddingScreen extends StatefulWidget {
  const TaskAddingScreen({super.key});

  @override
  State<TaskAddingScreen> createState() => _TaskAddingScreenState();
}

class _TaskAddingScreenState extends State<TaskAddingScreen> {
  bool isImportant = false;
  double leftOffset = 0;

  String selectedBefore = "5 Mins";
  String selectedAfter = "On Time";
  final List<bool> _selectedDays = List.generate(7, (index) => false);

  void _navigateToHome() {
    setState(() {
      leftOffset = MediaQuery.of(context).size.width; // Adjust this value as needed for your animation
    });
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
    return Scaffold(
      backgroundColor: const Color(0xFF313036),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              top: 0,
              left: leftOffset,
              right: -leftOffset,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 122.7,
                      decoration: const BoxDecoration(
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
                            borderRadius: BorderRadius.circular(30), // ← Missing comma added
                            child: InkWell(
                              onTap: () => _navigateToHome(),
                              borderRadius: BorderRadius.circular(30), // Optional: for ripple to match shape
                              child: const Image(
                                image: AssetImage("assets/addTaskArrowBack.png"),
                                width: 35,
                                height: 35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("Add Task",
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.3),
                          _buildLabel("Task Name"),
                          const SizedBox(height: 16),
                          _buildTextField(" Eg: Read Novel"),
                          const SizedBox(height: 24),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => {    }, // Optional: for ripple to match shape
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Tommorow–Sun, 25 May", 
                                  style: TextStyle(
                                    color: Color(0xFFEBFAF9),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  )
                                ),
                                Image(
                                  image: AssetImage("assets/calender_icon.png"), 
                                  width: 35, 
                                  height: 35
                                ),
                              ],
                            ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: "MTWTFSS".split("").asMap().entries.map((entry) {
        int index = entry.key;
        String day = entry.value;
        bool isSelected = _selectedDays[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedDays[index] = !_selectedDays[index];
              });
            },
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: 35,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF227D7B)
                    : const Color.fromARGB(0, 43, 46, 60),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: index == 6
                        ? const Color(0xFFD11E1E) // Sunday in red
                        : const Color(0xFFEBFAF9),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        );
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
                              _buildTag("Upskill", const Color(0xFFEDD57E)),
                              _buildTag("Work", const Color(0xFF68C6D9)),
                              _buildTag("Personal", const Color(0xFFDD7EB1)),
                              _buildTag("Health", const Color(0xFF7EDD86)),
                              _buildTag("Exercise", const Color(0xFF7EBCED)),
                              _buildTag("Social", const Color(0xFFF28C8C)),
                              _buildTag("Spiritual", const Color(0xFFD78CF2)),
                              _buildTag("Finance", const Color(0xFFB5ED7E)),
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
                              const Text("Mark As Important",
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
                              Expanded(
                                child: _buildDropdown(
                                  "Before",
                                  ["5 Mins", "10 Mins", "15 Mins"],
                                  selectedBefore,
                                  (val) => setState(() => selectedBefore = val!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  "After",
                                  ["On Time", "5 Mins Late"],
                                  selectedAfter,
                                  (val) => setState(() => selectedAfter = val!),
                                ),
                              ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        color: Color(0xFFEBFAF9),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEBFAF9),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: TextField(
        style: const TextStyle(
          color: Color(0xFF1B1A1E),
          fontSize: 20,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
          ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF82808E),
            fontSize: 20,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            ),
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, void Function(String?) onChanged) {
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
              isExpanded: true,
              dropdownColor: const Color(0xFF2B2E3C),
              style: const TextStyle(color: Colors.white),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        )
      ],
    );
  }
}
