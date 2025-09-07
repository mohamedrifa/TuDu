import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'app_settings_model.dart';

class AppSettingsRepository {
  static const _table = 'app_settings';
  Future<Database> get _db => AppDatabase.instance.database;

  Future<void> _ensureTable() async {
    final db = await _db;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        id INTEGER PRIMARY KEY CHECK (id=1),
        medium_alert_tone TEXT,
        loud_alert_tone TEXT,
        battery_unrestricted INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT
      );
    ''');
    await db.insert('app_settings', {'id': 1},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<AppSettingsDB> get() async {
    await _ensureTable(); // 👈 ensure schema exists
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: const [1],
      limit: 1,
    );
    return rows.isEmpty ? AppSettingsDB.defaults() : AppSettingsDB.fromMap(rows.first);
  }

  Future<void> upsert(AppSettingsDB s) async {
    await _ensureTable(); // 👈 ensure schema exists
    final db = await _db;
    final updated = await db.update(
      _table,
      s.toMap(),
      where: 'id = ?',
      whereArgs: const [1],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (updated == 0) {
      await db.insert(_table, {'id': 1, ...s.toMap()},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> setMediumAlert(String path) async {
    final current = await get();
    await upsert(current.copyWith(mediumAlertTone: path));
  }

  Future<void> setLoudAlert(String path) async {
    final current = await get();
    await upsert(current.copyWith(loudAlertTone: path));
  }

  Future<void> setBatteryUnrestricted(bool v) async {
    final current = await get();
    await upsert(current.copyWith(batteryUnrestricted: v));
  }
}
