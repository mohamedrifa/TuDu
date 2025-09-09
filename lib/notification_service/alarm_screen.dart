// ignore_for_file: unused_field
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tudu/notification_service/effect_service.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:tudu/notification_service/notification_service.dart';
import '../models/task.dart';

class AlarmScreen extends StatefulWidget {
  static const MethodChannel _channel = MethodChannel('custom.alarm.channel');
  final String taskId;
  final String message;

  const AlarmScreen({
    super.key,
    required this.taskId,
    required this.message
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late double screenWidth;
  late double screenHeight;
  double elipseWidth = 108.3;
  double elipseHeight = 108.3;
  Color elipseColor = Color.fromARGB(0, 0, 0, 0);
  late Timer _timer;
  bool isExpanded = false;
  bool _launchedFromNotification = false;
  double _volume = 0.5;
  var task;
  final box = Hive.box<Task>('tasks');

  String title = "";
  String prompText = "";
  String timing = "";
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationDetails _simpleNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'simple_channel',
        'General',
        channelDescription: 'Simple notification without actions',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  void GestDetect () {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  Future<void> taskInitialize() async {
    if (!Hive.isBoxOpen('tasks')) {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter()); // 👈 use your Task typeId
      }
      await Hive.openBox<Task>('tasks');
    }
    task = box.get(widget.taskId);
    title = task!.title;
    switch(widget.message) {
      case "5 Minutes to Start ":
        prompText = "5 Minutes to Start";
        break;
      case "10 Minutes to Start ":
        prompText = "10 Minutes to Start";
        break;
      case "15 Minutes to Start ":
        prompText = "15 Minutes to Start";
        break;
      case "Its Time to Start ":
        prompText = "Start Now";
        break;
      case "5 Mins Passed for ":
        prompText = "5 Mins Passed";
        break;
      case "10 Mins Passed for ":
        prompText = "10 Mins Passed";
        break;
      default:
        prompText = "Start Task";
    }


    DateFormat timeFormat = DateFormat("HH:mm");
    DateTime fromTime = timeFormat.parse(task.fromTime);
    DateTime toTime = timeFormat.parse(task.toTime);

    // Convert to 12-hour format with AM/PM
    String formattedFrom = DateFormat("h.mm a").format(fromTime);
    String formattedTo = DateFormat("h.mm a").format(toTime);

    // Replace AM/PM with A.M./P.M.
    formattedFrom = formattedFrom.replaceAll("AM", "A.M").replaceAll("PM", "P.M");
    formattedTo = formattedTo.replaceAll("AM", "A.M").replaceAll("PM", "P.M");

    timing = "$formattedFrom To $formattedTo";
  }


  @override
  void initState() {
    super.initState();
    startElipseAnimation();
    _checkLaunchDetails();

    VolumeController().showSystemUI = false; // 🚫 hide default popup
    VolumeController().getVolume().then((vol) {
      setState(() => _volume = vol);
    });

    VolumeController().listener((vol) {
      setState(() => _volume = vol);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    Future.microtask(() async {
      await taskInitialize();
      setState(() {}); // update UI after task loaded
    });
  }
  Future<void> _checkLaunchDetails() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final details = await plugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      setState(() {
        _launchedFromNotification = true;
      });
    }
  }
  void volumeadjust () {
    VolumeController().setVolume((_volume + 0.1).clamp(0.0, 1.0));
    VolumeController().setVolume((_volume - 0.1).clamp(0.0, 1.0));
    VolumeController().setVolume((_volume + 0.1).clamp(0.0, 1.0));
    VolumeController().setVolume((_volume - 0.1).clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _timer.cancel();
    EffectService().stopEffect();
    VolumeController().removeListener();
    super.dispose();
  }

  void startElipseAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        if (isExpanded) {
          elipseHeight = 108.3;
          elipseWidth = 108.3;
          elipseColor = Colors.transparent;
        } else {
          elipseWidth = 576.67;
          elipseHeight = 833.48;
          elipseColor = Color(0xFF27262B);
        }
        isExpanded = !isExpanded;
      });
    });
  }

  double objHeight(double height) {
    return (height / 917) * screenHeight;
  }
  double objWidth(double Width) {
    return (Width / 412) * screenWidth;
  }

  void handleLater() {
    EffectService().stopEffect();
    volumeadjust();
    FullScreenNotification().cancelById(widget.taskId);
    _timer.cancel();
    if (_launchedFromNotification) {
      SystemNavigator.pop();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> handleGo() async {
    if (task != null) {
      String date =
          DateFormat('d EEE MMM yyyy').format(DateTime.now());
      task.taskCompletionDates.add(date);
      await box.put(widget.taskId, task);

      await notificationPlugin.show(
        9999,
        'Task Started',
        '${task.title} marked as completed!',
        _simpleNotificationDetails(),
      );
    }
    EffectService().stopEffect();
    volumeadjust();
    FullScreenNotification().cancelById(widget.taskId);
    _timer.cancel();
    if (_launchedFromNotification) {
      SystemNavigator.pop();
    } else {
      Navigator.pop(context);
    }
  }

  void handleSkip() {
    EffectService().stopEffect();
    volumeadjust();
    FullScreenNotification().cancelById(widget.taskId);
    _timer.cancel();
    if (_launchedFromNotification) {
      SystemNavigator.pop();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        handleSkip();
        return false;
      }, 
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // No background
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: GestureDetector(
          onTap: () => GestDetect(),
          child: Scaffold(
            backgroundColor: Color(0xFF313036),
            body: Center(
              child: Stack(
                children: [
                  OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: ClipOval(
                      child: AnimatedContainer(
                      duration: const Duration(milliseconds: 3000),
                      curve: Curves.easeInOut,
                        width: objWidth(elipseWidth),
                        height: objHeight(elipseHeight),
                        color: elipseColor,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: objWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: objHeight(67.7)),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/logo.png',
                            width: objWidth(56.03),
                            height: objHeight(22),
                          ),
                        ),
                        SizedBox(height: objHeight(78.01)),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFEBFAF9),
                            fontWeight: FontWeight.w600,
                            fontSize: objWidth(40),
                          ),
                        ),
                        Text(
                          prompText,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFEBFAF9),
                            fontWeight: FontWeight.w600,
                            fontSize: objWidth(32),
                          ),
                        ),
                        SizedBox(height: objHeight(33.92)),
                        Text(
                          timing,
                          style: TextStyle(
                            fontFamily: 'Quantico',
                            color: Color(0xFFEBFAF9),
                            fontWeight: FontWeight.w700,
                            fontSize: objWidth(18),
                          ),
                        ),
                        SizedBox(height: objHeight(395)),
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                color: Color(0xFF1B1A1E),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () => {handleLater()},
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    width: objWidth(170),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Later",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEBFAF9),
                                            fontSize: 24
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Image.asset(
                                          'assets/laterIcon.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ],
                                    ),
                                  )
                                ),
                              ),
                              Material(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                color: Color(0xFF1B1A1E),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () => {handleGo()},
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    width: objWidth(170),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Go",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEBFAF9),
                                            fontSize: 24
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Image.asset(
                                          'assets/goIcon.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ],
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: objHeight(16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Unable To Do Now? ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFFEBFAF9),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => {handleSkip()},
                                child: Text(
                                  "Skip This",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: const Color(0xFF227D7B),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFF227D7B),
                                    decorationStyle: TextDecorationStyle.solid, 
                                  ),
                                ),
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
            ),
          ) 
        ),
      )
    );
  }
}
