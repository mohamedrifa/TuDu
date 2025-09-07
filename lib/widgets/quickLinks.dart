// ignore: file_names
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:file_selector/file_selector.dart';

// ✅ SQLite-backed Task & Repository
import '../data/task_model.dart';
import '../data/task_repository.dart';

// ✅ SQLite-backed AppSettings
import '../data/app_settings_repository.dart';

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
  final AudioPlayer player = AudioPlayer();
  Color containerColor = Colors.transparent;
  double rightOffset = -312; // Start off-screen

  // ===== AppSettings (SQLite) state =====
  late final AppSettingsRepository _settingsRepo;
  String mediumAlertLocation = "";
  String loudAlertLocation = "";
  String mediumAlertName = " Efefjwfgguggkfbgfbggf";
  String loudAlertName = " Efefjwfgguggkfbgfbggf";

  // ===== Tasks (SQLite) =====
  late final TaskRepository _repo;
  List<Task> _allTasks = [];
  bool _loadingTasks = true;

  void toast (String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
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

    // panel slide-in
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        containerColor = const Color.fromARGB(69, 0, 0, 0);
        rightOffset = 0;
      });
    });

    // set calendar selection from incoming showDate
    if (widget.showDate != "Importants") {
      final format = DateFormat("d EEE MMM yyyy");
      final dateTime = format.parse(widget.showDate);
      _selectedDay = dateTime;
    }

    // load AppSettings (SQLite)
    _settingsRepo = AppSettingsRepository();
    _loadSettings();

    // load tasks from SQLite
    _repo = SqliteTaskRepository();
    _loadTasks();
  }

  Future<void> _loadSettings() async {
    final s = await _settingsRepo.get();
    if (!mounted) return;
    setState(() {
      mediumAlertLocation = s.mediumAlertTone;
      loudAlertLocation = s.loudAlertTone;
      if (s.mediumAlertTone.isNotEmpty) {
        mediumAlertName = " ${p.basename(s.mediumAlertTone)}";
      }
      if (s.loudAlertTone.isNotEmpty) {
        loudAlertName = " ${p.basename(s.loudAlertTone)}";
      }
    });
  }

  Future<void> _loadTasks() async {
    setState(() => _loadingTasks = true);
    final tasks = await _repo.getAll();
    if (!mounted) return;
    setState(() {
      _allTasks = tasks;
      _loadingTasks = false;
    });
  }

  bool isAudioFile(String fileName) {
    final audioExtensions = [
      '.mp3', '.aac', '.wav', '.flac', '.ogg', '.opus', '.m4a', '.amr', '.3gp', '.caf'
    ];
    final lowerFileName = fileName.toLowerCase();
    return audioExtensions.any((ext) => lowerFileName.endsWith(ext));
  }

  Future<void> pickMediumAlert() async {
    await player.stop();
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
      if (!await mediumAlertDir.exists()) {
        await mediumAlertDir.create(recursive: true);
      }
      final newFile = File('${mediumAlertDir.path}/${file.name}');
      await File(file.path).copy(newFile.path);
      setState(() {
        mediumAlertLocation = newFile.path;
      });
      await player.play(DeviceFileSource(mediumAlertLocation));
    }
  }

  Future<void> setMediumAlert() async {
    player.stop();
    if (mediumAlertName == " Efefjwfgguggkfbgfbggf") {
      toast("Please Choose a File");
      return;
    }
    await _settingsRepo.setMediumAlert(mediumAlertLocation);
    await _loadSettings();
    toast("Medium Alert Tone is Set");
  }

  Future<void> pickLoudAlert() async {
    await player.stop();
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
      if (!await loudAlertDir.exists()) {
        await loudAlertDir.create(recursive: true);
      }
      final newFile = File('${loudAlertDir.path}/${file.name}');
      await File(file.path).copy(newFile.path);
      setState(() {
        loudAlertLocation = newFile.path;
      });
      await player.play(DeviceFileSource(loudAlertLocation));
    }
  }

  Future<void> setLoudAlert () async {
    player.stop();
    if (loudAlertName == " Efefjwfgguggkfbgfbggf") {
      toast("Please Choose a File");
      return;
    }
    await _settingsRepo.setLoudAlert(loudAlertLocation);
    await _loadSettings();
    toast("Loud Alert Tone is Set");
  }

  void _toggleQuickLinks () {
    player.stop();
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

    if (!isExpanded) {
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
      final inputFormat = DateFormat("d MM yyyy");
      final parsedDate = inputFormat.parse(date);
      final formattedDate = DateFormat('d EEE MMM yyyy').format(parsedDate);
      return widget.showDate == formattedDate;
    } else {
      final parsedDate = DateFormat("d EEE MMM yyyy").parse(widget.showDate);
      final formattedDay = DateFormat('EEE').format(parsedDate);
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
        GestureDetector(
          onTap: () {
            if (!mounted) return;
            setState(() {
              containerColor = Colors.transparent;
              rightOffset = -312; // Slide out
            });
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

        AnimatedPositioned(
          key: const ValueKey('quickLinksPanel'),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          right: rightOffset,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: 312,
            decoration: const BoxDecoration(
              color: Color(0xFF313036),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 82),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Links",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFFFED289),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFFED289),
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => setShowDate("Importants"),
                        child: const Text(
                          "Important",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xFFFED289),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Task On Other Days",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFFFED289),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        player.stop();
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          final formatted = DateFormat('d MM yyyy').format(_selectedDay ?? selectedDay);
                          setShowDate(formatted);
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFFFED289),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          fontFamily: 'Quantico',
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.white30,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.white,
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
                        titleTextStyle: const TextStyle(
                          color: Color(0xFFEBFAF9),
                          fontFamily: 'Quantico',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.5,
                        ),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          final text = DateFormat.E().format(day);
                          if (day.weekday == DateTime.sunday) {
                            return Center(
                              child: Text(text, style: const TextStyle(color: Color.fromARGB(255, 168, 55, 55), fontWeight: FontWeight.bold)),
                            );
                          } else if (day.weekday == DateTime.saturday) {
                            return const Center(
                              child: Text('Sat', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                            );
                          } else {
                            return Center(
                              child: Text(
                                text,
                                style: const TextStyle(color: Color(0xFFEBFAF9), fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          final color = day.weekday == DateTime.sunday
                              ? const Color.fromARGB(255, 171, 86, 86)
                              : (day.weekday == DateTime.saturday ? Colors.white70 : const Color(0xFFEBFAF9));
                          return Center(
                            child: Container(
                              width: 23,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Quantico',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: const Color(0xFF268D8C),
                        iconColor: const Color(0xFF268D8C),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        title: const Text(
                          "Total Hours Of Tasks",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xFFFED289),
                          ),
                        ),
                        onExpansionChanged: (bool expanded) {
                          player.stop();
                          setState(() {
                            isExpanded = expanded;
                          });
                          if (expanded) {
                            // refresh tasks when opening the section
                            _loadTasks();
                          }
                        },
                        children: [
                          _loadingTasks
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : buildHourTasks(), // uses SQLite tasks
                        ],
                      ),
                    ),
                    const SizedBox(height: 71.92),
                    Container(width: double.infinity, height: 1, color: const Color(0xFFFFFFFF)),
                    const SizedBox(height: 9.08),
                    const Text(
                      "Notification Tone",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFFFED289),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ===== Medium Alert (SQLite) =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 8.24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Image(image: AssetImage('assets/mediumAlertOn.png'), width: 35, height: 35),
                              const SizedBox(width: 12),
                              const Text(
                                "Medium Alert",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFEBFAF9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              const Expanded(child: SizedBox(height: 40)),
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFF268D8C),
                                child: InkWell(
                                  onTap: setMediumAlert,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    child: const Text(
                                      "Set",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF0D0C10),
                                        fontSize: 16,
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
                              const Image(image: AssetImage("assets/tone.png"), width: 24, height: 24),
                              const SizedBox(width: 3),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: pickMediumAlert,
                                  child: Container(
                                    width: 183.97,
                                    height: 30,
                                    decoration: const BoxDecoration(
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
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                          color: Color(0xFFEBFAF9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 23),
                          // ===== Loud Alert (SQLite) =====
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Image(image: AssetImage('assets/loudAlertOn.png'), width: 35, height: 35),
                              const SizedBox(width: 12),
                              const Text(
                                "Loud Alert",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFEBFAF9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              const Expanded(child: SizedBox(height: 40)),
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFF268D8C),
                                child: InkWell(
                                  onTap: setLoudAlert,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    child: const Text(
                                      "Set",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF0D0C10),
                                        fontSize: 16,
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
                              const Image(image: AssetImage("assets/tone.png"), width: 24, height: 24),
                              const SizedBox(width: 3),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: pickLoudAlert,
                                  child: Container(
                                    width: 183.97,
                                    height: 30,
                                    decoration: const BoxDecoration(
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
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                          color: Color(0xFFEBFAF9),
                                        ),
                                      ),
                                    ),
                                  ),
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
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the "Total Hours Of Tasks" section using SQLite data.
  Widget buildHourTasks() {
    final filteredTasks = _allTasks.where((task) {
      return filteredList(task.date, task.weekDays, task.important);
    }).toList();

    // Buckets by tag
    Duration upskill = Duration.zero;
    Duration work = Duration.zero;
    Duration personal = Duration.zero;
    Duration health = Duration.zero;
    Duration exercise = Duration.zero;
    Duration social = Duration.zero;
    Duration spiritual = Duration.zero;
    Duration finance = Duration.zero;
    Duration others = Duration.zero;
    Duration totalDuration = Duration.zero;

    for (final task in filteredTasks) {
      final fromTime = DateTime.parse("2025-01-01 ${task.fromTime}:00");
      final toTime = DateTime.parse("2025-01-01 ${task.toTime}:00");
      final diff = toTime.difference(fromTime);
      totalDuration += diff;

      switch (task.tags) {
        case "Upskill":   upskill += diff; break;
        case "Work":      work += diff; break;
        case "Personal":  personal += diff; break;
        case "Health":    health += diff; break;
        case "Exercise":  exercise += diff; break;
        case "Social":    social += diff; break;
        case "Spiritual": spiritual += diff; break;
        case "Finance":   finance += diff; break;
        default:          others += diff;
      }
    }

    double hours = totalDuration.inHours + (totalDuration.inMinutes.remainder(60) / 100);
    String total = hours % 1 == 0 ? hours.toInt().toString() : hours.toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (upskill != Duration.zero) buildTagHour("Upskill", upskill),
        if (work != Duration.zero) buildTagHour("Work", work),
        if (personal != Duration.zero) buildTagHour("Personal", personal),
        if (health != Duration.zero) buildTagHour("Health", health),
        if (exercise != Duration.zero) buildTagHour("Exercise", exercise),
        if (social != Duration.zero) buildTagHour("Social", social),
        if (spiritual != Duration.zero) buildTagHour("Spiritual", spiritual),
        if (finance != Duration.zero) buildTagHour("Finance", finance),
        if (others != Duration.zero) buildTagHour("Others", others),
        if (totalDuration != Duration.zero)
          Row(
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Color(0xFFFED289),
                ),
              ),
              const Expanded(child: SizedBox(height: 27)),
              Text(
                total,
                style: const TextStyle(
                  fontFamily: 'Quantico',
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Color(0xFFFED289),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
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
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Color(0xFFEBFAF9),
              ),
            ),
            const Expanded(child: SizedBox(height: 27)),
            Text(
              result,
              style: const TextStyle(
                fontFamily: 'Quantico',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Color(0xFFEBFAF9),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
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
        const SizedBox(height: 8),
      ],
    );
  }
}
