package com.example.tudu

import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "battery_optimization"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "isIgnoringBatteryOptimizations") {
                val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                val packageName = applicationContext.packageName

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val isIgnoring = powerManager.isIgnoringBatteryOptimizations(packageName)
                    result.success(isIgnoring)
                } else {
                    result.success(true)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

