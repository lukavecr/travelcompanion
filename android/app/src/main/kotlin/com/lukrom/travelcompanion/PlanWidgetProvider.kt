package com.lukrom.travelcompanion

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Widget „Plán na 3 dny + dnešní útrata“. Data připravuje Flutter (home_widget_service.dart)
 * na 14 dní dopředu – tady se jen vybere dnešek a další dva dny, takže po půlnoci
 * widget ukazuje správné dny i bez otevření aplikace.
 */
class PlanWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val days = try {
            JSONArray(widgetData.getString("w_days", "[]"))
        } catch (e: Exception) {
            JSONArray()
        }
        val spend = try {
            JSONObject(widgetData.getString("w_spend", "{}"))
        } catch (e: Exception) {
            JSONObject()
        }
        val labelToday = widgetData.getString("w_today", "Dnes") ?: "Dnes"
        val labelTomorrow = widgetData.getString("w_tomorrow", "Zítra") ?: "Zítra"
        val labelEmpty = widgetData.getString("w_empty", "Nic naplánováno") ?: "Nic naplánováno"
        val labelSpent = widgetData.getString("w_spent", "Dnes utraceno") ?: "Dnes utraceno"
        val title = widgetData.getString("w_title", "Travel Companion") ?: "Travel Companion"

        // dnešek a dva další dny
        val shown = mutableListOf<JSONObject>()
        for (i in 0 until days.length()) {
            val d = days.getJSONObject(i)
            if (d.optString("d") >= today && shown.size < 3) shown.add(d)
        }

        val heads = intArrayOf(R.id.day1_head, R.id.day2_head, R.id.day3_head)
        val bodies = intArrayOf(R.id.day1_body, R.id.day2_body, R.id.day3_body)

        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.plan_widget)
            views.setTextViewText(R.id.widget_title, title)
            val spent = spend.optString(today, "")
            views.setTextViewText(R.id.widget_spend, if (spent.isEmpty()) "" else "$labelSpent: $spent")

            for (i in 0 until 3) {
                if (i < shown.size) {
                    val d = shown[i]
                    val prefix = when (i) {
                        0 -> if (d.optString("d") == today) "$labelToday · " else ""
                        1 -> if (shown[0].optString("d") == today) "$labelTomorrow · " else ""
                        else -> ""
                    }
                    views.setTextViewText(heads[i], prefix + d.optString("label"))
                    val items = d.optJSONArray("items") ?: JSONArray()
                    val lines = (0 until items.length()).map { items.getString(it) }
                    views.setTextViewText(bodies[i], if (lines.isEmpty()) labelEmpty else lines.joinToString("\n"))
                    views.setViewVisibility(heads[i], android.view.View.VISIBLE)
                    views.setViewVisibility(bodies[i], android.view.View.VISIBLE)
                } else {
                    views.setViewVisibility(heads[i], android.view.View.GONE)
                    views.setViewVisibility(bodies[i], android.view.View.GONE)
                }
            }
            if (shown.isEmpty()) {
                views.setViewVisibility(heads[0], android.view.View.VISIBLE)
                views.setTextViewText(heads[0], labelEmpty)
            }

            val intent = HomeWidgetLaunchIntent.getActivity(
                context, MainActivity::class.java, Uri.parse("travelcompanion://widget")
            )
            views.setOnClickPendingIntent(R.id.widget_root, intent)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
