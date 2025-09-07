// android/app/src/main/kotlin/com/example/tudu/AlarmAudioPlayer.kt
package com.example.tudu

import android.content.Context
import android.media.*
import android.os.Build
import android.util.Log

object AlarmAudioPlayer {
    private var mp: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private const val TAG = "AlarmAudioPlayer"

    fun startDefault(ctx: Context) {
        stop()
        val afd = ctx.resources.openRawResourceFd(R.raw.loud) ?: return
        try {
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            mp = MediaPlayer().apply {
                setAudioAttributes(attrs)
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                isLooping = true
                setOnErrorListener { _, what, extra ->
                    Log.w(TAG, "MediaPlayer error: $what / $extra"); true
                }
                prepare()
                start()
            }
            afd.close()
            requestFocus(ctx, attrs)
        } catch (e: Exception) {
            Log.e(TAG, "startDefault failed", e)
            try { afd.close() } catch (_: Exception) {}
        }
    }

    fun startPath(ctx: Context, path: String) {
        stop()
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        try {
            mp = MediaPlayer().apply {
                setAudioAttributes(attrs)
                setDataSource(path)
                isLooping = true
                setOnErrorListener { _, what, extra ->
                    Log.w(TAG, "MediaPlayer error: $what / $extra"); true
                }
                prepare()
                start()
            }
            requestFocus(ctx, attrs)
        } catch (e: Exception) {
            Log.e(TAG, "startPath failed", e)
        }
    }

    private fun requestFocus(ctx: Context, attrs: AudioAttributes) {
        try {
            audioManager = ctx.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            if (Build.VERSION.SDK_INT >= 26) {
                val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setOnAudioFocusChangeListener { }
                    .setAudioAttributes(attrs)
                    .build()
                audioManager?.requestAudioFocus(req)
            } else {
                @Suppress("DEPRECATION")
                audioManager?.requestAudioFocus(null, AudioManager.STREAM_ALARM, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            }
        } catch (_: Exception) {}
    }

    fun stop() {
        try { mp?.stop() } catch (_: Exception) {}
        try { mp?.release() } catch (_: Exception) {}
        mp = null
    }
}
