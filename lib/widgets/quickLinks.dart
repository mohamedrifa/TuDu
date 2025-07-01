// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/hive_service.dart';
import '../models/settings.dart';
import '../models/task.dart';
import 'package:file_selector/file_selector.dart';

class QuickLinks extends StatefulWidget {
  final bool quickLinksEnabled;
  final ValueChanged<bool> onToggle;
  final String showDate;
  final ValueChanged<String> onDateChanged;

  const QuickLinks({
    Key? key,
    required this.quickLinksEnabled,
    required this.onToggle,
    required this.showDate,
    required this.onDateChanged

  }) : super(key: key);

  @override
  _QuickLinksState createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  late bool isEnabled;
  late String selectedDate;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color containerColor = Colors.transparent;
  double rightOffset = -312; // Start off-screen
  String mediumAlertLocation = "";
  String loudAlertLocation = "";
  String mediumAlertName = " Efefjwfgguggkfbgfbggf";
  String loudAlertName = " Efefjwfgguggkfbgfbggf";

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

  @override
  void initState() {
    super.initState();
    isEnabled = widget.quickLinksEnabled;
    selectedDate = widget.showDate;
    // Show panel after short delay
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        containerColor = const Color.fromARGB(69, 0, 0, 0);
        rightOffset = 0;
      });
    });
    if(widget.showDate != "Importants") {
      DateFormat format = DateFormat("d EEE MMM yyyy");
      DateTime dateTime = format.parse(widget.showDate);
      _selectedDay = dateTime;
    } 
  }
  bool isAudioFile(String fileName) {
  final audioExtensions = [
    '.mp3', '.aac', '.wav', '.flac', '.ogg', '.opus', '.m4a', '.amr', '.3gp', '.caf'
  ];
  String lowerFileName = fileName.toLowerCase();
  return audioExtensions.any((ext) => lowerFileName.endsWith(ext));
}
  Future<void> pickMediumAlert() async {
    final XFile? file = await openFile();
    if (file != null) {
      if (!isAudioFile(file.name)) {
        toast("Supported Audio formats:\n"
              ".mp3, .aac, .wav, .flac, .ogg, .opus, .m4a, .amr, .3gp, .caf");
              return;
      }
      final appDocDir = await getApplicationDocumentsDirectory();
      final mediumAlertDir = Directory('${appDocDir.path}/Medium Alert');
      mediumAlertName = " ${file.name}";
      // ✅ Create the directory if it doesn't exist
      if (!await mediumAlertDir.exists()) {
        await mediumAlertDir.create(recursive: true);
      }
      final newFile = File('${mediumAlertDir.path}/${file.name}');
      await File(file.path).copy(newFile.path);
      setState(() {
        mediumAlertLocation = newFile.path;
        print('File saved to: $mediumAlertLocation');
      });
    }
  }

  void setMediumAlert() {
    if (mediumAlertName == " Efefjwfgguggkfbgfbggf") {
      toast("Please Choose a File");
      return;
    }
  
    var settingsBox = Hive.box<AppSettings>('settings');
    AppSettings? currentSettings = settingsBox.get('userSettings');
  
    final updatedSettings = AppSettings(
      mediumAlertTone: mediumAlertLocation,
      loudAlertTone: currentSettings?.loudAlertTone ?? '',
      batteryUnrestricted: currentSettings?.batteryUnrestricted ?? false,
    );

    settingsBox.put('userSettings', updatedSettings);
    toast("Medium Alert Tone is Set");
  }


  Future<void> pickLoudAlert() async {
    final XFile? file = await openFile();
    if (file != null) {
      if (!isAudioFile(file.name)) {
        toast("Supported Audio formats:\n"
              ".mp3, .aac, .wav, .flac, .ogg, .opus, .m4a, .amr, .3gp, .caf");
              return;
      }
      final appDocDir = await getApplicationDocumentsDirectory();
      final loudAlertDir = Directory('${appDocDir.path}/Loud Alert');
      loudAlertName = " ${file.name}";
      // ✅ Ensure the "Loud Alert" directory exists
      if (!await loudAlertDir.exists()) {
        await loudAlertDir.create(recursive: true);
      }
      final newFile = File('${loudAlertDir.path}/${file.name}');
      await File(file.path).copy(newFile.path);
      setState(() {
        loudAlertLocation = newFile.path;
        print('File saved to: $loudAlertLocation');
      });
    }
  }

  void setLoudAlert () {
    if(loudAlertLocation == " Efefjwfgguggkfbgfbggf") {
      toast("Please Choose a File");
      return;
    }
    var settingsBox = Hive.box<AppSettings>('settings');
    AppSettings? currentSettings = settingsBox.get('userSettings');
    // Fallback for when no settings exist yet
    final updatedSettings = AppSettings(
      mediumAlertTone: currentSettings?.mediumAlertTone ?? '',
      loudAlertTone: loudAlertLocation,
      batteryUnrestricted: currentSettings?.batteryUnrestricted ?? false,
    );
    settingsBox.put('userSettings', updatedSettings);
    toast("Loud Alert Tone is Set");
  }

  void _toggleQuickLinks() {
    if (!mounted) return;
    setState(() {
      isEnabled = !isEnabled;
    });
    widget.onToggle(isEnabled);
  }

  bool isExpanded = false;
  void setShowDate(String date) {
    if (!mounted) return;
    widget.onDateChanged(date);
    
    if(!isExpanded) {
      setState(() {
        containerColor = Colors.transparent;
        rightOffset = -312; // Slide out
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _toggleQuickLinks();
      });
    }
    
  }
  
  bool allDaysFalse(List weekDays) {
    for (var day in weekDays) {
      if (day) return false;
    }
    return true;
  }
  bool filteredList(String date, List weekDays, bool isImportant) {
    if (widget.showDate == "Importants") {
      return isImportant;
    } else if (allDaysFalse(weekDays)) {
      DateFormat inputFormat = DateFormat("d MM yyyy");
      DateTime parsedDate = inputFormat.parse(date);
      String formattedDate = DateFormat('d EEE MMM yyyy').format(parsedDate);
      return widget.showDate == formattedDate;
    } else {
      DateTime parsedDate = DateFormat("d EEE MMM yyyy").parse(widget.showDate);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background tap closes panel
        GestureDetector(
          onTap: () {
            if (!mounted) return;
            setState(() {
              containerColor = Colors.transparent;
              rightOffset = -312; // Slide out
            });
            // Wait for animation to finish
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              _toggleQuickLinks();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: double.infinity,
            color: containerColor,
          ),
        ),
        // Sliding panel
        AnimatedPositioned(
          key: const ValueKey('quickLinksPanel'),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          right: rightOffset,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: 312,
            decoration: BoxDecoration(
              color: const Color(0xFF313036),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ), 
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 82),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Links",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: const Color(0xFFFED289),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFFED289),
                        decorationStyle: TextDecorationStyle.solid, 
                      ),
                    ),
                    const SizedBox(height: 24),
                    Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => {
                          setShowDate("Importants")
                        },
                        child: Text(
                          "Important",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: const Color(0xFFFED289),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Task On Other Days",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: const Color(0xFFFED289),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          String formatted = DateFormat('d MM yyyy').format(_selectedDay ?? selectedDay);
                          setShowDate(formatted);
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFFFED289),
                          shape: BoxShape.circle, 
                        ),
                        selectedTextStyle: TextStyle(
                          color: Colors.black, // Sunday date color
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          fontFamily: 'Quantico',
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.white30,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.white, // Sunday date color
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          fontFamily: 'Quantico',
                        ),
                        
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextFormatter: (date, locale) =>
                            '${DateFormat.MMM(locale).format(date).toUpperCase()} ${date.year}',
                        titleTextStyle: TextStyle(
                          color: Color(0xFFEBFAF9),
                          fontFamily: 'Quantico', // Your chosen font
                          fontWeight: FontWeight.bold,
                          fontSize: 20, // Customize as needed
                          letterSpacing: 1.5,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          final text = DateFormat.E().format(day);
                          if (day.weekday == DateTime.sunday) {
                            return Center(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 168, 55, 55), // Your custom Sunday color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else if (day.weekday == DateTime.saturday) {
                            return Center(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Colors.white54, // Your custom Sunday color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Color(0xFFEBFAF9), // Your custom Sunday color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          if (day.weekday == DateTime.sunday) {
                            return Center(
                              child: Container(
                                width: 23,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 171, 86, 86), // Sunday date color
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Quantico',
                                  ),
                                ),
                              ),
                            );
                          } else if(day.weekday == DateTime.saturday) {
                            return Center(
                              child: Container(
                                width: 23,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Quantico',
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: Container(
                                width: 23,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Color(0xFFEBFAF9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Quantico',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: Color(0xFF268D8C),
                        iconColor: Color(0xFF268D8C),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        title: Text(
                          "Total Hours Of Tasks",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xFFFED289),
                          ),
                        ),
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            isExpanded = expanded;
                          });
                        },
                        children: [
                          buildHourTasks()
                        ],
                      ),
                    ),
                    const SizedBox(height: 71.92,),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Color(0xFFFFFFFF),
                    ),
                    const SizedBox(height: 9.08,),
                    Text(
                      "Notification Tone",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: const Color(0xFFFED289),
                      ),
                    ),
                    const SizedBox(height:24),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 8.24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage('assets/mediumAlertOn.png'),
                                width: 35,
                                height: 35,
                              ),
                              const SizedBox(width:12),
                              Text(
                                "Medium Alert",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFEBFAF9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                ),
                              ),
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF268D8C),
                                child: InkWell(
                                  onTap: () => {
                                    setMediumAlert()
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    child: Text(
                                      "Set",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF0D0C10),
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/tone.png"),
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 3),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:() => {
                                    pickMediumAlert()
                                  },
                                  child: Container(
                                    width: 183.97,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border(
                                        left: BorderSide(color: Colors.white, width: 1.0),
                                        right: BorderSide(color: Colors.white, width: 1.0),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        mediumAlertName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                          color: Color(0xFFEBFAF9),
                                        ),
                                      ),
                                    ),
                                  )

                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 23),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage('assets/loudAlertOn.png'),
                                width: 35,
                                height: 35,
                              ),
                              const SizedBox(width:12),
                              Text(
                                "Loud Alert",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFEBFAF9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                ),
                              ),
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF268D8C),
                                child: InkWell(
                                  onTap: () => {
                                    setLoudAlert()
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    child: Text(
                                      "Set",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF0D0C10),
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/tone.png"),
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 3),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:() => {
                                    pickLoudAlert()
                                  },
                                  child: Container(
                                    width: 183.97,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border(
                                        left: BorderSide(color: Colors.white, width: 1.0),
                                        right: BorderSide(color: Colors.white, width: 1.0),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        loudAlertName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                          color: Color(0xFFEBFAF9),
                                        ),
                                      ),
                                    ),
                                  )

                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      
                    )
                  ],
                ),
              ),
            ) 
          ),
        ),
      ],
    );
  }

  Widget buildHourTasks() {
    final tasksBox = HiveService.getTasksBox();
    final tasks = tasksBox.values.toList();
    final filteredTasks = <Task>[];
    for (var task in tasks) {
      if (filteredList(task.date, task.weekDays, task.important)) {
        filteredTasks.add(task);
      }
    }
    // ignore: non_constant_identifier_names
    Duration Upskill = Duration.zero;
    Duration Work = Duration.zero;
    Duration Personal = Duration.zero;
    Duration Health = Duration.zero;
    Duration Exercise = Duration.zero;
    Duration Social = Duration.zero;
    Duration Spiritual = Duration.zero;
    Duration Finance = Duration.zero;
    Duration Others = Duration.zero;
    Duration totalDuration = Duration.zero;
    for (var task in filteredTasks) {
        String fromTimeStr = task.fromTime; // 2:30 PM
        String toTimeStr = task.toTime;   // 6:15 PM
        // Convert to DateTime objects (same date, only time matters)
        DateTime fromTime = DateTime.parse("2025-01-01 $fromTimeStr:00");
        DateTime toTime = DateTime.parse("2025-01-01 $toTimeStr:00");
        // Calculate the difference
        Duration difference = toTime.difference(fromTime);
        totalDuration += difference;
        switch(task.tags) {
          case "Upskill": 
            Upskill += difference;
            break;
          case "Work":
            Work += difference;
            break;
          case "Personal":
            Personal += difference;
            break;
          case "Health":
            Health += difference;
            break;
          case "Exercise":
            Exercise += difference;
            break;
          case "Social":
            Social += difference;
            break;
          case "Spiritual":
            Spiritual += difference;
            break;
          case "Finance":
            Finance += difference;
            break;
          default:
            Others += difference;
        }
    }
    double hours = totalDuration.inHours + (totalDuration.inMinutes.remainder(60) / 100);
    String total = hours % 1 == 0 ? hours.toInt().toString() : hours.toStringAsFixed(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(Upskill != Duration.zero) 
          buildTagHour("Upskill", Upskill),
        if(Work != Duration.zero) 
          buildTagHour("Work", Work),
        if(Personal != Duration.zero) 
          buildTagHour("Personal", Personal),
        if(Health != Duration.zero) 
          buildTagHour("Health", Health),
        if(Exercise != Duration.zero) 
          buildTagHour("Exercise", Exercise),
        if(Social != Duration.zero) 
          buildTagHour("Social", Social),
        if(Spiritual != Duration.zero) 
          buildTagHour("Spiritual", Spiritual),
        if(Finance != Duration.zero) 
          buildTagHour("Finance", Finance),
        if(Others != Duration.zero) 
          buildTagHour("Others", Others),
        if(totalDuration != Duration.zero) 
        Row(
          children: [
            Text(
              "Total",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Color(0xFFFED289),
              ),
            ),
            Expanded(child: SizedBox(height: 27)),
            Text(
              total,
              style: TextStyle(
                fontFamily: 'Quantico',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Color(0xFFFED289),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Hours",
              style: TextStyle(
                fontFamily: 'Quantico',
                fontWeight: FontWeight.w300,
                fontSize: 18,
                color: Color(0xFFFED289),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTagHour(String tag, Duration time) {
    double hours = time.inHours + (time.inMinutes.remainder(60) / 100);
    String result = hours % 1 == 0 ? hours.toInt().toString() : hours.toStringAsFixed(2);
    return Column(
      children: [
        Row(
          children: [
            Text(
              tag,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Color(0xFFEBFAF9),
              ),
            ),
            Expanded(child: SizedBox(height: 27)),
            Text(
              result,
              style: TextStyle(
                fontFamily: 'Quantico',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Color(0xFFEBFAF9),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Hours",
              style: TextStyle(
                fontFamily: 'Quantico',
                fontWeight: FontWeight.w300,
                fontSize: 18,
                color: Color(0xFFEBFAF9),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }

}
