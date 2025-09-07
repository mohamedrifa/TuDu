import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:tudu/models/settings.dart';
import 'package:tudu/notification_service/notification_service.dart';
import 'package:vibration/vibration.dart';
import 'package:volume_controller/volume_controller.dart';

class AlarmScreen extends StatefulWidget {
  static const MethodChannel _channel = MethodChannel('custom.alarm.channel');
  final String title;
  final String description;
  final String buttonText;

  const AlarmScreen({
    super.key,
    required this.title,
    required this.description,
    this.buttonText = 'Dismiss',
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
  final AudioPlayer player = AudioPlayer();

  String title = "Read Novel";
  String prompText = "Start Now";
  String timing = "6.00 A.M To 7.00 A.M";
  
  Timer? vibrationTimer;
  bool _listening = false;

  Future<void> dismissAlarm() async {
    try {
      await AlarmScreen._channel.invokeMethod('close');
    } catch (e) {
      print('❌ Failed to call native alarm: $e');
    }
    SystemNavigator.pop();
  }

  void GestDetect () {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  void startRepeatedVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 1000], // vibrate, pause, vibrate, pause
          repeat: 0, // repeat indefinitely from index 0
      );
    }
  }

  void _startListening() {
    if (!_listening) {
      VolumeController().listener((volume) {
        stopEffect();
        setState(() {
          // _buttonPressed = 'Volume button pressed!';
        });
      });
      _listening = true;
    }
  }

  void stopEffect() {
    Vibration.cancel();
    player.stop();
  }

  Future<void> ringtoneHandler() async {
    if (Hive.isBoxOpen('settings')) {
      await Hive.box<AppSettings>('settings').close();
    }
    final settingsBox = await Hive.openBox<AppSettings>('settings');
    final userSettings = settingsBox.get('userSettings');
    final tonePath = userSettings?.loudAlertTone;
    startRepeatedVibration();
    await player.setReleaseMode(ReleaseMode.loop);
    if (tonePath != null && tonePath.isNotEmpty) {
      await player.play(DeviceFileSource(tonePath));
    } else {
      await player.play(AssetSource('audio/loud.mp3'));
    }
  }


  @override
  void initState() {
    super.initState();
    startElipseAnimation();
    
    // ringtoneHandler();
    // _startListening();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }
  @override
  void dispose() {
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
    FullScreenNotification().stopAlarm();
    Navigator.pop(context);
  }

  void handleGo() {
    FullScreenNotification().stopAlarm();
    // Continue task flow...
  }

  void handleSkip() {
    FullScreenNotification().stopAlarm();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        dismissAlarm();
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
