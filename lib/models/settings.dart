// models/task.dart
import 'package:hive/hive.dart';
part 'settings.g.dart'; // This will be generated

@HiveType(typeId: 1)
class AppSettings {
  @HiveField(0)
  String mediumAlertTone;

   @HiveField(1)
  String loudAlertTone;

  AppSettings({
  required this.mediumAlertTone,
  required this.loudAlertTone
});

  get tagname => null;

}