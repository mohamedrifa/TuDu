package com.example.tudu

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object FullScreenNotifier {
    const val CHANNEL_ID = "alarm_fullscreen_v2"

    fun ensureChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            val ch = NotificationChannel(
                CHANNEL_ID,
                "Alarms (Full Screen)",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Full-screen alarms and urgent reminders"
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setSound(soundUri, attrs)
                enableVibration(true)
                enableLights(true)
                if (Build.VERSION.SDK_INT >= 29) setBypassDnd(true)
            }
            nm.createNotificationChannel(ch)
        }
    }

    /**
     * Posts a full-screen notification that launches LockScreenActivity.
     * Returns true if posted; false if it fell back to startActivity.
     */
    fun show(
        ctx: Context,
        title: String,
        text: String,
        route: String,
        extras: Map<String, String> = emptyMap(),
        notifId: Int
    ): Boolean {
        ensureChannel(ctx)

        val intent = Intent(ctx, LockScreenActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", route)
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        val fullScreenPi = PendingIntent.getActivity(
            ctx,
            0,
            intent,
            (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0) or
                PendingIntent.FLAG_UPDATE_CURRENT
        )

        val nm = NotificationManagerCompat.from(ctx)
        val canNotify = nm.areNotificationsEnabled()

        if (!canNotify && Build.VERSION.SDK_INT >= 29) {
            // Best-effort fallback if user disabled notifications.
            ctx.startActivity(intent)
            return false
        }

        val n = NotificationCompat.Builder(ctx, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(text)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX) // pre-26
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true) // keeps it on screen until acted upon
            .setAutoCancel(true)
            .setDefaults(0) // we set sound via channel on O+, below sets pre-26
            .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM))
            .setFullScreenIntent(fullScreenPi, true) // 👈 the key for full-screen
            .build()

        nm.notify(notifId, n)
        return true
    }
}
