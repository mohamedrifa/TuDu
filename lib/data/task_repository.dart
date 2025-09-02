import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'task_model.dart';

abstract class TaskRepository {
  Future<List<Task>> getAll(); // ✅ add this
  Future<Task?> getById(String id);
  Future<void> upsert(Task task);
  Future<void> delete(String id);
  Future<List<Task>> getConflictCandidates({
    required String date,
    required String excludeId,
  });
}

class SqliteTaskRepository implements TaskRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  @override
  Future<List<Task>> getAll() async {
    final db = await _dbProvider.database;
    final rows = await db.query('tasks');
    return rows.map(Task.fromMap).toList();
  }

  @override
  Future<Task?> getById(String id) async {
    final db = await _dbProvider.database;
    final rows =
        await db.query('tasks', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Task.fromMap(rows.first);
  }

  @override
  Future<void> upsert(Task task) async {
    final db = await _dbProvider.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbProvider.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Task>> getConflictCandidates({
    required String date,
    required String excludeId,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'tasks',
      where: 'id != ? AND (date = ? OR date = ?)',
      whereArgs: [excludeId, date, "repeat"],
    );
    return rows.map(Task.fromMap).toList();
  }
}
