// =============================================================================
// KiperaWidgetProvider — Android Home Screen Widget (Kotlin)
// =============================================================================
//
// HOW TO SET UP IN ANDROID STUDIO:
// 1. Copy this file to: android/app/src/main/kotlin/com/kipera/app/KiperaWidgetProvider.kt
//    (adjust the package path to match your applicationId)
// 2. Copy kipera_widget_layout.xml to: android/app/src/main/res/layout/
// 3. Copy kipera_widget_info.xml to: android/app/src/main/res/xml/
// 4. Register the widget receiver in AndroidManifest.xml (see below)
//
// AndroidManifest.xml addition (inside <application> tag):
//
//   <receiver
//       android:name=".KiperaWidgetProvider"
//       android:exported="true">
//       <intent-filter>
//           <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
//       </intent-filter>
//       <meta-data
//           android:name="android.appwidget.provider"
//           android:resource="@xml/kipera_widget_info" />
//   </receiver>
//
// SHARED DATA KEYS (from Flutter WidgetService):
//   Same keys as iOS — stored via SharedPreferences by home_widget package.
// =============================================================================

/*
package com.kipera.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class KiperaWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.kipera_widget_layout)
            val prefs = HomeWidgetPlugin.getData(context)

            val goalName = prefs.getString("goal_name", "No Goal Selected") ?: "No Goal Selected"
            val progress = prefs.getFloat("goal_progress", 0f)
            val saved = prefs.getFloat("goal_saved", 0f)
            val target = prefs.getFloat("goal_target", 0f)
            val streak = prefs.getInt("goal_streak", 0)
            val isCoupleGoal = prefs.getBoolean("goal_is_couple", false)

            views.setTextViewText(R.id.widget_goal_name, goalName)
            views.setTextViewText(R.id.widget_saved, "$${saved.toInt()}")
            views.setTextViewText(R.id.widget_target, "/ $${target.toInt()}")
            views.setTextViewText(R.id.widget_percentage, "${(progress * 100).toInt()}%")
            views.setTextViewText(R.id.widget_streak, if (streak > 0) "🔥 $streak" else "")
            views.setProgressBar(R.id.widget_progress_bar, 100, (progress * 100).toInt(), false)

            // Show couple badge
            views.setTextViewText(
                R.id.widget_couple_badge,
                if (isCoupleGoal) "❤️" else ""
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
*/
