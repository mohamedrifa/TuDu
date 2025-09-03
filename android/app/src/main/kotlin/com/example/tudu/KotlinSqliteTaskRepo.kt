package com.example.tudu

import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import org.json.JSONArray
import kotlin.math.absoluteValue

data class TaskRow(
    val id: String,
    val title: String,
    val date: String,
    val weekDays: List<Boolean>,   // from "1010010"
    val fromTime: String,
    val toTime: String,
    val tags: String,
    val important: Boolean,
    val location: String,
    val subTask: String,
    val beforeLoudAlert: Boolean,
    val beforeMediumAlert: Boolean,
    val afterLoudAlert: Boolean,
    val afterMediumAlert: Boolean,
    val alertBefore: String,
    val alertAfter: String,
    val taskCompletionDates: List<String>,
    val taskScheduledDate: String
) {
    val idBase: Int = id.hashCode().absoluteValue
}

class KotlinSqliteTaskRepo(private val path: String?) {
    private fun open(): SQLiteDatabase? =
        path?.let { SQLiteDatabase.openDatabase(it, null, SQLiteDatabase.OPEN_READONLY) }

    fun getAll(): List<TaskRow> {
        val db = open() ?: return emptyList()
        db.rawQuery(
            """
            SELECT id, title, date, week_days, from_time, to_time, tags, important, location,
                   sub_task, before_loud_alert, before_medium_alert, after_loud_alert, after_medium_alert,
                   alert_before, alert_after, task_completion_dates, task_scheduled_date
            FROM tasks
            """.trimIndent(),
            null
        ).use { c ->
            val out = mutableListOf<TaskRow>()
            while (c.moveToNext()) out += mapRow(c)
            db.close()
            return out
        }
    }

    private fun Cursor.getStringOr(col: String): String =
        getString(getColumnIndexOrThrow(col))
    private fun Cursor.getIntOrZero(col: String): Int =
        if (isNull(getColumnIndexOrThrow(col))) 0 else getInt(getColumnIndexOrThrow(col))

    private fun parseWeekDays(bits: String): List<Boolean> =
        bits.padEnd(7, '0').take(7).map { it == '1' }

    private fun parseStringArray(json: String): List<String> =
        runCatching {
            val arr = JSONArray(json)
            List(arr.length()) { i -> arr.optString(i) }
        }.getOrElse { emptyList() }

    private fun mapRow(c: Cursor) = TaskRow(
        id = c.getStringOr("id"),
        title = c.getStringOr("title"),
        date = c.getStringOr("date"),
        weekDays = parseWeekDays(c.getStringOr("week_days")),
        fromTime = c.getStringOr("from_time"),
        toTime = c.getStringOr("to_time"),
        tags = c.getStringOr("tags"),
        important = c.getIntOrZero("important") != 0,
        location = c.getStringOr("location"),
        subTask = c.getStringOr("sub_task"),
        beforeLoudAlert = c.getIntOrZero("before_loud_alert") != 0,
        beforeMediumAlert = c.getIntOrZero("before_medium_alert") != 0,
        afterLoudAlert = c.getIntOrZero("after_loud_alert") != 0,
        afterMediumAlert = c.getIntOrZero("after_medium_alert") != 0,
        alertBefore = c.getStringOr("alert_before"),
        alertAfter = c.getStringOr("alert_after"),
        taskCompletionDates = parseStringArray(c.getStringOr("task_completion_dates")),
        taskScheduledDate = c.getStringOr("task_scheduled_date")
    )
}
