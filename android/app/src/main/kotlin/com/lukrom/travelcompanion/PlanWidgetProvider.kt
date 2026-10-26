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
        val title = s("w_title", "Comes Viae")
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
            // název cesty, případně s dnešní útratou
            val spent = spend.optString(today, "")
            views.setTextViewText(R.id.widget_title, if (spent.isEmpty()) title else "$title · $labelSpent $spent")

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
                    views.setTextViewText(bodies[i], if (lines.isEmpty()) labelEmpty else lines.joinToString(" · "))
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

            // kroky (vpravo nahoře); vypnuté → klepnutím zapnout
            when {
                s("w_steps_on", "0") != "1" -> {
                    views.setTextViewText(R.id.widget_steps, "👣")
                    views.setTextViewText(R.id.widget_steps_label, s("w_steps_enable", "Zapnout kroky"))
                }
                steps == null -> {
                    views.setTextViewText(R.id.widget_steps, "👣 …")
                    views.setTextViewText(R.id.widget_steps_label, s("w_steps", "kroků"))
                }
                else -> {
                    views.setTextViewText(R.id.widget_steps, String.format(Locale.getDefault(), "%,d", steps))
                    views.setTextViewText(R.id.widget_steps_label, "👣 " + s("w_steps", "kroků"))
                }
            }
            views.setOnClickPendingIntent(
                R.id.widget_steps_box,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("travelcompanion://steps")),
            )

            // záznam trasy (vpravo dole)
            views.setTextViewText(R.id.widget_track_icon, if (recording) "■" else "▶")
            views.setTextViewText(
                R.id.widget_track_label,
                if (recording) s("w_track_dist", "").ifEmpty { s("w_track_stop", "Stop") } else s("w_track_start", "Trasa"),
            )
            views.setInt(
                R.id.widget_track, "setBackgroundResource",
                if (recording) R.drawable.widget_button_stop else R.drawable.widget_button,
            )
            // Start/Stop bez otevření aplikace (neviditelná aktivita spustí / zastaví službu)
            views.setOnClickPendingIntent(
                R.id.widget_track,
                android.app.PendingIntent.getActivity(
                    context, 3, android.content.Intent(context, TrackToggleActivity::class.java),
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
                ),
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

    /**
     * Dnešní kroky = celkový počet (od zapnutí telefonu) − stav o půlnoci.
     * Stav o půlnoci = poslední údaj ze včerejška (widget se obnovuje zhruba každých 30 min),
     * takže ranní kroky se neztratí, ani když systém půlnoční obnovení zdrží.
     */
    private fun stepsToday(context: Context, total: Int): Int {
        val p = prefs(context)
        val fmt = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val today = fmt.format(Date())
        val yesterday = fmt.format(Date(System.currentTimeMillis() - 24L * 3600 * 1000))
        var base = p.getInt("base", -1)
        if (p.getString("date", "") != today) {
            val lastTotal = p.getInt("lastTotal", -1)
            base = if (p.getString("lastTotalDate", "") == yesterday && lastTotal in 0..total) lastTotal else total
            p.edit().putString("date", today).putInt("base", base).apply()
        } else if (total < base) {
            base = 0 // restart telefonu: počítadlo začalo znovu od nuly
            p.edit().putInt("base", 0).apply()
        }
        val steps = total - base
        p.edit().putInt("last", steps).putString("lastDate", today)
            .putInt("lastTotal", total).putString("lastTotalDate", today).apply()
        return steps
    }

    private fun loadSteps(context: Context): Int? {
        val p = prefs(context)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        return if (p.getString("lastDate", "") == today) p.getInt("last", 0) else null
    }
}
