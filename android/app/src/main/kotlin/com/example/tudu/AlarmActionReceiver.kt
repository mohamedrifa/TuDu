// android/app/src/main/kotlin/com/example/tudu/AlarmActionReceiver.kt
package com.example.tudu

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

class AlarmActionReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val notifId = intent.getIntExtra("notifId", 0)
        when (intent.action) {
            FullScreenNotifier.ACTION_DISMISS -> {
                AlarmAudioPlayer.stop()
                NotificationManagerCompat.from(ctx).cancel(notifId)
                // Optionally: also close any full-screen UI
            }
            FullScreenNotifier.ACTION_SNOOZE -> {
                AlarmAudioPlayer.stop()
                NotificationManagerCompat.from(ctx).cancel(notifId)
                val minutes = intent.getIntExtra("snoozeMinutes", 5)
                // TODO: schedule your own alarm re-post after [minutes]
                // e.g., AlarmScheduler.schedule(ctx, minutes, extras...) or WorkManager, etc.
            }
        }
    }
}
