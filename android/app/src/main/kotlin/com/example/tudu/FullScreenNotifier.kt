package com.example.tudu

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.io.File

object FullScreenNotifier {
    // New silent channel (sound played via MediaPlayer)
    const val CHANNEL_ID = "alarm_fullscreen_silent_v1"
    const val ACTION_SNOOZE = "com.example.tudu.ACTION_SNOOZE"
    const val ACTION_DISMISS = "com.example.tudu.ACTION_DISMISS"

    private fun ensureSilentChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val ch = NotificationChannel(
                CHANNEL_ID,
                "Alarms (Full Screen, Silent)",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Full-screen alarms and urgent reminders (sound played separately)"
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setSound(null, null) // channel is silent; we play via MediaPlayer
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 600, 200, 600)
                enableLights(true)
                if (Build.VERSION.SDK_INT >= 29) setBypassDnd(true)
            }
            nm.createNotificationChannel(ch)
        }
    }

    /**
     * Posts a full-screen alarm notification and plays custom tone from DB (or default raw).
     */
    fun show(
        ctx: Context,
        title: String,
        text: String,
        route: String,
        extras: Map<String, String> = emptyMap(),
        notifId: Int,
        snoozeMinutes: Int = 5
    ): Boolean {
        ensureSilentChannel(ctx)

        // Full-screen activity intent
        val fsIntent = Intent(ctx, LockScreenActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", route)
            putExtra("notifId", notifId)
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        val fullScreenPi = PendingIntent.getActivity(
            ctx,
            0,
            fsIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        // Snooze action
        val snoozeIntent = Intent(ctx, AlarmActionReceiver::class.java).apply {
            action = ACTION_SNOOZE
            putExtra("notifId", notifId)
            putExtra("snoozeMinutes", snoozeMinutes)
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        val snoozePi = PendingIntent.getBroadcast(
            ctx,
            notifId shl 1,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        // Dismiss action
        val dismissIntent = Intent(ctx, AlarmActionReceiver::class.java).apply {
            action = ACTION_DISMISS
            putExtra("notifId", notifId)
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        val dismissPi = PendingIntent.getBroadcast(
            ctx,
            (notifId shl 1) + 1,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val nm = NotificationManagerCompat.from(ctx)
        if (!nm.areNotificationsEnabled() && Build.VERSION.SDK_INT >= 29) {
            // If notifications are disabled, still try to show the screen and play sound
            ctx.startActivity(fsIntent)
            startSoundFromDb(ctx)
            return false
        }

        // Start sound (custom from DB if present; otherwise raw/loud)
        startSoundFromDb(ctx)

        val n = NotificationCompat.Builder(ctx, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(text)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setDefaults(0)                  // no system sound; we handle sound ourselves
            .setFullScreenIntent(fullScreenPi, true)
            .addAction(0, "Later", dismissPi)
            .addAction(0, "Go", snoozePi)
            .build()

        nm.notify(notifId, n)
        return true
    }

    private fun startSoundFromDb(ctx: Context) {
        val path = AppSettingsStore.getLoudTonePath()
        if (!path.isNullOrBlank() && File(path).exists()) {
            AlarmAudioPlayer.startPath(ctx, path)
        } else {
            AlarmAudioPlayer.startDefault(ctx)
        }
    }
}
