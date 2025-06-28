package com.example.tudu

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class LockScreenActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setShowWhenLocked(true)
        setTurnScreenOn(true)
    }

    override fun getInitialRoute(): String {
        return "/lockscreen"
    }

    override fun provideFlutterEngine(context: android.content.Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get("lock_engine")
    }
}
