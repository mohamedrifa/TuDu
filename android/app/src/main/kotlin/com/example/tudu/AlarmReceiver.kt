package com.example.tudu

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        Log.d("AlarmReceiver", "🔥 Alarm triggered")

        // Optional: Acquire a temporary wake lock if needed
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "tudu:alarmWakeLock"
        )
        wakeLock.acquire(10 * 1000L)

        // Start the LockScreenActivity
        val i = Intent(context, LockScreenActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        context.startActivity(i)
    }
}
