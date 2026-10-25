package com.lukrom.travelcompanion

import android.Manifest
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Widget „Plán na 3 dny + dnešní útrata + kroky + záznam trasy“.
 *
 * Plán připravuje Flutter (home_widget_service.dart) na 14 dní dopředu – tady se jen vybere dnešek
 * a další dva dny, takže po půlnoci widget ukazuje správné dny i bez otevření aplikace.
 * Kroky: senzor krokoměru telefonu (počet od zapnutí telefonu), dnešní kroky = rozdíl od stavu
 * o půlnoci (překreslení o půlnoci plánuje aplikace). Tlačítko trasy otevře aplikaci s odkazem
 * travelcompanion://track (aplikace záznam spustí / zastaví).
 */
class PlanWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        render(context, appWidgetManager, appWidgetIds, widgetData, loadSteps(context))
        // kroky ze senzoru přijdou asynchronně → překreslit ještě jednou
        if (widgetData.getString("w_steps_on", "0") == "1" && hasStepPermission(context)) {
            val pending = goAsync()
            readStepCounter(context) { total ->
                try {
                    val steps = if (total != null) stepsToday(context, total) else loadSteps(context)
                    render(context, appWidgetManager, appWidgetIds, widgetData, steps)
                } finally {
                    pending.finish()
                }
            }
        }
    }

    private fun render(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
        steps: Int?,
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
        fun s(key: String, def: String) = widgetData.getString(key, def) ?: def
        val labelToday = s("w_today", "Dnes")
        val labelTomorrow = s("w_tomorrow", "Zítra")
        val labelEmpty = s("w_empty", "Nic naplánováno")
        val labelSpent = s("w_spent", "Dnes utraceno")
        val title = s("w_title", "Travel Companion")
        val recording = s("w_rec", "0") == "1"

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
                    views.setViewVisibility(heads[i], View.VISIBLE)
                    views.setViewVisibility(bodies[i], View.VISIBLE)
                } else {
                    views.setViewVisibility(heads[i], View.GONE)
                    views.setViewVisibility(bodies[i], View.GONE)
                }
            }
            if (shown.isEmpty()) {
                views.setViewVisibility(heads[0], View.VISIBLE)
                views.setTextViewText(heads[0], labelEmpty)
            }

            // kroky
            if (steps != null && s("w_steps_on", "0") == "1") {
                views.setTextViewText(R.id.widget_steps, "👣 " + String.format(Locale.getDefault(), "%,d", steps) + " " + s("w_steps", "kroků"))
                views.setViewVisibility(R.id.widget_steps, View.VISIBLE)
            } else {
                views.setTextViewText(R.id.widget_steps, "")
            }

            // záznam trasy
            views.setTextViewText(
                R.id.widget_track,
                if (recording) "■ " + s("w_track_stop", "Stop") + "  " + s("w_track_dist", "")
                else "▶ " + s("w_track_start", "Trasa"),
            )
            views.setInt(
                R.id.widget_track, "setBackgroundResource",
                if (recording) R.drawable.widget_button_stop else R.drawable.widget_button,
            )
            views.setOnClickPendingIntent(
                R.id.widget_track,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("travelcompanion://track")),
            )
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("travelcompanion://open")),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    // ---------- krokoměr ----------

    private fun hasStepPermission(context: Context) =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            context.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_GRANTED

    /** Přečte celkový počet kroků od zapnutí telefonu (null = senzor nemá / neodpověděl). */
    private fun readStepCounter(context: Context, done: (Int?) -> Unit) {
        val sm = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor = sm.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        if (sensor == null) {
            done(null)
            return
        }
        val handler = Handler(Looper.getMainLooper())
        var finished = false
        val listener = object : SensorEventListener {
            override fun onSensorChanged(e: SensorEvent) {
                if (finished) return
                finished = true
                sm.unregisterListener(this)
                done(e.values[0].toInt())
            }

            override fun onAccuracyChanged(s: Sensor?, a: Int) {}
        }
        sm.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
        handler.postDelayed({
            if (!finished) {
                finished = true
                sm.unregisterListener(listener)
                done(null)
            }
        }, 4000)
    }

    private fun prefs(context: Context) = context.getSharedPreferences("tc_steps", Context.MODE_PRIVATE)

    /** Dnešní kroky: rozdíl od prvního údaje dne (o půlnoci se widget překreslí sám). */
    private fun stepsToday(context: Context, total: Int): Int {
        val p = prefs(context)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        var base = p.getInt("base", -1)
        if (p.getString("date", "") != today || base < 0 || total < base) {
            // nový den nebo restart telefonu (počítadlo začne od nuly)
            base = if (p.getString("date", "") == today && total < base) 0 else total
            p.edit().putString("date", today).putInt("base", base).apply()
        }
        val steps = total - base
        p.edit().putInt("last", steps).putString("lastDate", today).apply()
        return steps
    }

    private fun loadSteps(context: Context): Int? {
        val p = prefs(context)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        return if (p.getString("lastDate", "") == today) p.getInt("last", 0) else null
    }
}
