package com.example.tudu

import android.database.sqlite.SQLiteDatabase
import android.util.Log
import java.io.File

object AppSettingsStore {
    private const val TAG = "AppSettingsStore"

    /** Reads app_settings.loud_alert_tone (id = 1). Returns null if missing/empty. */
    fun getLoudTonePath(): String? {
        val dbPath = MainActivity.dbPathFromDart
        if (dbPath.isNullOrBlank()) {
            Log.w(TAG, "DB path from Dart is null/blank.")
            return null
        }
        if (!File(dbPath).exists()) {
            Log.w(TAG, "DB path does not exist: $dbPath")
            return null
        }

        var db: SQLiteDatabase? = null
        var cursor: android.database.Cursor? = null
        return try {
            db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READONLY)
            // reduce lock contention a bit
            db.execSQL("PRAGMA busy_timeout = 3000")

            cursor = db.rawQuery(
                "SELECT loud_alert_tone FROM app_settings WHERE id = 1 LIMIT 1",
                null
            )
            if (cursor.moveToFirst()) {
                val tone = cursor.getString(0)
                tone?.takeIf { it.isNotBlank() }
            } else null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to read loud_alert_tone", e)
            null
        } finally {
            try { cursor?.close() } catch (_: Exception) {}
            try { db?.close() } catch (_: Exception) {}
        }
    }
}
