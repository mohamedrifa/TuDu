package com.example.tudu

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.tudu.TaskTickReceiver

class MainActivity : FlutterActivity() {

    companion object {
        const val ALARM_ID = 1
        const val CHANNEL_DB_META = "app.db.meta"
        const val CHANNEL_NOTIF = "app.notifications"
        @Volatile var dbPathFromDart: String? = null
        private const val TAG = "TUDU"
    }

    private var waitingForExactPerm = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_DB_META)
            .setMethodCallHandler { call, result ->
                if (call.method == "dbPath") {
                    val path = (call.arguments as? Map<*, *>)?.get("path") as? String
                    dbPathFromDart = path
                    android.util.Log.d(TAG, "MainActivity: received DB path = $path")
                    result.success(null)
                } else result.notImplemented()
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NOTIF)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarmEveryMinute" -> {
                        android.util.Log.d(TAG, "MainActivity: scheduleAlarmEveryMinute() called from Dart")
                        scheduleAlarmEveryMinute(this)
                        result.success(true)
                    }
                    "stopPeriodicAlarm" -> {
                        android.util.Log.d(TAG, "MainActivity: stopPeriodicAlarm() called from Dart")
                        result.success(stopPeriodicAlarm(this))
                    }
                    "runCheckNow" -> {
                        android.util.Log.d(TAG, "MainActivity: runCheckNow() → enqueue TaskCheckService immediately")
                        TaskCheckService.enqueue(applicationContext)
                        result.success(true)
                    }
                    "hasExactAlarm" -> result.success(hasExactAlarmPermission())
                    "openExactAlarmSettings" -> {
                        waitingForExactPerm = true
                        openExactAlarmSettings()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        ensureNotificationChannel(this)
    }

    override fun onResume() {
        super.onResume()
        if (waitingForExactPerm) {
            waitingForExactPerm = false
            val granted = hasExactAlarmPermission()
            android.util.Log.d(TAG, "MainActivity: returned from settings, exact alarm granted = $granted")
            if (granted) scheduleAlarmEveryMinute(this)
        }
    }

    private fun ensureNotificationChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            val nm = NotificationManagerCompat.from(ctx)
            val channel = NotificationChannelCompat.Builder(
                TaskTickReceiver.NOTIF_CHANNEL_ID,
                android.app.NotificationManager.IMPORTANCE_HIGH
            )
                .setName("Task Alerts")
                .setDescription("Before/After task alerts")
                .build()
            nm.createNotificationChannel(channel)
        }
    }

    private fun hasExactAlarmPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= 31) {
            val am = getSystemService(AlarmManager::class.java)
            am.canScheduleExactAlarms()
        } else true
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= 31) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        }
    }

    private fun requestExactAlarmPermissionIfNeeded(): Boolean {
        if (Build.VERSION.SDK_INT >= 31) {
            val am = getSystemService(AlarmManager::class.java)
            if (!am.canScheduleExactAlarms()) {
                waitingForExactPerm = true
                openExactAlarmSettings()
                return false
            }
        }
        return true
    }

    private fun scheduleAlarmEveryMinute(ctx: Context) {
        if (!hasExactAlarmPermission()) {
            if (!requestExactAlarmPermissionIfNeeded()) return
        }
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi: PendingIntent = TaskTickReceiver.pendingIntent(ctx) // explicit type
        val triggerAt = System.currentTimeMillis() + 60_000L
        val type = if (Build.VERSION.SDK_INT >= 23) AlarmManager.RTC_WAKEUP else AlarmManager.RTC
        if (Build.VERSION.SDK_INT >= 23) {
            am.setExactAndAllowWhileIdle(type, triggerAt, pi)
        } else {
            am.setExact(type, triggerAt, pi)
        }
    }

    private fun stopPeriodicAlarm(ctx: Context): Boolean {
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi: PendingIntent = TaskTickReceiver.pendingIntent(ctx) // explicit type
        am.cancel(pi) // resolves overload ambiguity
        return true
    }
}
