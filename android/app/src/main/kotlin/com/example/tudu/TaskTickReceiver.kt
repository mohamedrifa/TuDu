package com.example.tudu

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class TaskTickReceiver : BroadcastReceiver() {

    companion object {
        const val NOTIF_CHANNEL_ID = "task_alerts"

        private fun actionTick(ctx: Context) = "${ctx.packageName}.ACTION_TICK"

        fun pendingIntent(ctx: Context): PendingIntent {
            val i = Intent(ctx, TaskTickReceiver::class.java).setAction(actionTick(ctx))
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
            return PendingIntent.getBroadcast(ctx, MainActivity.ALARM_ID, i, flags)
        }
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != actionTick(context)) return

        TaskCheckService.enqueue(context) // run job now

        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = pendingIntent(context)
        val triggerAt = System.currentTimeMillis() + 60_000L
        val type = if (Build.VERSION.SDK_INT >= 23) AlarmManager.RTC_WAKEUP else AlarmManager.RTC
        if (Build.VERSION.SDK_INT >= 23) {
            am.setExactAndAllowWhileIdle(type, triggerAt, pi)
        } else {
            am.setExact(type, triggerAt, pi)
        }
    }
}
