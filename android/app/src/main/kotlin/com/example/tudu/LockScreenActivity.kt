package com.example.tudu

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class LockScreenActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        // If we’re using a cached engine that’s already running, push a nav event.
        (FlutterEngineCache.getInstance().get("lock_engine"))?.let { engine ->
            if (engine.dartExecutor.isExecutingDart) {
                val route = intent?.getStringExtra("route") ?: "/lockscreen"
                val args = mapOf(
                    "route" to route,
                    "alarm_kind" to (intent?.getStringExtra("alarm_kind") ?: ""),
                    "task_id" to (intent?.getStringExtra("task_id") ?: ""),
                    "task_title" to (intent?.getStringExtra("task_title") ?: "")
                )
                MethodChannel(engine.dartExecutor.binaryMessenger, "app.lock")
                    .invokeMethod("navigateTo", args)
            }
        }
    }

    override fun getInitialRoute(): String {
        // Used when a NEW engine is created
        return intent?.getStringExtra("route") ?: "/lockscreen"
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        val cached = FlutterEngineCache.getInstance().get("lock_engine") ?: return null
        // If engine isn't running yet, set initial route before Dart starts
        if (!cached.dartExecutor.isExecutingDart) {
            val route = intent?.getStringExtra("route") ?: "/lockscreen"
            cached.navigationChannel.setInitialRoute(route)
        }
        return cached
    }
}
