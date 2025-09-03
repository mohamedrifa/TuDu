package com.example.tudu

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object Notifier {
    fun show(ctx: Context, title: String, text: String, id: Int) {
        val intent = Intent(ctx, MainActivity::class.java)

        val pi = PendingIntent.getActivity(
            ctx,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE  // <-- Kotlin
        )

        val n = NotificationCompat.Builder(ctx, TaskTickReceiver.NOTIF_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(pi)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        NotificationManagerCompat.from(ctx).notify(id, n)
    }
}
