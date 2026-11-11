package com.dhikrapp.qurantracker

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dhikr/widget")
        widgetChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    val editor = getSharedPreferences("dhikr_widget", MODE_PRIVATE).edit()
                    editor.putString("date", call.argument<String>("date"))
                    editor.putString("language", call.argument<String>("language"))
                    for (key in listOf("dhikr", "rukus", "dhikrGoal", "rukuGoal")) {
                        editor.putInt(key, call.argument<Number>(key)?.toInt() ?: 0)
                    }
                    editor.apply()
                    DhikrWidgetProvider.refresh(this)
                    result.success(null)
                }
                "launchRoute" -> {
                    val route = intent.getStringExtra("widgetRoute")
                    intent.removeExtra("widgetRoute")
                    result.success(route)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getStringExtra("widgetRoute") == "/zikr-flow") {
            intent.removeExtra("widgetRoute")
            widgetChannel?.invokeMethod("openCounters", null)
        }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable edge-to-edge display
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}
