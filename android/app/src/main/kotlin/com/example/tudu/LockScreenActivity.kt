package com.example.tudu

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class LockScreenActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Show activity over lock screen and turn screen on
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
    }

    override fun getInitialRoute(): String {
        return "/lockscreen"
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get("lock_engine")
    }
}
