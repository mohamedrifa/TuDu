import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:volume_controller/volume_controller.dart';

import '../data/app_database.dart';
import '../data/app_settings_model.dart';
import '../data/app_settings_repository.dart';

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

class _AlarmScreenState extends State<AlarmScreen> with WidgetsBindingObserver {
  // Constants
  static const String _defaultAlarmSound = 'audio/loud.mp3';
  static const Duration _animationDuration = Duration(seconds: 3);
  static const List<int> _vibrationPattern = [500, 1000, 500, 1000];
  
  // Screen dimensions
  late double screenWidth;
  late double screenHeight;
  
  // Animation properties
  double elipseWidth = 108.3;
  double elipseHeight = 108.3;
  Color elipseColor = const Color.fromARGB(0, 0, 0, 0);
  bool isExpanded = false;
  
  // Timers and controllers
  Timer? _animationTimer;
  Timer? _vibrationTimer;
  
  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  
  // Volume listening
  bool _listening = false;
  
  // Display data
  String title = "Read Novel";
  String promptText = "Start Now";
  String timing = "6.00 A.M To 7.00 A.M";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAlarm();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Keep alarm playing even when app goes to background
    } else if (state == AppLifecycleState.resumed) {
      // Ensure alarm is still playing when app comes back
      if (!_isAudioPlaying) {
        _playAlarmSound();
      }
    }
  }

  void _initializeAlarm() {
    _setSystemUIMode();
    _startElipseAnimation();
    _startVolumeListener();
    _playAlarmWithVibration();
  }

  void _cleanupResources() {
    _animationTimer?.cancel();
    _vibrationTimer?.cancel();
    _stopAllEffects();
    _audioPlayer.dispose();
    VolumeController().removeListener();
  }

  void _setSystemUIMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, 
      overlays: [SystemUiOverlay.top]
    );
  }

  Future<void> dismissAlarm() async {
    try {
      await AlarmScreen._channel.invokeMethod('close');
    } catch (e) {
      debugPrint('❌ Failed to call native alarm: $e');
    }
    SystemNavigator.pop();
  }

  void _startVolumeListener() {
    if (!_listening) {
      VolumeController().listener((volume) {
        _stopAllEffects();
        setState(() {
          // Volume button pressed - stop alarm
        });
      });
      _listening = true;
    }
  }

  void _startRepeatedVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(
        pattern: _vibrationPattern,
        repeat: 0, // repeat indefinitely from index 0
      );
    }
  }

  void _stopAllEffects() {
    Vibration.cancel();
    _audioPlayer.stop();
    _isAudioPlaying = false;
  }

  Future<void> _playAlarmSound() async {
    try {
      // Set audio context for alarm
      await _audioPlayer.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ));

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0); // Maximum volume
      
      // Try to get user's custom tone first
      String? tonePath = await _getUserAlarmTone();
      
      if (tonePath != null && tonePath.isNotEmpty) {
        await _audioPlayer.play(DeviceFileSource(tonePath));
        debugPrint('✅ Playing custom alarm tone: $tonePath');
      } else {
        await _audioPlayer.play(AssetSource(_defaultAlarmSound));
        debugPrint('✅ Playing default alarm tone');
      }
      
      _isAudioPlaying = true;
      
    } catch (e) {
      debugPrint('❌ Error playing alarm sound: $e');
      // Fallback to asset sound
      try {
        await _audioPlayer.play(AssetSource(_defaultAlarmSound));
        _isAudioPlaying = true;
        debugPrint('✅ Playing fallback alarm tone');
      } catch (fallbackError) {
        debugPrint('❌ Even fallback audio failed: $fallbackError');
      }
    }
  }

  Future<String?> _getUserAlarmTone() async {
    try {
      await AppDatabase.instance.database;
      final settingsRepo = AppSettingsRepository();
      AppSettingsDB userSettings = await settingsRepo.get();
      return userSettings.loudAlertTone;
    } catch (e) {
      debugPrint('❌ Error loading user settings: $e');
      return null;
    }
  }

  Future<void> _playAlarmWithVibration() async {
    _startRepeatedVibration();
    await _playAlarmSound();
  }

  void _startElipseAnimation() {
    _animationTimer = Timer.periodic(_animationDuration, (timer) {
      if (mounted) {
        setState(() {
          if (isExpanded) {
            elipseHeight = 108.3;
            elipseWidth = 108.3;
            elipseColor = Colors.transparent;
          } else {
            elipseWidth = 576.67;
            elipseHeight = 833.48;
            elipseColor = const Color(0xFF27262B);
          }
          isExpanded = !isExpanded;
        });
      }
    });
  }

  double _objHeight(double height) {
    return (height / 917) * screenHeight;
  }

  double _objWidth(double width) {
    return (width / 412) * screenWidth;
  }

  void _handleGo() {
    _stopAllEffects();
    // Add your "Go" logic here
    dismissAlarm();
  }

  void _handleLater() {
    _stopAllEffects();
    // Add your "Later" logic here
    dismissAlarm();
  }

  void _handleSkip() {
    _stopAllEffects();
    // Add your "Skip" logic here
    dismissAlarm();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          dismissAlarm();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: GestureDetector(
          onTap: _setSystemUIMode,
          child: Scaffold(
            backgroundColor: const Color(0xFF313036),
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
                        width: _objWidth(elipseWidth),
                        height: _objHeight(elipseHeight),
                        color: elipseColor,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: _objWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: _objHeight(67.7)),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/logo.png',
                            width: _objWidth(56.03),
                            height: _objHeight(22),
                          ),
                        ),
                        SizedBox(height: _objHeight(78.01)),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFFEBFAF9),
                            fontWeight: FontWeight.w600,
                            fontSize: _objWidth(40),
                          ),
                        ),
                        Text(
                          promptText,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFFEBFAF9),
                            fontWeight: FontWeight.w600,
                            fontSize: _objWidth(32),
                          ),
                        ),
                        SizedBox(height: _objHeight(33.92)),
                        Text(
                          timing,
                          style: TextStyle(
                            fontFamily: 'Quantico',
                            color: const Color(0xFFEBFAF9),
                            fontWeight: FontWeight.w700,
                            fontSize: _objWidth(18),
                          ),
                        ),
                        SizedBox(height: _objHeight(395)),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildActionButton(
                                text: "Later",
                                iconPath: 'assets/laterIcon.png',
                                onTap: _handleLater,
                              ),
                              _buildActionButton(
                                text: "Go",
                                iconPath: 'assets/goIcon.png',
                                onTap: _handleGo,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _objHeight(16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
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
                                onTap: _handleSkip,
                                child: const Text(
                                  "Skip This",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF227D7B),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF227D7B),
                                    decorationStyle: TextDecorationStyle.solid,
                                  ),
                                ),
                              ),
                            ),
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
    );
  }

  Widget _buildActionButton({
    required String text,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: const Color(0xFF1B1A1E),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: _objWidth(170),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEBFAF9),
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(
                iconPath,
                width: 30,
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}