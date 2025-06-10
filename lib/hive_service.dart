// services/hive_service.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/task.dart';

class HiveService {
  static Future<void> init() async {
    final appDocumentDirectory = 
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasks');
  }

 static Box<Task> getTasksBox() {
    return Hive.box<Task>('tasks'); 
  }
}