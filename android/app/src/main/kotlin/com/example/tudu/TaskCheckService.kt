package com.example.tudu

import android.content.Context
import android.content.Intent
import androidx.core.app.JobIntentService
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale


import android.app.AlarmManager
import android.app.PendingIntent
import android.os.SystemClock
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class TaskCheckService : JobIntentService() {

    companion object {
        private const val JOB_ID = 1001
        fun enqueue(ctx: Context) {
            enqueueWork(ctx, TaskCheckService::class.java, JOB_ID, Intent(ctx, TaskCheckService::class.java))
        }
    }

    override fun onHandleWork(intent: Intent) {
        // Settings analogue (optional)
        val prefs = getSharedPreferences("settings", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("batteryUnrestricted", false)) {
            prefs.edit().putBoolean("batteryUnrestricted", true).apply()
        }

        // === Fetch tasks from SQLite ===
        val repo = KotlinSqliteTaskRepo(MainActivity.dbPathFromDart)
        val tasks: List<TaskRow> = repo.getAll()

        // === Filter like your Dart filteredList() ===
        val filtered: List<TaskRow> = tasks.filter { t: TaskRow ->
            filteredList(
                date = t.date,
                weekDays = t.weekDays,
                isImportant = t.important,
                taskScheduledDate = t.taskScheduledDate
            )
        }

        val timeFmt = SimpleDateFormat("HH:mm", Locale.US)
        val dayFmt = SimpleDateFormat("d EEE MMM yyyy", Locale.US)
        val nowStr: String = timeFmt.format(Date())

        for (task: TaskRow in filtered) {
            // Parse "HH:mm" safely
            val hhmm = task.fromTime.split(":")
            if (hhmm.size != 2) continue
            val h: Int = hhmm[0].toIntOrNull() ?: continue
            val m: Int = hhmm[1].toIntOrNull() ?: continue

            val baseCal = Calendar.getInstance().apply {
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                set(Calendar.HOUR_OF_DAY, h)
                set(Calendar.MINUTE, m)
            }

            val reduced = (baseCal.clone() as Calendar).apply { add(Calendar.MINUTE, -1) }

            // -------- BEFORE --------
            val beforeCal = (reduced.clone() as Calendar).apply {
                when (task.alertBefore) {          // <-- matches DB: alert_before
                    "5 Mins"  -> add(Calendar.MINUTE, -5)
                    "10 Mins" -> add(Calendar.MINUTE, -10)
                    "15 Mins" -> add(Calendar.MINUTE, -15)
                    else -> { /* exactly 'reduced' */ }
                }
            }
            val beforeStr = timeFmt.format(beforeCal.time)
            if (beforeStr == nowStr) {
                val todayStr = dayFmt.format(Date())
                if (!task.taskCompletionDates.contains(todayStr)) {
                    if (task.beforeMediumAlert) {
                        Notifier.show(
                            this,
                            title = "Reminder",
                            text = "Starts soon: ${task.title}",
                            id = 1000 + (task.idBase % 900000)  // stable INT from TEXT id
                        )
                    }
                    if (task.beforeLoudAlert) {
                        Notifier.show(
                            this,
                            title = "Reminder",
                            text = "Loud: ${task.title}",
                            id = 2000 + (task.idBase % 900000)
                        )
                    }
                }
            }

            // -------- AFTER --------
            val afterCal = (reduced.clone() as Calendar).apply {
                when (task.alertAfter) {           // <-- matches DB: alert_after
                    "On Time" -> { /* exactly reduced */ }
                    "5 Mins"  -> add(Calendar.MINUTE, +5)
                    "10 Mins" -> add(Calendar.MINUTE, +10)
                    else -> { /* exactly reduced */ }
                }
            }
            val afterStr = timeFmt.format(afterCal.time)
            if (afterStr == nowStr) {
                val todayStr = dayFmt.format(Date())
                if (!task.taskCompletionDates.contains(todayStr)) {
                    if (task.afterMediumAlert) {
                        Notifier.show(
                            this,
                            title = "Reminder",
                            text = "Now: ${task.title}",
                            id = 3000 + (task.idBase % 900000)
                        )
                    }
                    if (task.afterLoudAlert) {
                        Notifier.show(
                            this,
                            title = "Reminder",
                            text = "Overdue: ${task.title}",
                            id = 4000 + (task.idBase % 900000)
                        )
                    }
                }
            }
        }
    }

    /** Same semantics as your Dart filteredList() */
    private fun filteredList(
        date: String,
        weekDays: List<Boolean>,
        isImportant: Boolean,
        taskScheduledDate: String?
    ): Boolean {
        fun allDaysFalse(days: List<Boolean>) = days.all { !it }

        return if (allDaysFalse(weekDays)) {
            // One-time tasks: compare "d MM yyyy"
            try {
                val fmt = SimpleDateFormat("d MM yyyy", Locale.US)
                val taskDate = fmt.parse(date) ?: return false
                fmt.format(taskDate) == fmt.format(Date())
            } catch (_: Exception) {
                false
            }
        } else {
            // Recurring: today’s weekday (Mon=0..Sun=6)
            val idx = (Calendar.getInstance().get(Calendar.DAY_OF_WEEK) + 5) % 7
            weekDays.getOrNull(idx) == true
        }
    }

    private fun scheduleAlarm() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val triggerAt = SystemClock.elapsedRealtime() + 10_000 // 10 seconds from now
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.ELAPSED_REALTIME_WAKEUP,
            triggerAt,
            pendingIntent
        )
    }
}
