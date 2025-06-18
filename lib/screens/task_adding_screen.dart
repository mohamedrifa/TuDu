import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'task_screen.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskAddingScreen extends StatefulWidget {
  final String taskId;
  final bool isEdit;
  const TaskAddingScreen({super.key, required this.taskId, required this.isEdit});

  @override
  State<TaskAddingScreen> createState() => _TaskAddingScreenState();
}

class _TaskAddingScreenState extends State<TaskAddingScreen> {
  double leftOffset = 0;
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('EEEE, d MMMM').format(DateTime.now());

  final fromHourFocus = FocusNode();
  final fromMinuteFocus = FocusNode();
  final toHourFocus = FocusNode();
  final toMinuteFocus = FocusNode();    
  final _tagFocusNode = FocusNode();
  final fromMinuteRawKeyFocus = FocusNode(); 
  final toMinuteRawKeyFocus = FocusNode();
  final fromHourRawFocus = FocusNode();
  final toHourRawFocus = FocusNode();

  final tagController = TextEditingController();

  String showDate = "Today-${DateFormat('EEE, d MMMM').format(DateTime.now())}";
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
  final taskNameController = TextEditingController();
  final locationController = TextEditingController();
  final subTaskController = TextEditingController();

  void toast (String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
      gravity: ToastGravity.CENTER, // or TOP, CENTER
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Datas to Submit
  String taskName = "";
  String date = DateFormat('d MM yyyy').format(DateTime.now());
  List<bool> _selectedDays = List.generate(7, (index) => false);
  final fromHourController = TextEditingController();
  final fromMinuteController = TextEditingController();
  final toHourController = TextEditingController();
  final toMinuteController = TextEditingController();
  String fromperiod = "A.M";
  String toperiod = "A.M";
  String selectedTag = "";
  bool isImportant = false;
  String location = "";
  String subTask = "";
  bool isBeforeLoudAlert = false;
  bool isBeforeMediumAlert = false;
  bool isAfterLoudAlert = false;
  bool isAfterMediumAlert = false;
  String selectedBefore = "5 Mins";
  String selectedAfter = "On Time";
  // End

  bool _selectedDaysCheck () {
    for (int i = 0; i < _selectedDays.length; i++) {
      if(_selectedDays[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    final box = Hive.box<Task>('tasks');
    final task = box.get(widget.taskId);
    if(widget.isEdit) {
      taskNameController.text = task!.title;
      taskName = task.title;

      _selectedDays = task.weekDays;
      date = task.date;
      if(_selectedDaysCheck()) {
        String dateString = task.date;
        DateFormat format = DateFormat("d MM yyyy");
        DateTime parsedDate = format.parse(dateString);
        showdateModify(parsedDate);
      } else {
        for (int i = 0; i < _selectedDays.length; i++) {
          daySelection(i);
          updateShowDate();
        }
      }

      List<String> parts1 = task.fromTime.split(":");
      int fromHour = int.parse(parts1[0]);
      int fromMinute = int.parse(parts1[1]);
      DateTime time1 = DateTime(0, 1, 1, fromHour, fromMinute);
      fromHourController.text = DateFormat('hh').format(time1);
      fromMinuteController.text = DateFormat('mm').format(time1);
      fromperiod = DateFormat('a').format(time1).replaceAll("AM", "A.M").replaceAll("PM", "P.M");

      List<String> parts2 = task.toTime.split(":");
      int toHour = int.parse(parts2[0]);
      int toMinute = int.parse(parts2[1]);
      DateTime time2 = DateTime(0, 1, 1, toHour, toMinute);
      toHourController.text = DateFormat('hh').format(time2);
      toMinuteController.text = DateFormat('mm').format(time2);
      toperiod = DateFormat('a').format(time2).replaceAll("AM", "A.M").replaceAll("PM", "P.M");

      selectedTag = task.tags;

      isImportant = task.important;

      locationController.text = task.location;
      location = task.location;

      subTaskController.text = task.subTask;
      subTask = task.subTask;

      isBeforeLoudAlert = task.beforeLoudAlert;
      isBeforeMediumAlert = task.beforeMediumAlert;

      selectedBefore = task.alertBefore;

      isAfterLoudAlert = task.afterLoudAlert;
      isAfterMediumAlert = task.afterMediumAlert;

      selectedAfter = task.alertAfter;

    }
  }

  void submitTask() {
    bool toAlert = false;
    String toastMessage = "";
    if(taskName == ""){
      toastMessage != "" ? toastMessage = "$toastMessage," : toastMessage = "";
      toAlert = true;
      toastMessage = "$toastMessage Task Name";
    }
    if(fromHourController.text == "" || fromMinuteController.text == ""  || toHourController.text == "" || toMinuteController.text == "") {
      toastMessage != "" ? toastMessage = "$toastMessage," : toastMessage = "";
      toAlert = true;
      toastMessage = "$toastMessage Time Scheduling";
    }
    if(location == "") {
      toastMessage != "" ? toastMessage = "$toastMessage," : toastMessage = "";
      toAlert = true;
      toastMessage = "$toastMessage Loaction";
    }
    if(toAlert){
      toastMessage = "$toastMessage are Required";
      toast(toastMessage);
      return;
    }

    bool fromFlag  =  false;
    bool toFlag  = false;
    int fromHour = int.tryParse(fromHourController.text) ?? 0;
    int toHour = int.tryParse(toHourController.text) ?? 0;
    int fromMinute = int.tryParse(fromMinuteController.text) ?? 0;
    int toMinute = int.tryParse(toMinuteController.text) ?? 0;
    if(fromHour > 12 || fromHour < 1 || fromMinute > 59 || fromMinute < 0) {
      fromHourController.text = "";
      fromMinuteController.text = "";
      toastMessage = "Invalid From Time";
      fromFlag = true;
    }
    if(toHour > 12 || toHour < 1 || toMinute > 59 || toMinute < 0) {
      toHourController.text = "";
      toMinuteController.text = "";
      toastMessage = "Invalid To Time";
      toFlag = true;
    }
    if(fromFlag && toFlag) {
      toastMessage = "Invalid From and To Time";
    }

    if(fromFlag || toFlag) {
      toast(toastMessage);
      return;
    }
    toastMessage = "From Time should be less than To Time";
    if(fromHour>toHour) {
      fromHourController.text = "";
      fromMinuteController.text = "";
      toHourController.text = "";
      toMinuteController.text = "";
      toast(toastMessage);
      return;
    } else if (fromHour == toHour && fromMinute >= toMinute) {
      fromHourController.text = "";
      fromMinuteController.text = "";
      toHourController.text = "";
      toMinuteController.text = "";
      toast(toastMessage);
      return;
    }

    // Convert to 24-hour format if PM and not 12
    if (fromperiod == "P.M" && fromHour != 12) {
      fromHour += 12;
    }
    if (toperiod == "P.M" && toHour != 12) {
      toHour += 12;
    }
    // Handle midnight edge case (12 A.M.)
    if (fromperiod == "A.M" && fromHour == 12) {
      fromHour = 0;
    }
    if (toperiod == "A.M" && toHour == 12) {
      toHour = 0;
    }
    String fromTime = "${fromHour.toString().padLeft(2, '0')}:${fromMinuteController.text.padLeft(2, '0')}";
    String toTime = "${toHour.toString().padLeft(2, '0')}:${toMinuteController.text.padLeft(2, '0')}";

    final box = Hive.box<Task>('tasks');
    final task = Task(
      id: widget.taskId,
      title: taskName,
      date: date,
      weekDays: _selectedDays,
      fromTime: fromTime,
      toTime: toTime,
      tags: selectedTag,
      important: isImportant,
      location: location,
      subTask: subTask,
      beforeLoudAlert: isBeforeLoudAlert,
      beforeMediumAlert: isBeforeMediumAlert,
      afterLoudAlert: isAfterLoudAlert,
      afterMediumAlert: isAfterMediumAlert,
      alertBefore: selectedBefore,
      alertAfter: selectedAfter,
    );
    box.put(widget.taskId, task); 
    toast(widget.isEdit? "Task Edited" : "Task Added");
    _navigateToHome();
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

  void deletetask() {
    final box = Hive.box<Task>('tasks');
    box.delete(widget.taskId);
    toast("Task Deleted");
    _navigateToHome();
  }
  
  void showdateModify (DateTime picked) {
    setState(() {
      selectedDate = picked;
      date = DateFormat('d MM yyyy').format(selectedDate!);

      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      final selectedDateOnly = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      if (selectedDateOnly.isAtSameMomentAs(todayDateOnly)) {
        showDate = "Today-${DateFormat('EEE, d MMMM').format(selectedDate!)}";
      } else if (selectedDateOnly.isAtSameMomentAs(todayDateOnly.add(Duration(days: 1)))) {
        showDate = "Tomorrow-${DateFormat('EEE, d MMMM').format(selectedDate!)}";
      } else {
        showDate = DateFormat('EEE, d MMMM').format(selectedDate!);
      }
      for (int i = 0; i < _selectedDays.length; i++) {
        _selectedDays[i] = false;
      }

    });
  }

  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFFFED289), // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Colors.white, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFFED289), // button text color
                backgroundColor: Color(0xFF2B2E3C)
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      showdateModify(picked);
    }
  }
  List indexList = [];
  void daySelection(int index) {
    setState(() {
      if (_selectedDays[index]) {
        indexList.add(index);
        indexList.sort();
      } else {
        indexList.remove(index);
      }
      indexList.sort();
    });
  }
  getDayName(int index) {
    switch (index) {
      case 0:
        return "Monday";
      case 1:
        return "Tuesday";
      case 2:
        return "Wednesday";
      case 3:
        return "Thursday";
      case 4:
        return "Friday";
      case 5:
        return "Saturday";
      case 6:
        return "Sunday";
      default:
        return "";
    }
  }
  void updateShowDate() {
    for (int i = 0; i < indexList.length; i++) {
      if (i == 0) {
        setState(() {
          showDate = "Every ${getDayName(indexList[i])}";
          date = "repeat";
        });
      } else if (i == 6) {
        setState(() {
          showDate = "Every Day";
          date = "repeat";
        });
      } else {
        setState(() {
          showDate += ", ${getDayName(indexList[i])}";
          date = "repeat";
        });
      }
    }
    if (indexList.isEmpty) {
      setState(() {
        showDate = "Today-${DateFormat('EEE, d MMMM').format(DateTime.now())}";
        date = DateFormat('d MM yyyy').format(DateTime.now());
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF313036),
      body: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              top: 0,
              left: leftOffset,
              right: -leftOffset,
              bottom: 0,
              child: SingleChildScrollView(
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
                           Text(
                              widget.isEdit ? "Edit Task" : "Add Task",
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
                          _buildTextField(" Eg: Read Novel", "taskName"),
                          const SizedBox(height: 24),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => { _selectDate(context)   }, // Optional: for ripple to match shape
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      showDate,
                                      overflow: TextOverflow.ellipsis, // adds "..." at the end if it's too long
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Color(0xFFEBFAF9),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8), // optional spacing
                                  const Image(
                                    image: AssetImage("assets/calender_icon.png"),
                                    width: 35,
                                    height: 35,
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
                                      daySelection(index); 
                                    });
                                    updateShowDate();
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
                              _buildTimePicker("From"),
                              const SizedBox(width: 12),
                              _buildTimePicker("To"),
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

                          const SizedBox(height: 24),
                          _buildLabel("Location"),
                          const SizedBox(height: 16),
                          _buildTextField("At Cafe", "location"),
                          const SizedBox(height: 24),
                          _buildLabel("Sub Tasks"),
                          const SizedBox(height: 16),
                          _buildTextField("Binding Work", "subTask"),
                          const SizedBox(height: 24),
                          _buildLabel("Notifications"),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _buildDropdown(
                                "Before",
                                ["5 Mins", "10 Mins", "15 Mins"],
                                selectedBefore,
                                (val) => setState(() => selectedBefore = val!),
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                "After",
                                ["On Time", "5 Mins", "10 Mins"],
                                selectedAfter,
                                (val) => setState(() => selectedAfter = val!),
                              ),
                              
                            ],
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () { submitTask();},
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  height: 56,
                                  width: 119,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D0C10),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.isEdit ? "Edit" : "ADD",
                                          style: const TextStyle(
                                            color: Color(0xFFEBFAF9),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Image(
                                          image: widget.isEdit ? AssetImage("assets/editIcon.png"): AssetImage("assets/addTaskIcon.png"), 
                                          width: 30, 
                                          height: 30
                                        )
                                      ],
                                    )
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if(widget.isEdit)  
                      Material(
                        child: InkWell(
                          onTap: () => {
                            deletetask()
                          },
                          child: Container(
                            width: double.infinity,
                            height: 64,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF802020), Color(0xFF551515)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/dustBin.png",
                                  width: 21,
                                  height: 22.91,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Delete",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24,
                                    color: Color(0xFFEBFAF9),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildTextField(String hint, String fieldType) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEBFAF9),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextField(
        controller: fieldType == "taskName" ? taskNameController
                    : fieldType == "location" ? locationController
                    : subTaskController,
        onChanged: (value) {
          setState(() {
            if (fieldType == "taskName") {
              taskName = value;
            } else if (fieldType == "location") {
              location = value;
            } else if (fieldType == "subTask") {
              subTask = value;
            }
          });
        },
        cursorColor: Colors.black,
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
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void am_pmDialog(String label) {
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
 
  Widget _buildTimePicker(String label) {
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
                    controller: label == "From" ? fromHourController : toHourController,
                    textFieldFocusNode: label == "From" ? fromHourFocus : toHourFocus,
                    rawKeyFocusNode: label == "From" ? fromHourRawFocus : toHourRawFocus,
                    onChanged: (value) {
                      int val = int.tryParse(value) ?? 0;
                      if (val > 1 && val < 10) {
                        value = "0$value";
                        TextEditingController targetController =
                            label == "From" ? fromHourController : toHourController;
                        targetController.text = value;
                        targetController.selection = TextSelection.fromPosition(
                          TextPosition(offset: value.length),
                        );
                      }
                      if (value.length == 2) {
                        if (label == "From") {
                          fromMinuteFocus.requestFocus();
                        } else {
                          toMinuteFocus.requestFocus();
                        }
                      }
                    },
                    onBackspacePressed: () {
                      // If the field is empty and user hits backspace, go back to previous field
                      if (label == "From") {
                        fromMinuteFocus.unfocus();
                      } else {
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
                    textFieldFocusNode: label == "From" ? fromMinuteFocus : toMinuteFocus,
                    rawKeyFocusNode: label == "From" ? fromMinuteRawKeyFocus : toMinuteRawKeyFocus,
                    onChanged: (value) {
                      if (value.length == 2) {
                        if (label == "From") {
                          toHourFocus.requestFocus();
                        } else {
                          toMinuteFocus.unfocus();
                        }
                      } else if (value.isEmpty) {
                        if (label == "From") {
                          fromHourFocus.requestFocus();
                        } else {
                          toHourFocus.requestFocus();
                        }
                      }
                    },
                    onBackspacePressed: () {
                      if (label == "From") {
                        fromHourFocus.requestFocus();
                      } else {
                        toHourFocus.requestFocus();
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
                  am_pmDialog(label);
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
  required FocusNode textFieldFocusNode, // for TextField
  required FocusNode rawKeyFocusNode,    // for RawKeyboardListener
  required void Function(String) onChanged,
  required VoidCallback onBackspacePressed,
}) {
  return SizedBox(
    width: 46,
    height: 33,
    child: RawKeyboardListener(
      focusNode: rawKeyFocusNode, // ✅ CORRECT focus node for RawKeyboardListener
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (controller.text.isEmpty) {
            onBackspacePressed(); // ✅ Call your handler
          }
        }
      },
      child: TextField(
        controller: controller,
        focusNode: textFieldFocusNode, // ✅ CORRECT focus node for TextField
        onChanged: onChanged,
        cursorColor: Colors.black,
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFEBFAF9),
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (label == "Before") {
                    setState(() {
                      isBeforeLoudAlert = !isBeforeLoudAlert;
                      isBeforeMediumAlert = false;
                    });
                  } else {
                    setState(() {
                      isAfterLoudAlert = !isAfterLoudAlert;
                      isAfterMediumAlert = false;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Image(
                  image: label == "Before"
                      ? isBeforeLoudAlert
                          ? const AssetImage("assets/loudAlertOn.png")
                          : const AssetImage("assets/loudAlertOff.png")
                      : isAfterLoudAlert
                          ? const AssetImage("assets/loudAlertOn.png")
                          : const AssetImage("assets/loudAlertOff.png"),
                  width: 35,
                  height: 35,
                ),
              ),
            ),
            SizedBox(width: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (label == "Before") {
                    setState(() {
                      isBeforeMediumAlert = !isBeforeMediumAlert;
                      isBeforeLoudAlert = false;
                    });
                  } else {
                    setState(() {
                      isAfterMediumAlert = !isAfterMediumAlert;
                      isAfterLoudAlert = false;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Image(
                  image: label == "Before"
                      ? isBeforeMediumAlert
                          ? const AssetImage("assets/mediumAlertOn.png")
                          : const AssetImage("assets/mediumAlertOff.png")
                      : isAfterMediumAlert
                          ? const AssetImage("assets/mediumAlertOn.png")
                          : const AssetImage("assets/mediumAlertOff.png"),
                  width: 35,
                  height: 35,
                ),
              ),
            ),
            SizedBox(width: 16),
            IntrinsicWidth(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBFAF9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2B2E3C),
                    style: const TextStyle(
                      color: Color(0xFF82808E),
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    icon: Image.asset(
                      'assets/dropDownArrow.png', 
                      width: 24,
                      height: 24,
                    ),
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
            ),
          ],
        ),
        
      ],
    );
  }
}
