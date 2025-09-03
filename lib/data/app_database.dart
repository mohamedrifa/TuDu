import 'package:flutter/services.dart';             // 👈 add this
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  // 👇 Channel for sending the DB path to Android/Kotlin
  static const MethodChannel _meta = MethodChannel('app.db.meta');

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'app.db');        // <- this is the file Kotlin should open

    _db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        // journal_mode returns a row; use rawQuery (as you did)
        await db.rawQuery('PRAGMA journal_mode = WAL');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            week_days TEXT NOT NULL,            -- "1010010"
            from_time TEXT NOT NULL,            -- "HH:mm"
            to_time TEXT NOT NULL,              -- "HH:mm"
            tags TEXT NOT NULL,
            important INTEGER NOT NULL DEFAULT 0,
            location TEXT NOT NULL,
            sub_task TEXT NOT NULL,
            before_loud_alert INTEGER NOT NULL DEFAULT 0,
            before_medium_alert INTEGER NOT NULL DEFAULT 0,
            after_loud_alert INTEGER NOT NULL DEFAULT 0,
            after_medium_alert INTEGER NOT NULL DEFAULT 0,
            alert_before TEXT NOT NULL,
            alert_after TEXT NOT NULL,
            task_completion_dates TEXT NOT NULL, -- JSON array
            task_scheduled_date TEXT NOT NULL
          );
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_tasks_from_time ON tasks(from_time);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_tasks_to_time ON tasks(to_time);');
      },
    );

    // ✅ Send the actual DB path to Kotlin, so native code opens the same file
    try {
      await _meta.invokeMethod('dbPath', {'path': _db!.path});
    } catch (_) {
      // Don't crash the app if native side isn't ready yet
    }

    return _db!;
  }

  /// Optional helper if you ever need the path in Dart again
  Future<String> get path async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'app.db');
  }
}
