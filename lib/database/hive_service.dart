// services/hive_service.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/task.dart';
import '../models/settings.dart';

class HiveService {
  static Future<void> init() async {
    try {
      final appDocumentDirectory = 
          await path_provider.getApplicationDocumentsDirectory();
      Hive.init(appDocumentDirectory.path);
  
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SettingsAdapter());
  
      await Hive.openBox<Task>('tasks');
      await Hive.openBox<AppSettings>('settings');
    } catch (e) {
      print("Hive initialization error: $e");
    }
  }


 static Box<Task> getTasksBox() {
    return Hive.box<Task>('tasks'); 
  }
}