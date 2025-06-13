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


  final fromHourController = TextEditingController();
  final fromMinuteController = TextEditingController();
  final fromHourFocus = FocusNode();
  final fromMinuteFocus = FocusNode();

  final toHourController = TextEditingController();
  final toMinuteController = TextEditingController();
  final toHourFocus = FocusNode();
  final toMinuteFocus = FocusNode();

  String fromperiod = "A.M";
  String toperiod = "A.M";

  String selectedTag = "";
  final _tagFocusNode = FocusNode();
  final tagController = TextEditingController();

  @override
  void dispose() {
    fromHourController.dispose();
    fromMinuteController.dispose();
    fromHourFocus.dispose();
    fromMinuteFocus.dispose();

    toHourController.dispose();
    toMinuteController.dispose();
    toHourFocus.dispose();
    toMinuteFocus.dispose();

     _tagFocusNode.dispose();
    super.dispose();
  }

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
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 24),
                          _buildLabel("Schedule"),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildTimePicker("From", "08", "00", "A.M"),
                              const SizedBox(width: 12),
                              _buildTimePicker("To", "06", "00", "P.M"),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildLabel("Tags"),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 11.5),
                            child: Wrap(
                              spacing: 11,
                              runSpacing: 11,
                              children: [
                                _buildTag("Upskill"),
                                _buildTag("Work"),
                                _buildTag("Personal"),
                                _buildTag("Health"),
                                _buildTag("Exercise"),
                                _buildTag("Social"),
                                _buildTag("Spiritual"),
                                _buildTag("Finance"),
                                _buildTagAdder(),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: isImportant,
                                  onChanged: (val) {
                                    setState(() {
                                      isImportant = val!;
                                    });
                                  },
                                  activeColor: const Color(0xFF268D8C),
                                  checkColor: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 19), 
                              _buildLabel("Mark As Important"),
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

  // ignore: non_constant_identifier_names
  void am_pmDialog(String label, String period) {
    if(label == "From") {
      if(fromperiod == "A.M") {
        setState(() {
          fromperiod = "P.M";
        });
      } else {
        setState(() {
          fromperiod = "A.M";
        });
      }
    } else {
      if(toperiod == "A.M") {
        setState(() {
          toperiod = "P.M";
        });
      } else {
        setState(() {
          toperiod = "A.M";
        });
      }
    }
  }
 
  Widget _buildTimePicker(String label, String hour, String minute, String period) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFEBFAF9),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
        SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
      height: 40,
      width: 94,
      decoration: BoxDecoration(
        color: const Color(0xFFE9F8F8),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDigitField(
            controller:  label == "From" ? fromHourController : toHourController,
            focusNode: label == "From" ? fromHourFocus : toHourFocus,
            onChanged: (value) {
              if (value.length == 2) {
                if (label == "From") {
                  fromMinuteFocus.requestFocus();
                } else {
                  toMinuteFocus.requestFocus();
                }
              } else if (value.isEmpty && label == "To") {
                  fromMinuteFocus.requestFocus();
              }
            },
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.black,
          ),
          _buildDigitField(
            controller: label == "From" ? fromMinuteController : toMinuteController,
            focusNode: label == "From" ? fromMinuteFocus : toMinuteFocus,
            onChanged: (value) {
              if (value.isEmpty) {
                if (label == "From") {
                  fromHourFocus.requestFocus();
                } else {
                  toHourFocus.requestFocus();
                }
              } else if (value.length == 2) {
                if (label == "From") {
                  toHourFocus.requestFocus();
                } else {
                  toMinuteFocus.unfocus();
                }
              }
            },
          ),
        ],
      ),
    ),
            SizedBox(height: 5,),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  am_pmDialog(label, period);
                },
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: Container(
                height: 31,
                width: 94,
                decoration: BoxDecoration(
                  color:  label == "From" ? (fromperiod == "A.M" ? Color(0xFF268D8C) : const Color(0xFFFED289)) : (toperiod == "A.M" ? Color(0xFF268D8C) : const Color(0xFFFED289)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(image: AssetImage("assets/updown.png"), width: 21, height: 21),
                      const SizedBox(width: 8.41),
                      Text(
                        label == "From" ? fromperiod : toperiod,
                        style: const TextStyle(
                          color: Color(0xFF0D0C10),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Quantico',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ),
            
          ],
        ),
        
      ],
    );
  }

  Widget _buildDigitField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required void Function(String) onChanged,
  }) {
    return SizedBox(
      width: 46,
      height: 33,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        maxLength: 2,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Quantico', 
        ),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: '00',
          counterText: '',
          hintStyle: TextStyle(
            color: Color(0xFF82808E),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Quantico',
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTag = text;
            _tagFocusNode.unfocus(); 
            tagController.clear();
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selectedTag == text ? const Color(0xFFFED289) : const Color.fromARGB(0, 43, 46, 60),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFFFED289), width: 1),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selectedTag == text ? Color(0xFF1B1A1E) : Color(0xFFEBFAF9),
              fontSize: 18,
              fontWeight: FontWeight.w300,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagAdder() {
  final bool showBackground = _tagFocusNode.hasFocus && selectedTag.isNotEmpty;

  return Container(
    height: 27,
    padding: const EdgeInsets.only(left: 8, right: 8, top: 1.5, bottom: 1.5),
    decoration: BoxDecoration(
      color: showBackground ? const Color(0xFFFED189) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFED289), width: 1),
    ),
    child: IntrinsicWidth(
      child: TextField(
        focusNode: _tagFocusNode,
        controller: tagController,
        cursorHeight: 15,
        cursorColor: showBackground ? const Color(0xFF1B1A1E) : const Color(0xFFFED289),
        maxLines: 1,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Color(0xFF1B1A1E),
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          hintText: "+Add...",
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Color(0xFFFEE5BD),
          ),
          border: InputBorder.none,
        ),
        onChanged: (value) => setState(() => selectedTag = value),
        onTap: () => setState(() => selectedTag = ""),
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
