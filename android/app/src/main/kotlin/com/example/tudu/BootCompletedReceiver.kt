package com.example.tudu

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationManagerCompat

class BootCompletedReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return

        // Accept normal boot and (optionally) direct-boot
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            (Build.VERSION.SDK_INT < 24 || action != Intent.ACTION_LOCKED_BOOT_COMPLETED)
        ) return

        ensureNotificationChannel(context)

        // Re-arm the first minute-tick; TaskTickReceiver will self-reschedule thereafter
        val am = context.getSystemService(AlarmManager::class.java)
        if (Build.VERSION.SDK_INT < 31 || am.canScheduleExactAlarms()) {
            val pi = TaskTickReceiver.pendingIntent(context)
            val triggerAt = System.currentTimeMillis() + 60_000L
            val type = if (Build.VERSION.SDK_INT >= 23) AlarmManager.RTC_WAKEUP else AlarmManager.RTC
            if (Build.VERSION.SDK_INT >= 23) {
                am.setExactAndAllowWhileIdle(type, triggerAt, pi)
            } else {
                am.setExact(type, triggerAt, pi)
            }
        } else {
            android.util.Log.w("TUDU", "BootCompletedReceiver: cannot schedule exact alarms on API 31+")
        }
    }

    private fun ensureNotificationChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val ch = NotificationChannel(
                TaskTickReceiver.NOTIF_CHANNEL_ID,
                "Task Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Before/After task alerts"
            }
            nm.createNotificationChannel(ch)
        }
    }
}
