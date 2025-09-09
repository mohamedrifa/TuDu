import 'package:flutter/services.dart';

class AlarmPermissionHelper {
  static const _channel = MethodChannel("alarm_permission");

  /// Opens system settings to request Alarm & Reminders permission
  static Future<void> requestAlarmPermission() async {
    await _channel.invokeMethod("requestPermission");
  }

  /// Check if permission is granted
  static Future<bool> hasAlarmPermission() async {
    final result = await _channel.invokeMethod("hasPermission");
    return result == true;
  }
}
