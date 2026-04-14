package com.kipera.kipera

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.*
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class KiperaWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        Log.d(TAG, "onUpdate called — widgetIds: ${appWidgetIds.joinToString()}")

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.kipera_widget_layout)

            try {
                val goalName = widgetData.all["goal_name"]?.toString() ?: ""
                val progress = readDouble(widgetData, "goal_progress")
                val saved = readDouble(widgetData, "goal_saved")
                val target = readDouble(widgetData, "goal_target")
                val streak = safeInt(widgetData.all["goal_streak"])
                val isCoupleGoal = widgetData.all["goal_is_couple"] as? Boolean ?: false

                Log.d(TAG, "Data — name=$goalName, progress=$progress, saved=$saved, target=$target, streak=$streak, couple=$isCoupleGoal")

                if (goalName.isEmpty()) {
                    showEmptyState(context, views)
                } else {
                    showGoalState(context, views, goalName, progress, saved, target, streak, isCoupleGoal)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget", e)
                showEmptyState(context, views)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
            Log.d(TAG, "Widget $appWidgetId updated successfully")
        }
    }

    private fun showEmptyState(context: Context, views: RemoteViews) {
        views.setTextViewText(R.id.widget_goal_name, context.getString(R.string.widget_empty_title))
        views.setTextViewText(R.id.widget_saved, context.getString(R.string.widget_empty_saved))
        views.setTextViewText(R.id.widget_target, "")
        views.setTextViewText(R.id.widget_percentage, "—")
        views.setTextViewText(R.id.widget_percentage_sign, "")
        views.setTextViewText(R.id.widget_streak, "")
        views.setProgressBar(R.id.widget_progress_bar, 100, 0, false)
        views.setViewVisibility(R.id.widget_couple_icon, View.GONE)
        views.setImageViewBitmap(R.id.widget_arc_progress, renderArc(0.0, false))
    }

    private fun showGoalState(
        context: Context,
        views: RemoteViews,
        goalName: String,
        progress: Double,
        saved: Double,
        target: Double,
        streak: Int,
        isCoupleGoal: Boolean
    ) {
        views.setTextViewText(R.id.widget_goal_name, goalName)
        views.setTextViewText(R.id.widget_saved, formatCurrency(saved))
        views.setTextViewText(R.id.widget_target, "/ ${formatCurrency(target)}")
        views.setTextViewText(R.id.widget_percentage, "${(progress * 100).toInt()}")
        views.setTextViewText(R.id.widget_percentage_sign, "%")
        views.setProgressBar(R.id.widget_progress_bar, 100, (progress * 100).toInt(), false)

        // Streak badge
        views.setTextViewText(
            R.id.widget_streak,
            if (streak > 0) "\uD83D\uDD25 $streak" else ""
        )

        // Semi-arc progress bitmap
        views.setImageViewBitmap(R.id.widget_arc_progress, renderArc(progress, isCoupleGoal))

        // Accent bar color — purple→pink gradient for couple, purple for solo
        views.setImageViewBitmap(R.id.widget_accent_bar, renderAccentBar(isCoupleGoal))

        // Couple indicator
        if (isCoupleGoal) {
            views.setViewVisibility(R.id.widget_couple_icon, View.VISIBLE)
            views.setImageViewBitmap(R.id.widget_couple_icon, renderCoupleIndicator())
        } else {
            views.setViewVisibility(R.id.widget_couple_icon, View.GONE)
        }
    }

    // ── Rendering ──

    /**
     * Render a semi-arc progress indicator as a bitmap.
     * Matches the iOS widget's SemiArc style.
     */
    private fun renderArc(progress: Double, isCoupleGoal: Boolean): Bitmap {
        val size = 240  // px, will be scaled down by ImageView
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val cx = size / 2f
        val cy = size / 2f
        val radius = size / 2f - 24f
        val strokeWidth = 22f

        val startAngle = 140f
        val sweepAngle = 260f

        val rect = RectF(cx - radius, cy - radius, cx + radius, cy + radius)

        // Track (background arc)
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            this.strokeWidth = strokeWidth
            strokeCap = Paint.Cap.ROUND
            color = Color.parseColor("#F3F4F6")
        }
        canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint)

        // Progress arc with gradient
        if (progress > 0) {
            val progressSweep = (sweepAngle * progress).toFloat()
            val progressPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                this.strokeWidth = strokeWidth
                strokeCap = Paint.Cap.ROUND
                shader = if (isCoupleGoal) {
                    SweepGradient(cx, cy, intArrayOf(
                        Color.parseColor("#E0CFFC"),
                        Color.parseColor("#A855F7"),
                        Color.parseColor("#EC4899")
                    ), null)
                } else {
                    SweepGradient(cx, cy, intArrayOf(
                        Color.parseColor("#E0CFFC"),
                        Color.parseColor("#A855F7")
                    ), null)
                }
            }

            // Rotate shader to start at the arc's start angle
            val matrix = Matrix()
            matrix.postRotate(startAngle, cx, cy)
            progressPaint.shader.setLocalMatrix(matrix)

            canvas.drawArc(rect, startAngle, progressSweep, false, progressPaint)
        }

        return bitmap
    }

    /**
     * Render couple indicator: two overlapping circles (purple + pink)
     * similar to iOS CoupleIndicator.
     */
    private fun renderCoupleIndicator(): Bitmap {
        val width = 84
        val height = 48
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val circleSize = 18f
        val cy = height / 2f
        val overlap = circleSize * 0.3f

        // Left circle (purple)
        val purplePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#A855F7")
            alpha = 217  // 0.85 * 255
        }
        canvas.drawCircle(circleSize, cy, circleSize, purplePaint)

        // Person icon in left circle
        val iconPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = circleSize * 0.9f
            textAlign = Paint.Align.CENTER
            typeface = Typeface.DEFAULT
        }
        canvas.drawText("\u2022", circleSize, cy + circleSize * 0.3f, iconPaint)

        // Right circle (pink)
        val pinkPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#EC4899")
            alpha = 217
        }
        val rightCx = circleSize * 2 - overlap
        canvas.drawCircle(rightCx, cy, circleSize, pinkPaint)
        canvas.drawText("\u2022", rightCx, cy + circleSize * 0.3f, iconPaint)

        return bitmap
    }

    /**
     * Render the accent bar at the top with appropriate gradient.
     */
    private fun renderAccentBar(isCoupleGoal: Boolean): Bitmap {
        val width = 600
        val height = 9
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                0f, 0f, width.toFloat(), 0f,
                if (isCoupleGoal) {
                    intArrayOf(
                        Color.parseColor("#A855F7"),
                        Color.parseColor("#EC4899")
                    )
                } else {
                    intArrayOf(
                        Color.parseColor("#B088F7"),
                        Color.parseColor("#A855F7")
                    )
                },
                null,
                Shader.TileMode.CLAMP
            )
        }
        val rect = RectF(0f, 0f, width.toFloat(), height.toFloat())
        canvas.drawRoundRect(rect, 4f, 4f, paint)
        return bitmap
    }

    // ── Data helpers ──

    private fun readDouble(prefs: SharedPreferences, key: String): Double {
        val isDouble = prefs.getBoolean("home_widget.double.$key", false)
        return if (isDouble) {
            val longBits = prefs.getLong(key, 0L)
            java.lang.Double.longBitsToDouble(longBits)
        } else {
            safeDouble(prefs.all[key])
        }
    }

    private fun safeDouble(value: Any?): Double {
        return when (value) {
            is Double -> value
            is Float -> value.toDouble()
            is Long -> value.toDouble()
            is Int -> value.toDouble()
            is String -> value.toDoubleOrNull() ?: 0.0
            else -> 0.0
        }
    }

    private fun safeInt(value: Any?): Int {
        return when (value) {
            is Int -> value
            is Long -> value.toInt()
            is Double -> value.toInt()
            is Float -> value.toInt()
            is String -> value.toIntOrNull() ?: 0
            else -> 0
        }
    }

    private fun formatCurrency(value: Double): String {
        return when {
            value >= 1_000_000 -> String.format("$%.1fM", value / 1_000_000)
            value >= 10_000 -> String.format("$%.1fK", value / 1_000)
            value % 1.0 == 0.0 -> "$${value.toInt()}"
            else -> String.format("$%.2f", value)
        }
    }

    companion object {
        private const val TAG = "KiperaWidget"
    }
}
