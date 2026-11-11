package com.dhikrapp.qurantracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class DhikrWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val prefs = context.getSharedPreferences("dhikr_widget", Context.MODE_PRIVATE)
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(Locale(prefs.getString("language", "en") ?: "en"))
        val localized = context.createConfigurationContext(configuration)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val current = prefs.getString("date", "") == today
        val dhikr = if (current) prefs.getInt("dhikr", 0) else 0
        val rukus = if (current) prefs.getInt("rukus", 0) else 0
        val intent = Intent(context, MainActivity::class.java)
            .putExtra("widgetRoute", "/zikr-flow")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pending = PendingIntent.getActivity(context, 17, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.dhikr_widget)
            views.setTextViewText(R.id.widget_heading, localized.getString(R.string.widget_name))
            views.setTextViewText(R.id.widget_hint, localized.getString(R.string.widget_open))
            views.setTextViewText(R.id.widget_dhikr, localized.getString(R.string.widget_dhikr,
                dhikr, prefs.getInt("dhikrGoal", 100)))
            views.setTextViewText(R.id.widget_rukus, localized.getString(R.string.widget_rukus,
                rukus, prefs.getInt("rukuGoal", 2)))
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            manager.updateAppWidget(id, views)
        }
    }

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, DhikrWidgetProvider::class.java))
            DhikrWidgetProvider().onUpdate(context, manager, ids)
        }
    }
}
