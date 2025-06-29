import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alarm, size: 100, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => {
                    dismissAlarm(),
                  },
                  child: Text(widget.buttonText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          ) 
        ),
      )
    );
  }
}
