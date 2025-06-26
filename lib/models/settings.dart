// models/task.dart
import 'package:hive/hive.dart';
part 'settings.g.dart'; // This will be generated

@HiveType(typeId: 1)
class AppSettings {
  @HiveField(0)
  String mediumAlertTone;

   @HiveField(1)
  String loudAlertTone;

  @HiveField(2)
  bool batteryUnrestricted;

  AppSettings({
  required this.mediumAlertTone,
  required this.loudAlertTone,
  required this.batteryUnrestricted
});

  get tagname => null;

}