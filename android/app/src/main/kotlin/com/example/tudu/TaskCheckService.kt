package com.example.tudu

import android.content.Context
import android.content.Intent
import androidx.core.app.JobIntentService
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean

class TaskCheckService : JobIntentService() {

    companion object {
        private const val JOB_ID = 1001
        private val isRunning = AtomicBoolean(false)

        fun enqueue(ctx: Context) {
            enqueueWork(ctx, TaskCheckService::class.java, JOB_ID,
                Intent(ctx, TaskCheckService::class.java))
        }
    }


    override fun onHandleWork(intent: Intent) {
        if (!isRunning.compareAndSet(false, true)) return
        try {
            runWork()
        } finally {
            isRunning.set(false)
        }
    }

    private fun runWork() {
        val appCtx = applicationContext
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

            val reduced = (baseCal.clone() as Calendar).apply { add(Calendar.MINUTE, 0) }
            var message = "" 
            // -------- BEFORE --------
            val beforeCal = (reduced.clone() as Calendar).apply {
                when (task.alertBefore) {          // <-- matches DB: alert_before
                    "5 Mins"  -> {add(Calendar.MINUTE, -5); message = "5 mins to start"}
                    "10 Mins" -> {add(Calendar.MINUTE, -10); message = "10 mins to start"}
                    "15 Mins" -> {add(Calendar.MINUTE, -15); message = "15 mins to start"}
                    else -> { /* exactly 'reduced' */ }
                }
            }
            val beforeStr = timeFmt.format(beforeCal.time)
            if (beforeStr == nowStr) {
                val todayStr = dayFmt.format(Date())
                if (!task.taskCompletionDates.contains(todayStr)) {
                    if (task.beforeLoudAlert) {
                        FullScreenNotifier.show(
                            ctx = appCtx,
                            title = task.title,
                            text = message,
                            route = "/lockscreen", // or a more specific route if you like
                            extras = mapOf(
                                "alarm_kind" to "before",
                                "task_id" to task.id,
                                "task_title" to task.title
                            ),
                            notifId = 7000 + (task.idBase % 900000),
                            snoozeMinutes = 5
                        )
                    }
                }
            }
            message = ""
            // -------- AFTER --------
            val afterCal = (reduced.clone() as Calendar).apply {
                when (task.alertAfter) {           // <-- matches DB: alert_after
                    "On Time" -> {message = "It's time to start"}
                    "5 Mins"  -> {add(Calendar.MINUTE, +5); message = "5 mins Passed"}
                    "10 Mins" -> {add(Calendar.MINUTE, +10); message = "10 mins Passed"}
                    else -> { /* exactly reduced */ }
                }
            }
            val afterStr = timeFmt.format(afterCal.time)
            if (afterStr == nowStr) {
                val todayStr = dayFmt.format(Date())
                if (!task.taskCompletionDates.contains(todayStr)) {
                    if (task.afterLoudAlert) {
                        FullScreenNotifier.show(
                            ctx = appCtx,
                            title = task.title,
                            text = message,
                            route = "/lockscreen",
                            extras = mapOf(
                                "alarm_kind" to "after",
                                "task_id" to task.id,
                                "task_title" to task.title
                            ),
                            notifId = 8000 + (task.idBase % 900000),
                            snoozeMinutes = 5
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
}
